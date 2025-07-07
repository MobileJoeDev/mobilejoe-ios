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
  var featureRequests: [FeatureRequest] { get }
  func load(filterBy statuses: [FeatureRequest.Status]?, sort: FeatureRequest.Sorting) async throws
  func vote(_ featureRequest: FeatureRequest) async throws
}

@MainActor
class RemoteFeatureRequestGateway: FeatureRequestGateway {
  static var shared = RemoteFeatureRequestGateway()

  private let parser: FeatureRequestParser
  private let client: NetworkClient

  init() {
    self.parser = FeatureRequestParser()
    self.client = NetworkClient.shared
  }

  var featureRequests = [FeatureRequest]()

  func load(filterBy statuses: [FeatureRequest.Status]?, sort sorting: FeatureRequest.Sorting) async throws {
    let response = try await client.getFeatureRequests(filterBy: statuses, sort: sorting)
    let result: [FeatureRequest] = try parser.parse(response)
    featureRequests = result
  }

  func vote(_ featureRequest: FeatureRequest) async throws {
    let response = try await client.postVoteFeatureRequests(featureRequestID: featureRequest.id)
    let votedFeatureRequest: FeatureRequest = try parser.parse(response)

    guard let index = featureRequests.firstIndex(of: featureRequest) else { throw Error.unknownFeatureRequest }
    featureRequests.remove(at: index)
    featureRequests.insert(votedFeatureRequest, at: index)
  }
}

extension RemoteFeatureRequestGateway {
  enum Error: Swift.Error {
    case unknownFeatureRequest
  }
}
