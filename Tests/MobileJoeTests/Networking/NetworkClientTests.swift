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

    @Test func `repeated configuration preserves settings and logged out identity`() async throws {
      router.nextResult = (Data(), try makeResponse(path: "/v1/identify"))
      let identity = try #require(try client.configure(withAPIKey: "first-key", externalID: "first-account", debugMode: true))
      _ = try client.logout()

      #expect(try client.configure(withAPIKey: "second-key", externalID: "second-account", debugMode: false) == nil)
      await client.send(identity)
      #expect(router.performCallCount == 0)

      _ = try await client.getAlerts()
      #expect(router.lastRequest?.value(forHTTPHeaderField: "Authorization") == "Bearer first-key")
      #expect(router.lastRequest?.value(forHTTPHeaderField: "Debug-Mode") == "true")
      #expect(router.lastRequest?.value(forHTTPHeaderField: "Identity-External-ID") == nil)
    }

    @Test func `configuration returns before identification and requests use target identity`() async throws {
      router.nextResult = (Data("[]".utf8), try makeResponse(path: "/v1/alerts"))
      let identity = try #require(try client.configure(withAPIKey: "second-key", externalID: "account-id", debugMode: false))
      #expect(router.performCallCount == 0)

      _ = try await client.getAlerts()
      let request = try #require(router.requests.first)
      #expect(request.url?.path == "/v1/alerts")
      #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer second-key")
      #expect(request.value(forHTTPHeaderField: "Debug-Mode") == "false")
      #expect(request.value(forHTTPHeaderField: "Identity-External-ID") == Identity.hashExternalID(from: "account-id"))
      await client.send(identity)
      #expect(router.requests.map(\.url?.path) == ["/v1/alerts", "/v1/identify"])
    }

    @Test func `failed background identification is not retried by identification`() async throws {
      router.nextError = URLError(.notConnectedToInternet)
      try await client.configureAndSend(withAPIKey: "api-key", externalID: "account-id")
      #expect(router.performCallCount == 1)

      router.nextResult = (Data(), try makeResponse(path: "/v1/identify"))
      try await client.identifyAndSend(externalID: "account-id")
      #expect(router.performCallCount == 1)
    }

    @Test func `invalid API key disables requests`() async throws {
      router.nextResult = (Data(), try makeResponse(path: "/v1/identify", statusCode: 401))
      try await client.configureAndSend(withAPIKey: "invalid-key", externalID: "account-id")
      #expect(router.performCallCount == 1)

      for request in [{ _ = try await client.getAlerts() }, { try await client.identifyAndSend(externalID: "account-id") }] {
        let error = await #expect(throws: MobileJoeError.self) { try await request() }
        if case .notConfigured = error {} else { Issue.record("Expected .notConfigured error, got \(String(describing: error))") }
      }
      #expect(router.performCallCount == 1)
    }

    @Test(arguments: [403, 500])
    func `other identification failures keep requests enabled`(statusCode: Int) async throws {
      router.nextResult = (Data(), try makeResponse(path: "/v1/identify", statusCode: statusCode))
      try await client.configureAndSend(withAPIKey: "api-key", externalID: "account-id")

      router.nextResult = (Data("[]".utf8), try makeResponse(path: "/v1/alerts"))
      _ = try await client.getAlerts()
      #expect(router.performCallCount == 2)
    }

    @Test func `repeated configuration has nothing to send`() throws {
      #expect(try client.configure(withAPIKey: "api-key", externalID: "account-id") != nil)
      #expect(try client.configure(withAPIKey: "api-key", externalID: "account-id") == nil)
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

    @Test func `throws not configured before configuration without identity`() async {
      let router = RouterMock()
      let client = NetworkClient(router: router, identityManager: IdentityManager(gateway: IdentityGatewayMock()))

      let error = await #expect(throws: MobileJoeError.self) {
        try await client.getAlerts()
      }
      guard case .notConfigured = error else {
        Issue.record("Expected .notConfigured error, got \(String(describing: error))")
        return
      }
      #expect(router.performCallCount == 0)
    }

    @Test func `logout before configuration has nothing to send`() async throws {
      let router = RouterMock()
      let client = NetworkClient(router: router, identityManager: IdentityManager(gateway: IdentityGatewayMock()))

      let identity = try client.logout()
      await client.send(identity)

      #expect(router.performCallCount == 0)
    }

    @Test func `configuration after logout identifies the anonymous identity`() async throws {
      let router = RouterMock()
      let client = NetworkClient(router: router, identityManager: IdentityManager(gateway: IdentityGatewayMock()))
      router.nextResult = (Data(), try makeResponse(path: "/v1/identify"))

      let identity = try client.logout()
      try await client.configureAndSend(withAPIKey: "api-key", externalID: nil)

      #expect(router.performCallCount == 1)
      #expect(router.lastRequest?.value(forHTTPHeaderField: "Identity-Anonymous-ID") == identity.anonymousID)
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

    @Test(arguments: [400, 403, 404, 429, 500, 503])
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

    @Test func `invalid API key disables later requests`() async throws {
      router.nextResult = (Data("{}".utf8), try makeResponse(path: "/v1/feature_plans", statusCode: 401))

      let error = await #expect(throws: MobileJoeError.self) {
        _ = try await client.getFeaturePlans(filterBy: nil, sort: .byNewest, search: nil, page: 1)
      }
      if case .invalidAPIKey = error {} else { Issue.record("Expected .invalidAPIKey, got \(String(describing: error))") }

      let laterError = await #expect(throws: MobileJoeError.self) { try await client.getAlerts() }
      if case .notConfigured = laterError {} else { Issue.record("Expected .notConfigured, got \(String(describing: laterError))") }
      #expect(router.performCallCount == 1)
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

    @Test func `requests after logout use new anonymous identity`() async throws {
      _ = try client.logout()

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

    @Test func `repeated logout rotates anonymous identity`() async throws {
      _ = try client.logout()
      let firstIdentity = try #require(gateway.findReturnValue)

      _ = try client.logout()
      let secondIdentity = try #require(gateway.findReturnValue)

      #expect(secondIdentity.anonymousID != firstIdentity.anonymousID)
      #expect(secondIdentity.deviceID != firstIdentity.deviceID)
      #expect(secondIdentity.externalID == nil)
      #expect(router.performCallCount == 0)
    }

    @Test(arguments: ["account-id", "another-account"])
    func `login after logout keeps new local IDs`(accountID: String) async throws {
      _ = try client.logout()
      let anonymousIdentity = try #require(gateway.findReturnValue)

      try prepareResponse()
      try await client.identifyAndSend(externalID: accountID)

      let request = try #require(router.lastRequest)
      #expect(request.httpMethod == "POST")
      #expect(request.url?.path == "/v1/identify")
      #expect(request.value(forHTTPHeaderField: "Identity-Anonymous-ID") == anonymousIdentity.anonymousID)
      #expect(request.value(forHTTPHeaderField: "Identity-Device-ID") == anonymousIdentity.deviceID)
      #expect(request.value(forHTTPHeaderField: "Identity-External-ID") == Identity.hashExternalID(from: accountID))
    }

    @Test func `failed logout reports error and stops using old identity`() async throws {
      gateway.saveError = CocoaError(.fileWriteNoPermission)

      #expect(throws: CocoaError(.fileWriteNoPermission)) {
        _ = try client.logout()
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
      _ = try client.logout()
      try prepareResponse()
      _ = try await client.getAlerts()
      #expect(router.lastRequest?.value(forHTTPHeaderField: "Identity-External-ID") == nil)
    }

    @Test func `identification propagates storage errors before backend request`() async throws {
      _ = try client.logout()
      let anonymousIdentity = identityManager.currentIdentity
      try prepareResponse()
      gateway.saveError = CocoaError(.fileWriteNoPermission)

      #expect(throws: CocoaError(.fileWriteNoPermission)) {
        try client.identify(externalID: "new-account")
      }

      #expect(router.performCallCount == 0)
      #expect(identityManager.currentIdentity == anonymousIdentity)
    }

    @Test func `identification keeps new identity after network error`() async throws {
      router.nextError = URLError(.notConnectedToInternet)

      try await client.identifyAndSend(externalID: "new-account")

      #expect(router.performCallCount == 1)
      let identity = try #require(identityManager.currentIdentity)
      #expect(identity.externalID == Identity.hashExternalID(from: "new-account"))
      #expect(identity.anonymousID != oldIdentity.anonymousID)
      #expect(router.lastRequest?.value(forHTTPHeaderField: "Identity-Anonymous-ID") == identity.anonymousID)
    }

    @Test(arguments: [false, true])
    func `logout after identification uses anonymous headers`(fromConfigure: Bool) async throws {
      try prepareResponse()
      if fromConfigure {
        try await client.configureAndSend(withAPIKey: "api-key", externalID: "account-id", debugMode: true)
      } else {
        try await client.identifyAndSend(externalID: "account-id")
      }
      let requestsBeforeLogout = router.performCallCount

      _ = try client.logout()
      let anonymousIdentity = try #require(gateway.findReturnValue)
      #expect(router.performCallCount == requestsBeforeLogout)
      _ = try await client.getAlerts()

      let request = try #require(router.lastRequest)
      #expect(request.value(forHTTPHeaderField: "Identity-External-ID") == nil)
      #expect(request.value(forHTTPHeaderField: "Identity-Anonymous-ID") == anonymousIdentity.anonymousID)
      #expect(request.value(forHTTPHeaderField: "Identity-Device-ID") == anonymousIdentity.deviceID)
      #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer api-key")
    }

    @Test func `configuration keeps target identity when identification fails`() async throws {
      router.nextError = URLError(.notConnectedToInternet)
      let identity = try #require(try client.configure(withAPIKey: "api-key", externalID: "new-account"))
      #expect(identityManager.currentIdentity == identity)
      #expect(identity.anonymousID != oldIdentity.anonymousID)
      #expect(identity.externalID == Identity.hashExternalID(from: "new-account"))
      #expect(gateway.findReturnValue == identity)

      await client.send(identity)
      #expect(router.performCallCount == 1)
      #expect(identityManager.currentIdentity == identity)
      try prepareResponse()
      _ = try await client.getAlerts()
      #expect(router.lastRequest?.value(forHTTPHeaderField: "Identity-Anonymous-ID") == identity.anonymousID)
    }

    @Test func `clients read current identity from manager without loading storage`() async throws {
      let secondClient = NetworkClient(router: router, apiKey: "api-key", identityManager: identityManager)
      try prepareResponse()

      let anonymousIdentity = try identityManager.logout()
      let readsAfterLogout = gateway.findCallCount
      for networkClient in [client, secondClient] {
        _ = try await networkClient.getAlerts()
        #expect(router.lastRequest?.value(forHTTPHeaderField: "Identity-Anonymous-ID") == anonymousIdentity.anonymousID)
        #expect(router.lastRequest?.value(forHTTPHeaderField: "Identity-Device-ID") == anonymousIdentity.deviceID)
        #expect(router.lastRequest?.value(forHTTPHeaderField: "Identity-External-ID") == nil)
      }
      #expect(gateway.findCallCount == readsAfterLogout)

      let signedInIdentity = try #require(try identityManager.identify(externalID: "new-account"))

      let readsAfterLogin = gateway.findCallCount
      for networkClient in [client, secondClient] {
        _ = try await networkClient.getAlerts()
        #expect(router.lastRequest?.value(forHTTPHeaderField: "Identity-External-ID") == signedInIdentity.externalID)
      }
      #expect(gateway.findCallCount == readsAfterLogin)

      gateway.saveError = CocoaError(.fileWriteNoPermission)
      #expect(throws: CocoaError(.fileWriteNoPermission)) {
        try identityManager.logout()
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
