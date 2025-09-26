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

public protocol AlertGateway {
  var alerts: [Alert] { get }
  func load() async throws
}

class RemoteAlertGateway: AlertGateway {
  static var shared = RemoteAlertGateway()

  private let client: NetworkClient

  init() {
    self.client = NetworkClient.shared
  }

  var alerts = [Alert]()

  func load() async throws {
    let response = try await client.getAlerts()
    alerts = try Parser().parse(response)
  }
}

extension RemoteAlertGateway {
  enum Error: Swift.Error {
    case unknownAlert
  }
}
