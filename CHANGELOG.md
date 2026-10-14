# Changelog

All notable changes to the Mobile Joe iOS SDK are documented in this file.

## 1.0.1

Fixes alerts that were missing on a cold start. This release changes how you set up the SDK and removes internals from the public API, so it needs small changes in your app. It also simplifies the FAQ list.

### Setup

- `Joe.configure(withAPIKey:appUserID:debugMode:)`, `Joe.identify(appUserID:)`, and `Joe.logout()` are no longer `async`. Remove `await` from these calls.
- Call `Joe.configure` in your app's initializer, before any SDK view appears. It returns right away, and SDK views load content immediately.
- The SDK sends the identity to Mobile Joe in the background, once per app start and once per identity change. If that fails, it logs an error with the subsystem `MobileJoe` and retries on the next app start.
- A rejected API key now throws `MobileJoeError.invalidAPIKey` (code 1007) instead of `MobileJoeError.httpFailure` with status 401. It disables SDK requests until the app restarts.

### Fixes

- `AlertsView` on the start screen showed no active alert on a cold start until the app returned from the background.
- A corrupt identity file no longer makes `Joe.configure` fail on every launch. The SDK replaces it with a new identity.

### FAQs

- The FAQ list shows only the question of each entry. The answer opens in the detail view.
- An entry opens with push navigation instead of a sheet, and each row shows a chevron.
- With a support recipient, the FAQ list shows the contact hint and the email link below the entries, not only in the detail view.
- After a failed refresh, the FAQ list keeps its entries instead of showing the failure view.

### Public API

- `AlertGateway`, `FAQGateway`, `FeaturePlanGateway`, `FeaturePlanGatewayError`, and `init(gateway:)` on `Alerts`, `FAQs`, and `FeaturePlans` are no longer public. Use `Alerts()`, `FAQs()`, and `FeaturePlans()`.
- `all` on `Alerts`, `FAQs`, and `FeaturePlans` is read-only.
- Preview data (`.preview`, `.previewEmpty`, and others) moved to `MobileJoeUI`. Add `import MobileJoeUI` to SwiftUI previews that use it.
- `FeaturePlan.init(id:…)`, `FeaturePlan.update(from:)`, `Calendar.utc`, and `Calendar.date(year:…)` are no longer public.

## 1.0.0

First public release of the Mobile Joe iOS SDK.

- Feature plans: let users suggest and vote on features, with search and roadmap filters (`FeaturePlansView`).
- Alerts: show in-app banners with detail sheets for outages or critical bugs (`AlertsView`).
- FAQs: answer common questions in your app, with optional email support (`FAQView`).
- Build your own UI on top of the core `MobileJoe` library.

Requires iOS 17+ and Swift 6.2+ (Xcode 26+).
