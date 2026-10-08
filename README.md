<h3 align="center">🦫 Mobile app toolkit for indies and small teams</h3>

<p align="center">
  <img src="https://img.shields.io/badge/iOS-17%2B-blue.svg" alt="iOS 17+">
  <img src="https://img.shields.io/badge/Swift-6.2%2B-orange.svg" alt="Swift 6.2+">
  <img src="https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg" alt="SwiftPM compatible">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-lightgrey.svg" alt="MIT License"></a>
</p>

If you are a small team or an indie working on apps for iOS and Android: Don't waste time on anything outside your core business! [Mobile Joe](https://mobilejoe.dev) provides the backend and native mobile SDKs, so you can start using our tools in your app right away:

- **Feature plans**: Turn user suggestions into curated plans in your own words and use votes to prioritize what to build next.
- **Alerts**: Let users know right away when there is a critical bug, a server outage, or delayed orders.
- **FAQs**: Answer common questions directly in your app and update them without an app release.
- …and more coming soon.

Your users never sign up for a third-party account. Use the ready-made SwiftUI views or build your own UI on top of the core SDK.

[Sign up](https://mobilejoe.dev/#pricing) to get started.

## Features

| Feature | SwiftUI view |
| --- | --- |
| Feature plans with voting, search, and roadmap filters | `FeaturePlansView` |
| FAQs with optional email support | `FAQView` |
| In-app alert banners with detail sheets | `AlertsView` |

Requires iOS 17+ and Swift 6.2+ (Xcode 26+).

## Installation

Add this Swift package in Xcode and link `MobileJoe` and `MobileJoeUI` to your app target:

```text
https://github.com/MobileJoeDev/mobilejoe-ios.git
```

## Quick start

Configure once at app startup and await it before showing SDK views:

```swift
import SwiftUI
import MobileJoe
import MobileJoeUI

@main
struct MyApp: App {
  @State private var isConfigured = false

  var body: some Scene {
    WindowGroup {
      if isConfigured {
        NavigationStack {
          FAQView(presentationMode: .inNavigationStack, configuration: .standard(recipient: "support@example.com"))
        }
      } else {
        ProgressView()
          .task {
            do {
              try await Joe.configure(withAPIKey: "YOUR_API_KEY")
              isConfigured = true
            } catch {
              print("Mobile Joe configuration failed: \(error)")
            }
          }
      }
    }
  }
}
```

## Documentation

API keys, user identity, feature plans, alerts, and custom UI are covered in the [Mobile Joe documentation](https://docs.mobilejoe.dev). Start with the [iOS quickstart](https://docs.mobilejoe.dev/ios/quickstart/).

The [sample app](Examples/SampleJoe) shows all views with preview data and runs without an API key.
