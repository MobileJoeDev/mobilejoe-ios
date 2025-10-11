# Repository Guidelines

## Project Structure & Module Organization
- `Package.swift` exports two libraries: the core SDK in `Sources/MobileJoe` and SwiftUI surfaces in `MobileJoeUI`.
- Core modules are grouped by domain (`Alerts/`, `FeatureRequests/`, `Identity/`, `Networking/`, etc.); favor extending the matching folder when adding new capabilities.
- UI components mirror the core naming and ship localized assets under `MobileJoeUI/Resources`.
- Tests live in `Tests/MobileJoeTests`, organized by feature area (`FeatureRequests/`, `Identity/`, `Networking/`); create new folders when introducing sizable domains.

## Build, Test & Development Commands
- `swift build` compiles the package locally and is the fastest way to verify Swift 6 compatibility.
- `xcodebuild test -scheme MobileJoe-Package -destination "platform=iOS Simulator,name=iPhone 16 Pro,OS=18.5"` runs the iOS test suite; adjust the destination with `xcrun simctl list devices` when needed.
- `xcodebuild -list` enumerates available schemes to confirm configuration before CI or PR validation.

## Coding Style & Naming Conventions
- Use two-space indentation, brace-on-same-line, and keep trailing closures inline when concise.
- Prefer `public` only where the API surface demands it; default to `internal` otherwise.
- Conform types and files to Swift naming: `PascalCase` for types/protocols, `camelCase` for functions, properties, and test helpers.
- Maintain concurrency annotations introduced in the manifest (e.g., `.defaultIsolation(MainActor.self)`), and lean on `Task` + `async/await` instead of callbacks.

## Testing Guidelines
- Tests use the `Testing` package with `@Test` and `#expect`; co-locate fixtures or mocks under `Tests/MobileJoeTests/Mocks`.
- Name test functions by behavior (e.g., `filterFeatureRequests`) and scope them within structs matching the subject under test.
- Always run `xcodebuild test` before submitting; document flaky cases in the PR if simulator timing requires `Task.sleep` or similar workarounds.

## Commit & Pull Request Guidelines
- Follow the existing Git history: short, imperative present-tense subjects ("Reduce search debounce delay").
- Reference issue numbers in the subject or body when applicable and avoid batching unrelated changes.
- Pull requests should outline intent, list manual test steps, and include screenshots or screen recordings for UI-affecting work.
