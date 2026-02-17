// Disclaimer
//
// THE CODE HEREUNDER IS PROVIDED "AS IS" AND WITHOUT WARRANTY OF ANY KIND.
// SUCH CODE IS EXPRESSLY EXCLUDED FROM PING IDENTITY'S INDEMNITY OR SUPPORT
// OBLIGATIONS, IF ANY, PURSUANT TO THE RELEVANT GOVERNING AGREEMENT.
// PING IDENTITY AND ITS LICENSORS EXPRESSLY DISCLAIM ALL WARRANTIES, WHETHER
// EXPRESS, IMPLIED OR STATUTORY, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND ANY
// WARRANTY OF NON-INFRINGEMENT. PING IDENTITY SHALL NOT HAVE ANY LIABILITY ARISING
// OUT OF OR RELATING TO ANY USE, IMPLEMENTATION OR CONFIGURATION OF THE SAMPLE
// CODE HEREUNDER.

//
//  WebViewScreen.swift
//  Sample webview handler for JourneyModuleSample demonstrator app
//

import SwiftUI
import WebKit
import PingOidc
import PingLogger
import PingJourney


// MARK: - Screen


struct WebViewScreen: View {
    let url: String
    

    @State private var finalURL: URL?
    @State private var errorMessage: String?
    

    var body: some View {
        Group {
            if let finalURL {
                WebView(url: finalURL)
            } else if let errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            } else {
                ProgressView("Loading…")
            }
        }
        .task {
            await loadSsoUrl(targetUrl: url)
        }
    }
    
    
    // MARK: - SSO Flow

    private func loadSsoUrl(targetUrl: String) async {
        do {
            let journeyUrlString = Bundle.main.object(forInfoDictionaryKey: "ssoInitiationJourneyUrl") as! String;
            let journeyUrl = URL(string: journeyUrlString);
            let bearerToken = try await getToken()

            var request = URLRequest(url: journeyUrl!)
            request.httpMethod = "POST"
            // No body required

            // Authorization header
            request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
            request.setValue("protocol=1.0,resource=2.1", forHTTPHeaderField: "Accept-API-Version")
            request.setValue(targetUrl, forHTTPHeaderField: "X-SSO-Location")

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode) else {
                throw URLError(.badServerResponse)
            }

            let decoded = try JSONDecoder().decode(SSOResponse.self, from: data)
            finalURL = URL(string: decoded.successUrl)!
        } catch {
            errorMessage = "Failed to load page"
            print("SSO fetch error:", error)
        }
    }

    private struct SSOResponse: Decodable {
        let successUrl: String
    }
    
    private func getToken() async throws -> String  {
        let token: Result<Token, OidcError>? = await journey.journeyUser()?.token()

        switch token {
        case .success(let token):
            return token.accessToken
        case .failure(let error):
            LogManager.standard.e("", error: error)
            return ""
        case .none:
            return ""
        }
    }
}

// MARK: - WebView

private struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.allowsBackForwardNavigationGestures = true
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if webView.url != url {
            webView.load(URLRequest(url: url))
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("WebView navigation error:", error.localizedDescription)
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("WebView provisional navigation error:", error.localizedDescription)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        WebViewScreen(
            url: "https://www.example.com"
        )
    }
}
