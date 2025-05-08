//
//  Copyright Florian Mielke. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  FeatureRequestGateway.swift
//
//  Created by Florian Mielke on 08.05.25.
//

import Foundation

@MainActor
public protocol FeatureRequestGateway {
  func all() async throws -> [FeatureRequest]
  func load() async throws -> [FeatureRequest]
  func vote(_ featureRequest: FeatureRequest) async throws
}

@MainActor
class InMemoryFeatureRequestGateway: FeatureRequestGateway {
  static var shared = InMemoryFeatureRequestGateway()

  private var container: Set<FeatureRequest>
  private let parser: FeatureRequestParser
  private let client: NetworkClient

  init() {
    self.parser = FeatureRequestParser()
    self.client = NetworkClient.shared
    self.container = []
  }

  func all() async throws -> [FeatureRequest] {
    Array(container)
  }

  func load() async throws -> [FeatureRequest] {
    let response = try await client.getFeatureRequests()
    let result: [FeatureRequest] = try parser.parse(response)
    container = Set(result)
    return result
  }

  func vote(_ featureRequest: FeatureRequest) async throws {
    let response = try await client.postVoteFeatureRequests(featureRequestID: featureRequest.id)
    let result: FeatureRequest = try parser.parse(response)
    container.remove(result)
    container.insert(result)
  }
}
