# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MobileJoe is a Swift Package Manager-based iOS SDK for feature request management. The project consists of two main modules:
- `MobileJoe`: Core SDK with networking, identity management, and feature request handling
- `MobileJoeUI`: SwiftUI views and components for displaying feature requests

## Build System & Commands

This project uses Swift Package Manager (SPM) with iOS 17+ deployment target and Swift 6.0 toolchain.

### Common Commands
```bash
# Build the package
swift build

# Run tests (iOS-only package - use xcodebuild for iOS simulator)
xcodebuild test -scheme MobileJoe-Package -sdk iphonesimulator18.5 -destination "OS=18.5,name=iPhone 16 Pro"

# Clean build artifacts
swift package clean

# Reset entire build directory
swift package reset

# Show package dependencies
swift package show-dependencies

# Update dependencies
swift package update
```

### Xcode Integration
The package can be integrated into Xcode projects via Swift Package Manager using the repository URL.

## Architecture

### Core Components

**MobileJoe (Core SDK)**
- `MobileJoe.swift`: Main SDK entry point with `configure()` and `identify()` methods
- `NetworkClient.swift`: HTTP client for API communication with https://mbj-api.com
- `IdentityManager.swift`: Handles user identity creation and management
- `FeatureRequests.swift`: Observable class managing feature request state and sorting

**MobileJoeUI (SwiftUI Views)**
- `FeatureRequestListView.swift`: Main list view with sorting, voting, and refresh functionality
- Uses `@Observable` macro for state management
- Includes preview support with fixture data

### Key Patterns

**Dependency Injection**: Gateway pattern used for networking and identity storage
- `FeatureRequestGateway` protocol with `RemoteFeatureRequestGateway` implementation
- `IdentityGateway` protocol with `FileBasedIdentityGateway` implementation

**Actor Isolation**: All main components are `@MainActor` isolated for UI thread safety

**Observable Architecture**: Uses Swift's `@Observable` macro for reactive state management

**Configuration**: SDK requires API key configuration before use via `MobileJoe.configure()`

## File Structure

```
Sources/MobileJoe/           # Core SDK
├── MobileJoe.swift         # Main SDK interface
├── Networking/             # HTTP client and routing
├── Identity/               # User identity management
├── FeatureRequests/        # Feature request domain logic
├── Helper/                 # Utility extensions
└── Error/                  # Custom error types

MobileJoeUI/                # SwiftUI components
├── FeatureRequests/        # Feature request views
├── Foundation/             # Base UI components
├── Helper/                 # UI utilities
└── Resources/              # Assets and localizations

Tests/MobileJoeTests/       # Unit tests
```

## Testing

Tests are located in `Tests/MobileJoeTests/` and use standard XCTest framework. Mock implementations are provided in the `Mocks/` directory for gateway dependencies.

## Localization

The UI components support localization through `Localizable.xcstrings` with module-scoped string resources using `bundle: .module`.