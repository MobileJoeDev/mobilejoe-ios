// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation
import Testing
@testable import MobileJoe

struct IdentitySwitchTests {
  private let router = RouterMock()
  private let gateway = IdentityGatewayMock()
  private let manager: IdentityManager
  private let client: NetworkClient

  init() throws {
    manager = IdentityManager(gateway: gateway)
    client = NetworkClient(router: router, apiKey: "api-key", identityManager: manager)
    let url = try #require(URL(string: "https://mbj-api.com/v1/identify"))
    let response = try #require(HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil))
    router.nextResult = (Data(), response)
  }

  @Test func `first login keeps anonymous IDs`() async throws {
    try await client.identifyAndSend(externalID: nil)
    let anonymous = try #require(manager.currentIdentity)

    try await client.identifyAndSend(externalID: "A")

    let identity = try #require(manager.currentIdentity)
    #expect(identity.anonymousID == anonymous.anonymousID)
    #expect(identity.deviceID == anonymous.deviceID)
    #expect(identity.externalID == Identity.hashExternalID(from: "A"))
    #expect(gateway.deleteCalled == false)
  }

  @Test func `same app user ID again keeps identity without request`() async throws {
    try await client.identifyAndSend(externalID: "A")
    let identity = manager.currentIdentity

    try await client.identifyAndSend(externalID: "A")

    #expect(manager.currentIdentity == identity)
    #expect(router.performCallCount == 1)
    #expect(gateway.deleteCalled == false)
  }

  @Test func `persisted identity with same app user ID keeps IDs`() async throws {
    let persisted = Identity(externalID: "A")
    gateway.findReturnValue = persisted

    try await client.identifyAndSend(externalID: "A")

    #expect(manager.currentIdentity == persisted)
    #expect(router.lastRequest?.value(forHTTPHeaderField: "Identity-Anonymous-ID") == persisted.anonymousID)
    #expect(gateway.deleteCalled == false)
  }

  @Test func `switching app user ID logs out first`() async throws {
    try await client.identifyAndSend(externalID: "A")
    let accountA = try #require(manager.currentIdentity)

    try await client.identifyAndSend(externalID: "B")

    let accountB = try #require(manager.currentIdentity)
    #expect(gateway.deleteCalled)
    #expect(accountB.anonymousID != accountA.anonymousID)
    #expect(accountB.deviceID != accountA.deviceID)
    #expect(accountB.externalID == Identity.hashExternalID(from: "B"))
    let request = try #require(router.lastRequest)
    #expect(request.value(forHTTPHeaderField: "Identity-Anonymous-ID") == accountB.anonymousID)
    #expect(request.value(forHTTPHeaderField: "Identity-External-ID") == accountB.externalID)
  }

  @Test func `switching from persisted app user ID logs out first`() async throws {
    let accountA = Identity(externalID: "A")
    gateway.findReturnValue = accountA

    try await client.identifyAndSend(externalID: "B")

    let accountB = try #require(manager.currentIdentity)
    #expect(accountB.anonymousID != accountA.anonymousID)
    #expect(accountB.externalID == Identity.hashExternalID(from: "B"))
  }

  @Test func `configuration without app user ID keeps persisted identity`() async throws {
    let accountA = Identity(externalID: "A")
    gateway.findReturnValue = accountA
    let client = NetworkClient(router: router, identityManager: manager)

    try await client.configureAndSend(withAPIKey: "api-key", externalID: nil)

    #expect(manager.currentIdentity == accountA)
    #expect(gateway.deleteCalled == false)
    let request = try #require(router.lastRequest)
    #expect(request.value(forHTTPHeaderField: "Identity-Anonymous-ID") == accountA.anonymousID)
    #expect(request.value(forHTTPHeaderField: "Identity-External-ID") == accountA.externalID)

    try await client.identifyAndSend(externalID: "A")
    #expect(manager.currentIdentity == accountA)
    #expect(router.performCallCount == 1)
  }

  @Test func `identification after configuration without app user ID switches identity`() async throws {
    let accountA = Identity(externalID: "A")
    gateway.findReturnValue = accountA
    let client = NetworkClient(router: router, identityManager: manager)
    try await client.configureAndSend(withAPIKey: "api-key", externalID: nil)

    try await client.identifyAndSend(externalID: "B")

    let accountB = try #require(manager.currentIdentity)
    #expect(gateway.deleteCalled)
    #expect(accountB.anonymousID != accountA.anonymousID)
    #expect(accountB.externalID == Identity.hashExternalID(from: "B"))
  }

  @Test func `configuration with different app user ID never uses previous identity`() async throws {
    let accountA = Identity(externalID: "A")
    gateway.findReturnValue = accountA
    let client = NetworkClient(router: router, identityManager: manager)

    let identity = try #require(try client.configure(withAPIKey: "api-key", externalID: "B"))
    _ = try await client.getAlerts()
    await client.send(identity)

    #expect(gateway.deleteCalled)
    #expect(router.requests.map(\.url?.path) == ["/v1/alerts", "/v1/identify"])
    for request in router.requests {
      #expect(request.value(forHTTPHeaderField: "Identity-Anonymous-ID") != accountA.anonymousID)
      #expect(request.value(forHTTPHeaderField: "Identity-External-ID") == Identity.hashExternalID(from: "B"))
    }
  }

  @Test func `identification without app user ID keeps identity`() async throws {
    try await client.identifyAndSend(externalID: "A")
    let accountA = manager.currentIdentity

    try await client.identifyAndSend(externalID: nil)

    #expect(manager.currentIdentity == accountA)
    #expect(router.performCallCount == 1)
    #expect(gateway.deleteCalled == false)
  }

  @Test func `anonymous identification when anonymous keeps IDs`() async throws {
    try await client.identifyAndSend(externalID: nil)
    let anonymous = manager.currentIdentity

    try await client.identifyAndSend(externalID: nil)

    #expect(manager.currentIdentity == anonymous)
    #expect(gateway.deleteCalled == false)
  }

  @Test func `login after logout keeps fresh anonymous IDs`() async throws {
    try await client.identifyAndSend(externalID: "A")
    let accountA = try #require(manager.currentIdentity)
    _ = try client.logout()
    let loggedOut = try #require(manager.currentIdentity)
    gateway.deleteCalled = false

    try await client.identifyAndSend(externalID: "B")

    let accountB = try #require(manager.currentIdentity)
    #expect(accountB.anonymousID == loggedOut.anonymousID)
    #expect(accountB.anonymousID != accountA.anonymousID)
    #expect(accountB.externalID == Identity.hashExternalID(from: "B"))
    #expect(gateway.deleteCalled == false)
  }

  @Test func `failed switch keeps new identity`() async throws {
    try await client.identifyAndSend(externalID: "A")
    let accountA = try #require(manager.currentIdentity)
    router.nextError = URLError(.timedOut)

    try await client.identifyAndSend(externalID: "B")

    let accountB = try #require(manager.currentIdentity)
    #expect(accountB.externalID == Identity.hashExternalID(from: "B"))
    #expect(accountB.anonymousID != accountA.anonymousID)
    #expect(gateway.findReturnValue == accountB)

    try await client.identifyAndSend(externalID: "B")
    #expect(router.performCallCount == 2)
    #expect(manager.currentIdentity == accountB)
  }

  @Test(arguments: ["", " ", "\n\t "])
  func `empty app user ID is rejected`(appUserID: String) async throws {
    try await client.identifyAndSend(externalID: "A")
    let accountA = manager.currentIdentity

    let error = #expect(throws: MobileJoeError.self) { try client.identify(externalID: appUserID) }

    if case .invalidAppUserID = error {} else { Issue.record("Expected invalid app user ID") }

    #expect(manager.currentIdentity == accountA)
    #expect(router.performCallCount == 1)
    #expect(gateway.deleteCalled == false)
  }

  @Test(arguments: ["", "  "])
  func `empty app user ID fails configuration`(appUserID: String) throws {
    let client = NetworkClient(router: router, identityManager: manager)

    let error = #expect(throws: MobileJoeError.self) {
      try client.configure(withAPIKey: "api-key", externalID: appUserID)
    }

    if case .invalidAppUserID = error {} else { Issue.record("Expected invalid app user ID") }
    #expect(gateway.findCallCount == 0)
    #expect(router.performCallCount == 0)
    _ = try client.configure(withAPIKey: "api-key", externalID: "A")
    #expect(manager.currentIdentity?.externalID == Identity.hashExternalID(from: "A"))
  }
}
