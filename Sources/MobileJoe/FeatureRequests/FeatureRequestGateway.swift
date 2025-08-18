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
  func reload(filterBy statuses: [FeatureRequest.Status]?, sort: FeatureRequest.Sorting, search: String?) async throws
  func load(filterBy statuses: [FeatureRequest.Status]?, sort: FeatureRequest.Sorting, search: String?) async throws
  func vote(_ featureRequest: FeatureRequest) async throws
}

@MainActor
class RemoteFeatureRequestGateway: FeatureRequestGateway {
  static var shared = RemoteFeatureRequestGateway()

  private let parser: FeatureRequestParser
  private let client: NetworkClient
  private var pagination: Pagination

  init() {
    self.parser = FeatureRequestParser()
    self.client = NetworkClient.shared
    self.pagination = Pagination()
  }

  var featureRequests = [FeatureRequest]()

  func reload(filterBy statuses: [FeatureRequest.Status]?, sort: FeatureRequest.Sorting, search: String?) async throws {
    pagination = Pagination()
    featureRequests.removeAll()
    try await load(filterBy: statuses, sort: sort, search: search)
  }

  func load(filterBy statuses: [FeatureRequest.Status]?, sort sorting: FeatureRequest.Sorting, search: String?) async throws {
    guard let nextPage = pagination.nextPage else { return }
    let response = try await client.getFeatureRequests(filterBy: statuses, sort: sorting, search: search, page: nextPage)
    pagination = response.pagination
    let result: [FeatureRequest] = try parser.parse(response.data)
    featureRequests.append(contentsOf: result)
  }

  func vote(_ featureRequest: FeatureRequest) async throws {
    let response = try await client.postVoteFeatureRequests(featureRequestID: featureRequest.id)
    let votedFeatureRequest: FeatureRequest = try parser.parse(response)
    try featureRequests.replace(featureRequest, with: votedFeatureRequest)
  }
}

extension RemoteFeatureRequestGateway {
  enum Error: Swift.Error {
    case unknownFeatureRequest
  }
}
