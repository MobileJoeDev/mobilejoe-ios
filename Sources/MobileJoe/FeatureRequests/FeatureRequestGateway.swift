//
//  Copyright Bytekontor GmbH. All Rights Reserved.
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
  var all: [FeatureRequest] { get }
  func load(filterBy statuses: [FeatureRequest.Status]?, sort: FeatureRequest.Sorting) async throws
  func vote(_ featureRequest: FeatureRequest) async throws
}

@MainActor
class RemoteFeatureRequestGateway: FeatureRequestGateway {
  static var shared = RemoteFeatureRequestGateway()

  private var cache: Set<FeatureRequest>
  private let parser: FeatureRequestParser
  private let client: NetworkClient

  init() {
    self.parser = FeatureRequestParser()
    self.client = NetworkClient.shared
    self.cache = []
  }

  var all: [FeatureRequest] {
    Array(cache)
  }

  func load(filterBy statuses: [FeatureRequest.Status]?, sort sorting: FeatureRequest.Sorting) async throws {
    let response = try await client.getFeatureRequests(filterBy: statuses, sort: sorting)
    let result: [FeatureRequest] = try parser.parse(response)
    cache = Set(result)
  }

  func vote(_ featureRequest: FeatureRequest) async throws {
    let response = try await client.postVoteFeatureRequests(featureRequestID: featureRequest.id)
    let result: FeatureRequest = try parser.parse(response)
    cache.remove(result)
    cache.insert(result)
  }
}
