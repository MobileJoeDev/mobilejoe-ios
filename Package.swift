// swift-tools-version: 6.2
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
      path: "Sources",
    ),
    .testTarget(
      name: "MobileJoeTests",
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
  settings.append(contentsOf: [
    .defaultIsolation(MainActor.self),
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    .enableUpcomingFeature("InferIsolatedConformances")
  ])
  target.swiftSettings = settings
}
