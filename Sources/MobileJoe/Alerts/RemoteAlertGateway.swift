// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation
import OSLog

class RemoteAlertGateway: AlertGateway {
  static var shared = RemoteAlertGateway()

  private let client: APIClient
  internal var lastFetch: Date? = nil
  private let logger = Logger(category: "RemoteAlertGateway")

  init(client: APIClient = NetworkClient.shared) {
    self.client = client
  }

  var alerts = [Alert]()

  func load() async throws {
    guard isEligibleToLoad else {
      logger.debug("Joe says: Postpone loading.")
      return
    }
    let response = try await client.getAlerts()
    alerts = try Parser().parse(response)
    updateLastFetched()
  }

  private func updateLastFetched() {
    lastFetch = .now
  }

  private var isEligibleToLoad: Bool {
    if client.isDebugModeEnabled {
      return true
    }
    guard let lastFetch else { return true }
    return lastFetch.addingTimeInterval(15 * 60) < .now
  }
}

