//
//  Copyright Bytekontor GmbH. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  NetworkClientTests.swift
//
//  Created by Florian Mielke on 09.10.25.
//

import Foundation
import Testing
@testable import MobileJoe

@Suite("Network Client")
struct NetworkClientTests {

  @Suite("Feature Request Endpoints")
  struct FeatureRequestEndpoints {
    let router: RouterMock
    let identity: Identity
    let client: NetworkClient

    init() {
      router = RouterMock()
      identity = Identity(externalID: "external-id")
      client = NetworkClient(
        router: router,
        debugMode: true,
        apiKey: "api-key",
        identity: identity
      )
    }

    @Test func `builds expected request with query parameters`() async throws {
      router.nextResult = (
        Data("[]".utf8),
        try makeResponse(path: "/v1/feature_requests", headers: [
          "current-page": "1",
          "total-pages": "2",
          "total-count": "4"
        ])
      )

      let statuses: [FeatureRequest.Status] = [.planned, .inProgress]
      _ = try await client.getFeatureRequests(
        filterBy: statuses,
        sort: .byScore,
        search: "Cloud Sync",
        page: 1
      )

      let request = try #require(router.lastRequest)
      let requestURL = try #require(request.url)
      #expect(request.httpMethod == "GET")
      #expect(requestURL.path == "/v1/feature_requests")

      let components = try #require(URLComponents(url: requestURL, resolvingAgainstBaseURL: false))
      let queryItems = try #require(components.queryItems)
      let queryNames = queryItems.reduce(into: [String: [String]]()) { partialResult, item in
        partialResult[item.name, default: []].append(item.value ?? "")
      }

      #expect(queryNames["sort"] == ["score"])
      #expect(queryNames["page"] == ["1"])
      #expect(queryNames["search"] == ["Cloud Sync"])
      #expect(queryNames["statuses[]"] == statuses.map(\.rawValue))
    }

    @Test func `post vote targets vote endpoint`() async throws {
      router.nextResult = (Data("{}".utf8), try makeResponse(path: "/v1/feature_requests/123/vote"))

      let data = try await client.postVoteFeatureRequests(featureRequestID: 123)
      #expect(data == Data("{}".utf8))

      let request = try #require(router.lastRequest)
      #expect(request.httpMethod == "POST")
      #expect(request.url?.path == "/v1/feature_requests/123/vote")
    }
  }

  @Suite("Configuration and Error Handling")
  struct ConfigurationAndErrors {
    let router: RouterMock
    let identity: Identity
    let client: NetworkClient

    init() {
      router = RouterMock()
      identity = Identity(externalID: "external-id")
      client = NetworkClient(
        router: router,
        debugMode: true,
        apiKey: "api-key",
        identity: identity
      )
    }

    @Test func `sets expected headers on requests`() async throws {
      router.nextResult = (Data("[]".utf8), try makeResponse(path: "/v1/feature_requests"))

      _ = try await client.getFeatureRequests(
        filterBy: nil,
        sort: .byNewest,
        search: nil,
        page: 1
      )

      let headers = try #require(router.lastRequest?.allHTTPHeaderFields)
      #expect(headers["Authorization"] == "Bearer api-key")
      #expect(headers["Content-Type"] == "application/json")
      #expect(headers["Framework-Version"] == SystemInfo.frameworkVersion)
      #expect(headers["Device-Model"] == SystemInfo.deviceModel)
      #expect(headers["OS-Name"] == SystemInfo.osName)
      #expect(headers["OS-Version"] == SystemInfo.osVersion)
      #expect(headers["App-Version"] == SystemInfo.appVersion)
      #expect(headers["App-Build-Version"] == SystemInfo.appBuildVersion)
      #expect(headers["Language-Code"] == SystemInfo.languageCode)
      #expect(headers["Debug-Mode"] == "true")
      #expect(headers["Identity-Anonymous-ID"] == identity.anonymousID)
      #expect(headers["Identity-External-ID"] == identity.externalID)
      #expect(headers["Identity-Device-ID"] == identity.deviceID)
    }

    @Test func `throws error when not configured`() async {
      let router = RouterMock()
      let client = NetworkClient(router: router, debugMode: false, apiKey: "", identity: identity)

      let error = await #expect(throws: MobileJoeError.self) {
        try await client.getAlerts()
      }
      guard case .notConfigured = error else {
        Issue.record("Expected .notConfigured error, got \(error)")
        return
      }
      #expect(router.performCallCount == 0)
    }

    @Test func `throws error when identity is missing`() async throws {
      let router = RouterMock()
      let client = NetworkClient(router: router, debugMode: false, apiKey: "api-key", identity: nil)
      router.nextResult = (Data("[]".utf8), try makeResponse(path: "/v1/alerts"))

      let error = await #expect(throws: MobileJoeError.self) {
        try await client.getAlerts()
      }
      guard case .unknownIdentity = error else {
        Issue.record("Expected .unknownIdentity error, got \(error)")
        return
      }
    }
  }

  @Suite("HTTP Error Responses")
  struct HTTPErrorResponses {
    let router: RouterMock
    let identity: Identity
    let client: NetworkClient

    init() {
      router = RouterMock()
      identity = Identity(externalID: "external-id")
      client = NetworkClient(
        router: router,
        debugMode: false,
        apiKey: "api-key",
        identity: identity
      )
    }

    @Test(arguments: [400, 401, 403, 404, 429, 500, 503])
    func `handles HTTP error status codes`(statusCode: Int) async throws {
      router.nextResult = (Data("{}".utf8), try makeResponse(path: "/v1/feature_requests", statusCode: statusCode))

      let error = await #expect(throws: MobileJoeError.self) {
        _ = try await client.getFeatureRequests(filterBy: nil, sort: .byNewest, search: nil, page: 1)
      }

      guard case .notOkURLResponse = error else {
        Issue.record("Expected .notOkURLResponse error, got \(error)")
        return
      }
    }

    @Test func `returns raw data without decoding`() async throws {
      // NetworkClient doesn't decode JSON, it just returns raw data
      let invalidJSON = Data("invalid json{".utf8)
      router.nextResult = (invalidJSON, try makeResponse(path: "/v1/feature_requests"))

      let (data, _) = try await client.getFeatureRequests(filterBy: nil, sort: .byNewest, search: nil, page: 1)
      #expect(data == invalidJSON)
    }

    @Test func `handles empty response body`() async throws {
      router.nextResult = (Data(), try makeResponse(path: "/v1/feature_requests"))

      let (data, _) = try await client.getFeatureRequests(filterBy: nil, sort: .byNewest, search: nil, page: 1)
      #expect(data.isEmpty)
    }
  }
}

// MARK: - Helpers
extension NetworkClientTests.FeatureRequestEndpoints {
  private func makeResponse(path: String, statusCode: Int = 200, headers: [String: String] = [:]) throws -> HTTPURLResponse {
    let url = try #require(URL(string: "https://mbj-api.com\(path)"))
    return try #require(HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: headers))
  }
}

extension NetworkClientTests.ConfigurationAndErrors {
  private func makeResponse(path: String, statusCode: Int = 200, headers: [String: String] = [:]) throws -> HTTPURLResponse {
    let url = try #require(URL(string: "https://mbj-api.com\(path)"))
    return try #require(HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: headers))
  }
}

extension NetworkClientTests.HTTPErrorResponses {
  private func makeResponse(path: String, statusCode: Int = 200, headers: [String: String] = [:]) throws -> HTTPURLResponse {
    let url = try #require(URL(string: "https://mbj-api.com\(path)"))
    return try #require(HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: headers))
  }
}
