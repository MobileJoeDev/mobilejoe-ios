// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation

class InMemoryAlertGateway: AlertGateway {
  var alerts: [Alert]
  private let seedData: [Alert]
  private var loadError: Swift.Error?

  init(seedData: [Alert] = [], loadError: Swift.Error? = nil) {
    self.seedData = seedData
    self.alerts = seedData
    self.loadError = loadError
  }

  func load() async throws {
    if let loadError { throw loadError }
    alerts = seedData
  }
}

// MARK: - Seed Data

extension InMemoryAlertGateway {
  static let seed = InMemoryAlertGateway(seedData: InMemoryAlertGateway.seedData)

  private static var seedData: [Alert] {
    [
      Alert(
        id: 1,
        title: "Critical error.",
        message: "Please update version.",
        kind: .error,
        occurredAt: .distantPast,
        createdAt: .distantPast,
        updatedAt: .distantPast
      ),
      Alert(
        id: 2,
        title: "Please be patient and stay tuned for further updates. We're working hard.",
        message: nil,
        kind: .error,
        occurredAt: .distantPast,
        createdAt: .distantPast,
        updatedAt: .distantPast
      ),
      Alert(
        id: 3,
        title: "Please be patient and stay tuned for further updates. We're working hard.",
        message: "Our developer spilled coffee on the keyboard again. We've switched to decaf and are working on a fix.",
        kind: .warning,
        occurredAt: .distantPast,
        createdAt: .distantPast,
        updatedAt: .distantPast
      )
    ]
  }

  public static var singleAlert: [Alert] {
    [
      Alert(
        id: 1,
        title: "Please be patient and stay tuned for further updates. We're working hard.",
        message: "Please update version.",
        kind: .warning,
        occurredAt: .distantPast,
        createdAt: .distantPast,
        updatedAt: .distantPast
      )
    ]
  }
}
