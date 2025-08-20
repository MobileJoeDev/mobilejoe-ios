# MobileJoe

MobileJoe is a Swift Package for integrating feature request collection and voting into your iOS app. It consists of a core SDK (`MobileJoe`) and SwiftUI UI components (`MobileJoeUI`).

## Installation

Add the package to your Xcode project via Swift Package Manager using the repository URL.

Minimum requirements: iOS 17+, Swift tools 6.0

## Quick Start

1) Configure the SDK early in your app lifecycle (e.g., `App` init or `application(_:didFinishLaunchingWithOptions:)`):

```swift
import MobileJoe

@main
struct MyApp: App {
  init() {
    MobileJoe.configure(withAPIKey: "YOUR_API_KEY", appUserID: nil)
  }
  var body: some Scene { WindowGroup { ContentView() } }
}
```

2) Present the Feature Requests UI anywhere in your app:

```swift
import MobileJoeUI

struct ContentView: View {
  @State private var showing = false
  var body: some View {
    Button("Feature Requests") { showing = true }
      .sheet(isPresented: $showing) {
        FeatureRequestListView(
          configuration: .init(recipients: ["support@example.com"]) // Optional mail link
        )
      }
  }
}
```

## Development

- Build with SPM: `swift build`
- Tests use Swift's `Testing` library and are under `Tests/MobileJoeTests/`

## Testing

Run package tests on an iOS Simulator using Xcode:

```bash
# List schemes
xcodebuild -list

# Pick a simulator and run tests
xcodebuild test \
  -scheme MobileJoe-Package \
  -destination "platform=iOS Simulator,name=iPhone 16 Pro,OS=18.5"
```

Troubleshooting:
- If the specified simulator is unavailable, list devices with `xcrun simctl list devices` and adjust the `-destination`.
- If tests don’t start or hang, try opening the package in Xcode once to let it resolve toolchains and create DerivedData.
- `swift test` won’t run iOS-targeted tests; use `xcodebuild` as shown above.
