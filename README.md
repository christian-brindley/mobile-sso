# Mobile to web SSO with PingOne Identity Cloud

## Introduction

This repository contains sample artefacts for demonstrating how to enable single signon between a mobile app and a webview launched from the app, using PingOne Advanced Identity Cloud (or a version of PingAM which supports Backchannel Authentication).

Refer to the [associated blog](https://medium.com/@christian.brindley/wwwhoosh-creating-a-mobile-launchpad-for-your-web-apps-using-ping-advanced-identity-cloud-79a7faa095ed) for more background.

## Repository contents

The repository contains the following directories

- `journeys`
  Two journeys for the initiation of the SSO request, and the follow on backchannel journey:
  `Mobile SSO - Initialise-journeyExport.json`
  `Mobile SSO - Login-journeyExport`

- `custom-node`
  Sample custom nodes included in the initialisation journey:
  `DEMO Headers to State-node.json`
  `DEMO OAuth2 Introspect-nodejson`

- `ios`
  Sample Swift code to merge with the demonstration iOS app included with the Ping SDK.

## Requirements

To run this demo, you will need

- A [PingOne Advanced Identity Cloud](https://docs.pingidentity.com/pingoneaic/getting-started/overview.html) tenant (or [PingAM](https://docs.pingidentity.com/pingam/latest/index.html) version which supports Backchannel Authentication)
- The [Ping SDK sample app repository](https://github.com/ForgeRock/sdk-sample-apps)
