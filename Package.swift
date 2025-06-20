// swift-tools-version: 6.0
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
      path: "Sources"
    ),
    .testTarget(
      name: "MobileJoeTests",
      dependencies: ["MobileJoe"]
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
