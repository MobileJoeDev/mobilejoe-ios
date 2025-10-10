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

struct NetworkClientTests {
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

  @Test func `get feature requests builds expected request`() async throws {
    guard let url = URL(string: "https://mbj-api.com/v1/feature_requests") else {
      Issue.record("Invalid feature requests URL")
      return
    }
    guard let response = HTTPURLResponse(
      url: url,
      statusCode: 200,
      httpVersion: nil,
      headerFields: [
        "current-page": "1",
        "total-pages": "2",
        "total-count": "4"
      ]
    ) else {
      Issue.record("Failed to build HTTP response")
      return
    }
    router.nextResult = (Data("[]".utf8), response)

    let statuses: [FeatureRequest.Status] = [.planned, .inProgress]
    _ = try await client.getFeatureRequests(
      filterBy: statuses,
      sort: .byScore,
      search: "Cloud Sync",
      page: 1
    )

    guard let request = router.lastRequest else {
      Issue.record("Request not captured")
      return
    }
    guard let requestURL = request.url else {
      Issue.record("Request missing URL")
      return
    }
    #expect(request.httpMethod == "GET")
    #expect(requestURL.path == "/v1/feature_requests")

    guard let components = URLComponents(url: requestURL, resolvingAgainstBaseURL: false) else {
      Issue.record("Failed to build URL components")
      return
    }
    guard let queryItems = components.queryItems else {
      Issue.record("Missing query items")
      return
    }
    let queryNames = queryItems.reduce(into: [String: [String]]()) { partialResult, item in
      partialResult[item.name, default: []].append(item.value ?? "")
    }

    #expect(queryNames["sort"] == ["score"])
    #expect(queryNames["page"] == ["1"])
    #expect(queryNames["search"] == ["Cloud Sync"])
    #expect(queryNames["statuses[]"] == statuses.map(\.rawValue))
  }

  @Test func `get feature requests sets expected headers`() async throws {
    guard let url = URL(string: "https://mbj-api.com/v1/feature_requests") else {
      Issue.record("Invalid feature requests URL")
      return
    }
    guard let response = HTTPURLResponse(
      url: url,
      statusCode: 200,
      httpVersion: nil,
      headerFields: [:]
    ) else {
      Issue.record("Failed to build HTTP response")
      return
    }
    router.nextResult = (Data("[]".utf8), response)

    _ = try await client.getFeatureRequests(
      filterBy: nil,
      sort: .byNewest,
      search: nil,
      page: 1
    )

    guard let headers = router.lastRequest?.allHTTPHeaderFields else {
      Issue.record("Missing headers")
      return
    }
    #expect(headers["Authorization"] == "Bearer api-key")
    #expect(headers["Content-Type"] == "application/json")
    #expect(headers["Framework-Version"] == SystemInfo.frameworkVersion)
    #expect(headers["Device-Version"] == SystemInfo.deviceVersion)
    #expect(headers["System-OS-Name"] == SystemInfo.systemOSName)
    #expect(headers["System-OS-Version"] == SystemInfo.systemOSVersion)
    #expect(headers["App-Version"] == SystemInfo.appVersion)
    #expect(headers["App-Build-Version"] == SystemInfo.buildVersion)
    #expect(headers["Language-Code"] == SystemInfo.languageCode)
    #expect(headers["Debug-Mode"] == "true")
    #expect(headers["Identity-Anonymous-ID"] == identity.anonymousID)
    #expect(headers["Identity-External-ID"] == identity.externalID)
  }

  @Test func `perform without configuration throws`() async {
    let router = RouterMock()
    let client = NetworkClient(router: router, debugMode: false, apiKey: "", identity: identity)

    let error = await #expect(throws: MobileJoeError.self) {
      try await client.getAlerts()
    }
    let isNotConfigured: Bool
    switch error {
    case .notConfigured:
      isNotConfigured = true
    default:
      isNotConfigured = false
    }
    #expect(isNotConfigured)
    #expect(router.performCallCount == 0)
  }

  @Test func `missing identity throws unknown identity`() async {
    let router = RouterMock()
    let client = NetworkClient(router: router, debugMode: false, apiKey: "api-key", identity: nil)
    guard let alertsURL = URL(string: "https://mbj-api.com/v1/alerts") else {
      Issue.record("Invalid alerts URL")
      return
    }
    guard let alertsResponse = HTTPURLResponse(
      url: alertsURL,
      statusCode: 200,
      httpVersion: nil,
      headerFields: [:]
    ) else {
      Issue.record("Failed to build HTTP response")
      return
    }
    router.nextResult = (Data("[]".utf8), alertsResponse)

    let error = await #expect(throws: MobileJoeError.self) {
      try await client.getAlerts()
    }
    let isUnknownIdentity: Bool
    switch error {
    case .unknownIdentity:
      isUnknownIdentity = true
    default:
      isUnknownIdentity = false
    }
    #expect(isUnknownIdentity)
  }

  @Test func `post vote feature requests targets vote endpoint`() async throws {
    guard let voteURL = URL(string: "https://mbj-api.com/v1/feature_requests/123/vote") else {
      Issue.record("Invalid vote URL")
      return
    }
    guard let voteResponse = HTTPURLResponse(
      url: voteURL,
      statusCode: 200,
      httpVersion: nil,
      headerFields: [:]
    ) else {
      Issue.record("Failed to build HTTP response")
      return
    }
    router.nextResult = (Data("{}".utf8), voteResponse)

    let data = try await client.postVoteFeatureRequests(featureRequestID: 123)
    #expect(data == Data("{}".utf8))

    guard let request = router.lastRequest else {
      Issue.record("Request not captured")
      return
    }
    #expect(request.httpMethod == "POST")
    #expect(request.url?.path == "/v1/feature_requests/123/vote")
  }
}
