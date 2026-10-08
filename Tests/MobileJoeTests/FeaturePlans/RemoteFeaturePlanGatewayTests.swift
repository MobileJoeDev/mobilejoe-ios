// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation
import Testing
@testable import MobileJoe

@Suite("Remote Feature Plan Gateway")
struct RemoteFeaturePlanGatewayTests {

  @Suite("Pagination and Loading")
  struct PaginationAndLoading {
    let router: RouterMock
    let client: NetworkClient
    var gateway: RemoteFeaturePlanGateway

    init() {
      router = RouterMock()
      client = NetworkClient(
        router: router,
        isDebugMode: false,
        apiKey: "api-key",
        identityManager: IdentityManager(gateway: IdentityGatewayMock(), identity: Identity(externalID: "external-id"))
      )
      gateway = RemoteFeaturePlanGateway(client: client)
    }

    @Test
    func `reload resets pagination and replaces results`() async throws {
    gateway.featurePlans = [FeaturePlan.fixture(isVoted: false, score: 1)]

    router.resultsQueue = [
      (
        try encodeFeaturePlans([
          FeaturePlan.fixture(isVoted: true, score: 10),
          FeaturePlan.fixture(isVoted: false, score: 5)
        ]),
        try makeResponse(
          path: "/v1/feature_plans",
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

    let request = try #require(router.lastRequest)
    let requestURL = try #require(request.url)
    let components = try #require(URLComponents(url: requestURL, resolvingAgainstBaseURL: false))
    let queryItems = components.queryItems ?? []
    #expect(queryItems.contains(where: { $0.name == "sort" && $0.value == "score" }))
    #expect(queryItems.contains(where: { $0.name == "page" && $0.value == "1" }))
    #expect(queryItems.contains(where: { $0.name == "search" && $0.value == "Cloud" }))
    let statuses = queryItems
      .filter { $0.name == "statuses[]" }
      .compactMap(\.value)
    #expect(statuses == ["planned"])

    #expect(gateway.featurePlans.count == 2)
    #expect(gateway.featurePlans.first?.isVoted == true)
    #expect(gateway.featurePlans.last?.score == 5)
  }

    @Test
    func `load appends until pagination ends`() async throws {
    router.resultsQueue = [
      (
        try encodeFeaturePlans([
          FeaturePlan.fixture(isVoted: false, score: 3)
        ]),
        try makeResponse(
          path: "/v1/feature_plans",
          headers: [
            "current-page": "1",
            "total-pages": "2",
            "total-count": "2"
          ]
        )
      ),
      (
        try encodeFeaturePlans([
          FeaturePlan.fixture(isVoted: true, score: 7)
        ]),
        try makeResponse(
          path: "/v1/feature_plans",
          headers: [
            "current-page": "2",
            "total-pages": "2",
            "total-count": "2"
          ]
        )
      )
    ]

    try await gateway.load(filterBy: nil, sort: .byNewest, search: nil)
    #expect(gateway.featurePlans.count == 1)

    try await gateway.load(filterBy: nil, sort: .byNewest, search: nil)
    #expect(gateway.featurePlans.count == 2)

    try await gateway.load(filterBy: nil, sort: .byNewest, search: nil)
    #expect(router.performCallCount == 2)
    #expect(gateway.featurePlans.count == 2)
    }
  }

  @Suite("Fetch Single Feature Plan")
  struct FetchSingle {
    let router: RouterMock
    let client: NetworkClient
    var gateway: RemoteFeaturePlanGateway

    init() {
      router = RouterMock()
      client = NetworkClient(
        router: router,
        isDebugMode: false,
        apiKey: "api-key",
        identityManager: IdentityManager(gateway: IdentityGatewayMock(), identity: Identity(externalID: "external-id"))
      )
      gateway = RemoteFeaturePlanGateway(client: client)
    }

    @Test
    func `fetches single feature plan by id`() async throws {
      let expected = FeaturePlan.fixture(isVoted: true, score: 42)

      router.nextResult = (
        try encodeFeaturePlan(expected),
        try makeResponse(path: "/v1/feature_plans/\(expected.id)")
      )

      let result = try await gateway.featurePlan(id: expected.id)

      let request = try #require(router.lastRequest)
      #expect(request.httpMethod == "GET")
      #expect(request.url?.path == "/v1/feature_plans/\(expected.id)")
      #expect(result.id == expected.id)
      #expect(result.score == expected.score)
      #expect(result.isVoted == expected.isVoted)
    }

    @Test
    func `throws unknownFeaturePlan error for 404 response`() async throws {
      router.nextResult = (
        Data(),
        try makeResponse(path: "/v1/feature_plans/999", statusCode: 404)
      )

      await #expect(throws: FeaturePlanGatewayError.unknownFeaturePlan) {
        try await gateway.featurePlan(id: 999)
      }
    }
  }

  @Suite("Voting")
  struct Voting {
    let router: RouterMock
    let client: NetworkClient
    var gateway: RemoteFeaturePlanGateway

    init() {
      router = RouterMock()
      client = NetworkClient(
        router: router,
        isDebugMode: false,
        apiKey: "api-key",
        identityManager: IdentityManager(gateway: IdentityGatewayMock(), identity: Identity(externalID: "external-id"))
      )
      gateway = RemoteFeaturePlanGateway(client: client)
    }

    @Test
    func `vote replaces feature plan`() async throws {
    let original = FeaturePlan.fixture(isVoted: false, score: 2)
    let updated = FeaturePlan(
      id: original.id,
      title: original.title,
      body: original.body,
      score: original.score + 1,
      status: original.status,
      createdAt: original.createdAt,
      updatedAt: original.updatedAt,
      isVoted: true
    )
    gateway.featurePlans = [original]

    router.nextResult = (
      try encodeFeaturePlan(updated),
      try makeResponse(path: "/v1/feature_plans/\(original.id)/vote")
    )

    try await gateway.vote(original)

    let request = try #require(router.lastRequest)
    #expect(request.httpMethod == "POST")
    #expect(request.url?.path == "/v1/feature_plans/\(original.id)/vote")
    #expect(gateway.featurePlans.first == updated)
    }
  }
}

// MARK: - Helpers
private func encodeFeaturePlans(_ featurePlans: [FeaturePlan]) throws -> Data {
  let encoder = JSONEncoder()
  encoder.dateEncodingStrategy = .formatted(.apiDateFormatter)
  return try encoder.encode(featurePlans)
}

private func encodeFeaturePlan(_ featurePlan: FeaturePlan) throws -> Data {
  let encoder = JSONEncoder()
  encoder.dateEncodingStrategy = .formatted(.apiDateFormatter)
  return try encoder.encode(featurePlan)
}

private func makeResponse(path: String, statusCode: Int = 200, headers: [String: String] = [:]) throws -> HTTPURLResponse {
  guard let url = URL(string: "https://mbj-api.com\(path)") else {
    throw RemoteFeaturePlanTestError.invalidURL
  }
  guard let response = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: headers) else {
    throw RemoteFeaturePlanTestError.invalidResponse
  }
  return response
}

private enum RemoteFeaturePlanTestError: Error {
  case invalidURL
  case invalidResponse
}
