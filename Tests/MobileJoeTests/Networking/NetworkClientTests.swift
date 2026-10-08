// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation
import Testing
@testable import MobileJoe

@Suite("Network Client")
struct NetworkClientTests {

  @Suite("Feature Plan Endpoints")
  struct FeaturePlanEndpoints {
    let router: RouterMock
    let identity: Identity
    let client: NetworkClient

    init() {
      router = RouterMock()
      identity = Identity(externalID: "external-id")
      client = NetworkClient(
        router: router,
        isDebugMode: true,
        apiKey: "api-key",
        identityManager: IdentityManager(gateway: IdentityGatewayMock(), identity: identity)
      )
    }

    @Test func `builds expected request with query parameters`() async throws {
      router.nextResult = (
        Data("[]".utf8),
        try makeResponse(path: "/v1/feature_plans", headers: [
          "current-page": "1",
          "total-pages": "2",
          "total-count": "4"
        ])
      )

      let statuses: [FeaturePlan.Status] = [.planned, .inProgress]
      _ = try await client.getFeaturePlans(
        filterBy: statuses,
        sort: .byScore,
        search: "Cloud Sync",
        page: 1
      )

      let request = try #require(router.lastRequest)
      let requestURL = try #require(request.url)
      #expect(request.httpMethod == "GET")
      #expect(requestURL.path == "/v1/feature_plans")

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
      router.nextResult = (Data("{}".utf8), try makeResponse(path: "/v1/feature_plans/123/vote"))

      let data = try await client.postFeaturePlanVote(featurePlanID: 123)
      #expect(data == Data("{}".utf8))

      let request = try #require(router.lastRequest)
      #expect(request.httpMethod == "POST")
      #expect(request.url?.path == "/v1/feature_plans/123/vote")
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
        isDebugMode: true,
        apiKey: "api-key",
        identityManager: IdentityManager(gateway: IdentityGatewayMock(), identity: identity)
      )
    }

    @Test func repeatedConfigurationPreservesSettingsAndLoggedOutIdentity() async throws {
      router.nextResult = (Data(), try makeResponse(path: "/v1/identify"))
      try await client.configure(withAPIKey: "first-key", externalID: "first-account", debugMode: true)
      try await client.logout()

      try await client.configure(withAPIKey: "second-key", externalID: "second-account", debugMode: false)
      #expect(router.performCallCount == 1)

      _ = try await client.getAlerts()
      #expect(router.lastRequest?.value(forHTTPHeaderField: "Authorization") == "Bearer first-key")
      #expect(router.lastRequest?.value(forHTTPHeaderField: "Debug-Mode") == "true")
      #expect(router.lastRequest?.value(forHTTPHeaderField: "Identity-External-ID") == nil)
    }

    @Test func failedConfigurationCanBeRetried() async throws {
      router.nextError = URLError(.notConnectedToInternet)
      await #expect(throws: URLError(.notConnectedToInternet)) {
        try await client.configure(withAPIKey: "api-key", externalID: "account-id")
      }

      router.nextResult = (Data(), try makeResponse(path: "/v1/identify"))
      try await client.configure(withAPIKey: "api-key", externalID: "account-id")
      try await client.configure(withAPIKey: "api-key", externalID: "account-id")
      #expect(router.performCallCount == 2)
    }

    @Test func concurrentConfigurationSendsOneIdentifyRequest() async throws {
      router.nextResult = (Data(), try makeResponse(path: "/v1/identify"))
      async let first: Void = client.configure(withAPIKey: "api-key", externalID: "account-id")
      async let second: Void = client.configure(withAPIKey: "api-key", externalID: "account-id")
      _ = try await (first, second)
      #expect(router.performCallCount == 1)
    }

    @Test func `sets expected headers on requests`() async throws {
      router.nextResult = (Data("[]".utf8), try makeResponse(path: "/v1/feature_plans"))

      _ = try await client.getFeaturePlans(
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
      #expect(headers["Preferred-Languages"] == SystemInfo.preferredLanguages)
      #expect(headers["Language-Code"] == nil)
      #expect(headers["Debug-Mode"] == "true")
      #expect(headers["Identity-Anonymous-ID"] == identity.anonymousID)
      #expect(headers["Identity-External-ID"] == identity.externalID)
      #expect(headers["Identity-Device-ID"] == identity.deviceID)
    }

    @Test func `throws error when not configured`() async {
      let router = RouterMock()
      let client = NetworkClient(router: router, isDebugMode: false, apiKey: "", identityManager: IdentityManager(gateway: IdentityGatewayMock(), identity: identity))

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
      let client = NetworkClient(router: router, isDebugMode: false, apiKey: "api-key", identityManager: IdentityManager(gateway: IdentityGatewayMock()))
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
        isDebugMode: false,
        apiKey: "api-key",
        identityManager: IdentityManager(gateway: IdentityGatewayMock(), identity: identity)
      )
    }

    @Test(arguments: [400, 401, 403, 404, 429, 500, 503])
    func `handles HTTP error status codes`(statusCode: Int) async throws {
      router.nextResult = (Data("{}".utf8), try makeResponse(path: "/v1/feature_plans", statusCode: statusCode))

      let error = await #expect(throws: MobileJoeError.self) {
        _ = try await client.getFeaturePlans(filterBy: nil, sort: .byNewest, search: nil, page: 1)
      }

      guard case let .httpFailure(actualStatusCode, method, path) = error else {
        Issue.record("Expected .httpFailure error, got \(error)")
        return
      }
      #expect(actualStatusCode == statusCode)
      #expect(method == "GET")
      #expect(path == "/v1/feature_plans")
    }

    @Test func `returns raw data without decoding`() async throws {
      // NetworkClient doesn't decode JSON, it just returns raw data
      let invalidJSON = Data("invalid json{".utf8)
      router.nextResult = (invalidJSON, try makeResponse(path: "/v1/feature_plans"))

      let (data, _) = try await client.getFeaturePlans(filterBy: nil, sort: .byNewest, search: nil, page: 1)
      #expect(data == invalidJSON)
    }

    @Test func `handles empty response body`() async throws {
      router.nextResult = (Data(), try makeResponse(path: "/v1/feature_plans"))

      let (data, _) = try await client.getFeaturePlans(filterBy: nil, sort: .byNewest, search: nil, page: 1)
      #expect(data.isEmpty)
    }
  }

  @Suite("Logout")
  struct Logout {
    let router = RouterMock()
    let gateway = IdentityGatewayMock()
    let oldIdentity = Identity(externalID: "account-id")
    let identityManager: IdentityManager
    let client: NetworkClient

    init() {
      gateway.findReturnValue = oldIdentity
      identityManager = IdentityManager(gateway: gateway, identity: oldIdentity)
      client = NetworkClient(
        router: router,
        isDebugMode: true,
        apiKey: "api-key",
        identityManager: identityManager
      )
    }

    @Test func requestsAfterLogoutUseNewAnonymousIdentity() async throws {
      try await client.logout()

      #expect(router.performCallCount == 0)
      let identity = try #require(gateway.findReturnValue)
      #expect(identity.anonymousID != oldIdentity.anonymousID)
      #expect(identity.deviceID != oldIdentity.deviceID)
      #expect(identity.externalID == nil)

      try prepareResponse()
      _ = try await client.getAlerts()

      let request = try #require(router.lastRequest)
      #expect(request.value(forHTTPHeaderField: "Identity-Anonymous-ID") == identity.anonymousID)
      #expect(request.value(forHTTPHeaderField: "Identity-Device-ID") == identity.deviceID)
      #expect(request.value(forHTTPHeaderField: "Identity-External-ID") == nil)
      #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer api-key")
      #expect(request.value(forHTTPHeaderField: "Debug-Mode") == "true")
    }

    @Test func repeatedLogoutRotatesAnonymousIdentity() async throws {
      try await client.logout()
      let firstIdentity = try #require(gateway.findReturnValue)

      try await client.logout()
      let secondIdentity = try #require(gateway.findReturnValue)

      #expect(secondIdentity.anonymousID != firstIdentity.anonymousID)
      #expect(secondIdentity.deviceID != firstIdentity.deviceID)
      #expect(secondIdentity.externalID == nil)
      #expect(router.performCallCount == 0)
    }

    @Test(arguments: ["account-id", "another-account"])
    func loginAfterLogoutKeepsNewLocalIDs(accountID: String) async throws {
      try await client.logout()
      let anonymousIdentity = try #require(gateway.findReturnValue)

      try prepareResponse()
      try await client.identify(externalID: accountID)

      let request = try #require(router.lastRequest)
      #expect(request.httpMethod == "POST")
      #expect(request.url?.path == "/v1/identify")
      #expect(request.value(forHTTPHeaderField: "Identity-Anonymous-ID") == anonymousIdentity.anonymousID)
      #expect(request.value(forHTTPHeaderField: "Identity-Device-ID") == anonymousIdentity.deviceID)
      #expect(request.value(forHTTPHeaderField: "Identity-External-ID") == Identity.hashExternalID(from: accountID))
    }

    @Test func failedLogoutReportsErrorAndStopsUsingOldIdentity() async throws {
      gateway.saveError = CocoaError(.fileWriteNoPermission)

      await #expect(throws: CocoaError(.fileWriteNoPermission)) {
        try await client.logout()
      }

      let error = await #expect(throws: MobileJoeError.self) {
        try await client.getAlerts()
      }
      guard case .unknownIdentity = error else {
        Issue.record("Expected requests to stop using the previous identity")
        return
      }
      #expect(router.performCallCount == 0)

      gateway.saveError = nil
      try await client.logout()
      try prepareResponse()
      _ = try await client.getAlerts()
      #expect(router.lastRequest?.value(forHTTPHeaderField: "Identity-External-ID") == nil)
    }

    @Test func identificationPropagatesStorageErrorsAfterBackendSuccess() async throws {
      try await client.logout()
      let anonymousIdentity = identityManager.currentIdentity
      try prepareResponse()
      gateway.saveError = CocoaError(.fileWriteNoPermission)

      await #expect(throws: CocoaError(.fileWriteNoPermission)) {
        try await client.identify(externalID: "new-account")
      }

      #expect(router.performCallCount == 1)
      #expect(identityManager.currentIdentity == anonymousIdentity)
    }

    @Test func identificationPropagatesNetworkErrorsAfterLoggingOutPreviousAccount() async throws {
      router.nextError = URLError(.notConnectedToInternet)

      await #expect(throws: URLError(.notConnectedToInternet)) {
        try await client.identify(externalID: "new-account")
      }

      #expect(router.performCallCount == 1)
      let identity = try #require(identityManager.currentIdentity)
      #expect(identity.externalID == nil)
      #expect(identity.anonymousID != oldIdentity.anonymousID)
    }

    @Test(arguments: [false, true])
    func logoutAfterIdentificationUsesAnonymousHeaders(fromConfigure: Bool) async throws {
      try prepareResponse()
      if fromConfigure {
        try await client.configure(withAPIKey: "api-key", externalID: "account-id", debugMode: true)
      } else {
        try await client.identify(externalID: "account-id")
      }
      #expect(router.performCallCount == 1)

      try await client.logout()
      let anonymousIdentity = try #require(gateway.findReturnValue)
      #expect(router.performCallCount == 1)
      _ = try await client.getAlerts()

      let request = try #require(router.lastRequest)
      #expect(request.value(forHTTPHeaderField: "Identity-External-ID") == nil)
      #expect(request.value(forHTTPHeaderField: "Identity-Anonymous-ID") == anonymousIdentity.anonymousID)
      #expect(request.value(forHTTPHeaderField: "Identity-Device-ID") == anonymousIdentity.deviceID)
      #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer api-key")
    }

    @Test func configurePropagatesNetworkErrors() async throws {
      router.nextError = URLError(.notConnectedToInternet)
      await #expect(throws: URLError(.notConnectedToInternet)) {
        try await client.configure(withAPIKey: "api-key", externalID: "new-account")
      }
      #expect(router.performCallCount == 1)
    }

    @Test func clientsReadCurrentIdentityFromManagerWithoutLoadingStorage() async throws {
      let secondClient = NetworkClient(router: router, apiKey: "api-key", identityManager: identityManager)
      try prepareResponse()

      let anonymousIdentity = try await identityManager.logout()
      let readsAfterLogout = gateway.findCallCount
      for networkClient in [client, secondClient] {
        _ = try await networkClient.getAlerts()
        #expect(router.lastRequest?.value(forHTTPHeaderField: "Identity-Anonymous-ID") == anonymousIdentity.anonymousID)
        #expect(router.lastRequest?.value(forHTTPHeaderField: "Identity-Device-ID") == anonymousIdentity.deviceID)
        #expect(router.lastRequest?.value(forHTTPHeaderField: "Identity-External-ID") == nil)
      }
      #expect(gateway.findCallCount == readsAfterLogout)

      let signedInIdentity = try #require(await identityManager.prepareIdentity(for: "new-account"))
      try await identityManager.commit(signedInIdentity)
      let readsAfterLogin = gateway.findCallCount
      for networkClient in [client, secondClient] {
        _ = try await networkClient.getAlerts()
        #expect(router.lastRequest?.value(forHTTPHeaderField: "Identity-External-ID") == signedInIdentity.externalID)
      }
      #expect(gateway.findCallCount == readsAfterLogin)

      gateway.saveError = CocoaError(.fileWriteNoPermission)
      await #expect(throws: CocoaError(.fileWriteNoPermission)) {
        try await identityManager.logout()
      }
      #expect(identityManager.currentIdentity == nil)
      let requestCount = router.performCallCount
      for networkClient in [client, secondClient] {
        let error = await #expect(throws: MobileJoeError.self) {
          try await networkClient.getAlerts()
        }
        guard case .unknownIdentity = error else {
          Issue.record("Expected both clients to observe the cleared identity")
          return
        }
      }
      #expect(router.performCallCount == requestCount)
    }

    private func prepareResponse() throws {
      let url = try #require(URL(string: "https://mbj-api.com/v1/alerts"))
      let response = try #require(HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil))
      router.nextResult = (Data("[]".utf8), response)
    }
  }
}

// MARK: - Helpers
extension NetworkClientTests.FeaturePlanEndpoints {
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
