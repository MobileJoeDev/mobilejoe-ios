//
//  Copyright Bytekontor GmbH. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  RemoteFeatureRequestGatewayTests.swift
//
//  Created by Florian Mielke on 09.10.25.
//

import Foundation
import Testing
@testable import MobileJoe

struct RemoteFeatureRequestGatewayTests {
  let router: RouterMock
  let client: NetworkClient
  var gateway: RemoteFeatureRequestGateway

  init() {
    router = RouterMock()
    client = NetworkClient(
      router: router,
      debugMode: false,
      apiKey: "api-key",
      identity: Identity(externalID: "external-id")
    )
    gateway = RemoteFeatureRequestGateway(client: client)
  }

  @Test
  func `render PDF file`() {

  }


  @Test
  func `reload resets pagination and replaces results`() async throws {
    gateway.featureRequests = [FeatureRequest.fixture(isVoted: false, score: 1)]

    router.resultsQueue = [
      (
        try encodeFeatureRequests([
          FeatureRequest.fixture(isVoted: true, score: 10),
          FeatureRequest.fixture(isVoted: false, score: 5)
        ]),
        try makeResponse(
          path: "/v1/feature_requests",
          headers: [
            "current-page": "1",
            "total-pages": "3",
            "total-count": "2"
          ]
        )
      )
    ]

    try await gateway.reload(filterBy: [.planned], sort: .byScore, search: "Cloud")

    #expect(router.performCallCount == 1)

    guard let request = router.lastRequest else {
      Issue.record("Request not captured")
      return
    }
    guard let requestURL = request.url else {
      Issue.record("Request missing URL")
      return
    }
    guard let components = URLComponents(url: requestURL, resolvingAgainstBaseURL: false) else {
      Issue.record("Failed to build URL components")
      return
    }
    let queryItems = components.queryItems ?? []
    #expect(queryItems.contains(where: { $0.name == "sort" && $0.value == "score" }))
    #expect(queryItems.contains(where: { $0.name == "page" && $0.value == "1" }))
    #expect(queryItems.contains(where: { $0.name == "search" && $0.value == "Cloud" }))
    let statuses = queryItems
      .filter { $0.name == "statuses[]" }
      .compactMap(\.value)
    #expect(statuses == ["planned"])

    #expect(gateway.featureRequests.count == 2)
    #expect(gateway.featureRequests.first?.isVoted == true)
    #expect(gateway.featureRequests.last?.score == 5)
  }

  @Test
  func `load appends until pagination ends`() async throws {
    router.resultsQueue = [
      (
        try encodeFeatureRequests([
          FeatureRequest.fixture(isVoted: false, score: 3)
        ]),
        try makeResponse(
          path: "/v1/feature_requests",
          headers: [
            "current-page": "1",
            "total-pages": "2",
            "total-count": "2"
          ]
        )
      ),
      (
        try encodeFeatureRequests([
          FeatureRequest.fixture(isVoted: true, score: 7)
        ]),
        try makeResponse(
          path: "/v1/feature_requests",
          headers: [
            "current-page": "2",
            "total-pages": "2",
            "total-count": "2"
          ]
        )
      )
    ]

    try await gateway.load(filterBy: nil, sort: .byNewest, search: nil)
    #expect(gateway.featureRequests.count == 1)

    try await gateway.load(filterBy: nil, sort: .byNewest, search: nil)
    #expect(gateway.featureRequests.count == 2)

    try await gateway.load(filterBy: nil, sort: .byNewest, search: nil)
    #expect(router.performCallCount == 2)
    #expect(gateway.featureRequests.count == 2)
  }

  @Test
  func `vote replaces feature request`() async throws {
    let original = FeatureRequest.fixture(isVoted: false, score: 2)
    let updated = FeatureRequest(
      id: original.id,
      title: original.title,
      body: original.body,
      score: original.score + 1,
      status: original.status,
      createdAt: original.createdAt,
      updatedAt: original.updatedAt,
      isVoted: true
    )
    gateway.featureRequests = [original]

    router.nextResult = (
      try encodeFeatureRequest(updated),
      try makeResponse(path: "/v1/feature_requests/\(original.id)/vote")
    )

    try await gateway.vote(original)

    guard let request = router.lastRequest else {
      Issue.record("Request not captured")
      return
    }
    #expect(request.httpMethod == "POST")
    #expect(request.url?.path == "/v1/feature_requests/\(original.id)/vote")
    #expect(gateway.featureRequests.first == updated)
  }
}

private func encodeFeatureRequests(_ requests: [FeatureRequest]) throws -> Data {
  let encoder = JSONEncoder()
  encoder.dateEncodingStrategy = .formatted(.apiDateFormatter)
  return try encoder.encode(requests)
}

private func encodeFeatureRequest(_ request: FeatureRequest) throws -> Data {
  let encoder = JSONEncoder()
  encoder.dateEncodingStrategy = .formatted(.apiDateFormatter)
  return try encoder.encode(request)
}

private func makeResponse(path: String, headers: [String: String] = [:]) throws -> HTTPURLResponse {
  guard let url = URL(string: "https://mbj-api.com\(path)") else {
    throw RemoteFeatureRequestTestError.invalidURL
  }
  guard let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: headers) else {
    throw RemoteFeatureRequestTestError.invalidResponse
  }
  return response
}

enum RemoteFeatureRequestTestError: Error {
  case invalidURL
  case invalidResponse
}
