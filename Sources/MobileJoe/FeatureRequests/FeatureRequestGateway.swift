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

public protocol FeatureRequestGateway {
  var featureRequests: [FeatureRequest] { get }
  func reload(filterBy statuses: [FeatureRequest.Status]?, sort sorting: FeatureRequest.Sorting, search: String?) async throws
  func load(filterBy statuses: [FeatureRequest.Status]?, sort sorting: FeatureRequest.Sorting, search: String?) async throws
  func vote(_ featureRequest: FeatureRequest) async throws
}

class RemoteFeatureRequestGateway: FeatureRequestGateway {
  static var shared = RemoteFeatureRequestGateway()

  private let client: NetworkClient
  private var pagination: Pagination

  init(client: NetworkClient = NetworkClient.shared, pagination: Pagination = Pagination()) {
    self.client = client
    self.pagination = pagination
  }

  var featureRequests = [FeatureRequest]()

  func reload(filterBy statuses: [FeatureRequest.Status]?, sort sorting: FeatureRequest.Sorting, search: String?) async throws {
    pagination = Pagination()
    featureRequests.removeAll()
    guard let nextPage = pagination.nextPage else { return }
    let response = try await client.getFeatureRequests(filterBy: statuses, sort: sorting, search: search, page: nextPage)
    pagination = response.pagination
    let result: [FeatureRequest] = try Parser().parse(response.data)
    featureRequests = result
  }

  func load(filterBy statuses: [FeatureRequest.Status]?, sort sorting: FeatureRequest.Sorting, search: String?) async throws {
    guard let nextPage = pagination.nextPage else { return }
    let response = try await client.getFeatureRequests(filterBy: statuses, sort: sorting, search: search, page: nextPage)
    pagination = response.pagination
    let result: [FeatureRequest] = try Parser().parse(response.data)
    featureRequests.append(contentsOf: result)
  }

  func vote(_ featureRequest: FeatureRequest) async throws {
    let response = try await client.postVoteFeatureRequests(featureRequestID: featureRequest.id)
    let votedFeatureRequest: FeatureRequest = try Parser().parse(response)
    try featureRequests.replace(featureRequest, with: votedFeatureRequest)
  }
}

extension RemoteFeatureRequestGateway {
  enum Error: Swift.Error {
    case unknownFeatureRequest
  }
}
