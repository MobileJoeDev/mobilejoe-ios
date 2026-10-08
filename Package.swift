// swift-tools-version: 6.2
// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "MobileJoe",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(
      name: "MobileJoe",
      targets: ["MobileJoe"]
    ),
    .library(
      name: "MobileJoeUI",
      targets: ["MobileJoeUI"]
    ),
  ],
  targets: [
    .target(
      name: "MobileJoe",
      dependencies: ["MobileJoeResources"],
      path: "Sources/MobileJoe",
      resources: [
        .process("PrivacyInfo.xcprivacy")
      ],
    ),
    // SwiftPM 6.2.3 generates MainActor-isolated Bundle.module in MainActor targets.
    // Keep translations in a nonisolated target so LocalizedError can access them.
    // Retain this workaround while supporting affected toolchains:
    // https://github.com/swiftlang/swift-package-manager/issues/9656
    .target(
      name: "MobileJoeResources",
      resources: [.process("Resources")]
    ),
    .testTarget(
      name: "MobileJoeTests",
      dependencies: ["MobileJoe"],
    ),
    .testTarget(
      name: "MobileJoeAPITests",
      dependencies: ["MobileJoe"],
    ),
    .target(
      name: "MobileJoeUI",
      dependencies: ["MobileJoe"],
      path: "MobileJoeUI",
      resources: [
        .process("Resources")
      ]
    ),
  ]
)

for target in package.targets {
  var settings = target.swiftSettings ?? []
  // SwiftUI views inherit @MainActor; their generated string symbols need a
  // nonisolated Bundle.module.
  if target.name != "MobileJoeUI" && target.name != "MobileJoeResources" {
    settings.append(.defaultIsolation(MainActor.self))
  }
  settings.append(contentsOf: [
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    .enableUpcomingFeature("InferIsolatedConformances")
  ])
  target.swiftSettings = settings
}
