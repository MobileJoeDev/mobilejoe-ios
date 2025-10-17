//
//  Copyright Bytekontor GmbH. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  AlertGateway.swift
//
//  Created by Florian Mielke on 26.09.25.
//

import Foundation
import OSLog

public protocol AlertGateway {
  var alerts: [Alert] { get }
  func load() async throws
}

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
      logger.debug("Postpone loading.")
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
    guard let lastFetch else { return true }
    return lastFetch.addingTimeInterval(15 * 60) < .now
  }
}

extension RemoteAlertGateway {
  enum Error: Swift.Error {
    case unknownAlert
  }
}
