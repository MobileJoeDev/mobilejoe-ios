//
//  Copyright Bytekontor GmbH. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  Alerts.swift
//
//  Created by Florian Mielke on 25.09.25.
//

import Foundation
import Observation

@Observable
public class Alerts {
  public var all = [Alert]()

  public var isEmpty: Bool {
    all.isEmpty
  }

  private let gateway: AlertGateway

  public init(gateway: AlertGateway? = nil) {
    self.gateway = gateway ?? RemoteAlertGateway.shared
  }

  public func load() async throws {
    try await gateway.load()
    all = gateway.alerts
  }
}
