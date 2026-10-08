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

  @Test func firstLoginKeepsAnonymousIDs() async throws {
    try await client.identify(externalID: nil)
    let anonymous = try #require(manager.currentIdentity)

    try await client.identify(externalID: "A")

    let identity = try #require(manager.currentIdentity)
    #expect(identity.anonymousID == anonymous.anonymousID)
    #expect(identity.deviceID == anonymous.deviceID)
    #expect(identity.externalID == Identity.hashExternalID(from: "A"))
    #expect(gateway.deleteCalled == false)
  }

  @Test func sameAccountAgainKeepsIdentityWithoutRequest() async throws {
    try await client.identify(externalID: "A")
    let identity = manager.currentIdentity

    try await client.identify(externalID: "A")

    #expect(manager.currentIdentity == identity)
    #expect(router.performCallCount == 1)
    #expect(gateway.deleteCalled == false)
  }

  @Test func persistedSameAccountKeepsIDs() async throws {
    let persisted = Identity(externalID: "A")
    gateway.findReturnValue = persisted

    try await client.identify(externalID: "A")

    #expect(manager.currentIdentity == persisted)
    #expect(router.lastRequest?.value(forHTTPHeaderField: "Identity-Anonymous-ID") == persisted.anonymousID)
    #expect(gateway.deleteCalled == false)
  }

  @Test func switchingAccountLogsOutFirst() async throws {
    try await client.identify(externalID: "A")
    let accountA = try #require(manager.currentIdentity)

    try await client.identify(externalID: "B")

    let accountB = try #require(manager.currentIdentity)
    #expect(gateway.deleteCalled)
    #expect(accountB.anonymousID != accountA.anonymousID)
    #expect(accountB.deviceID != accountA.deviceID)
    #expect(accountB.externalID == Identity.hashExternalID(from: "B"))
    let request = try #require(router.lastRequest)
    #expect(request.value(forHTTPHeaderField: "Identity-Anonymous-ID") == accountB.anonymousID)
    #expect(request.value(forHTTPHeaderField: "Identity-External-ID") == accountB.externalID)
  }

  @Test func persistedAccountSwitchLogsOutFirst() async throws {
    let accountA = Identity(externalID: "A")
    gateway.findReturnValue = accountA

    try await client.identify(externalID: "B")

    let accountB = try #require(manager.currentIdentity)
    #expect(accountB.anonymousID != accountA.anonymousID)
    #expect(accountB.externalID == Identity.hashExternalID(from: "B"))
  }

  @Test func configurationWithoutAppUserIDKeepsPersistedAccount() async throws {
    let accountA = Identity(externalID: "A")
    gateway.findReturnValue = accountA
    let client = NetworkClient(router: router, identityManager: manager)

    try await client.configure(withAPIKey: "api-key", externalID: nil)

    #expect(manager.currentIdentity == accountA)
    #expect(gateway.deleteCalled == false)
    let request = try #require(router.lastRequest)
    #expect(request.value(forHTTPHeaderField: "Identity-Anonymous-ID") == accountA.anonymousID)
    #expect(request.value(forHTTPHeaderField: "Identity-External-ID") == accountA.externalID)

    try await client.identify(externalID: "A")
    #expect(manager.currentIdentity == accountA)
    #expect(router.performCallCount == 1)
  }

  @Test func identificationAfterConfigurationWithoutAppUserIDSwitchesAccount() async throws {
    let accountA = Identity(externalID: "A")
    gateway.findReturnValue = accountA
    let client = NetworkClient(router: router, identityManager: manager)
    try await client.configure(withAPIKey: "api-key", externalID: nil)

    try await client.identify(externalID: "B")

    let accountB = try #require(manager.currentIdentity)
    #expect(gateway.deleteCalled)
    #expect(accountB.anonymousID != accountA.anonymousID)
    #expect(accountB.externalID == Identity.hashExternalID(from: "B"))
  }

  @Test func identificationWithoutAppUserIDKeepsAccount() async throws {
    try await client.identify(externalID: "A")
    let accountA = manager.currentIdentity

    try await client.identify(externalID: nil)

    #expect(manager.currentIdentity == accountA)
    #expect(router.performCallCount == 1)
    #expect(gateway.deleteCalled == false)
  }

  @Test func anonymousIdentificationWhenAnonymousKeepsIDs() async throws {
    try await client.identify(externalID: nil)
    let anonymous = manager.currentIdentity

    try await client.identify(externalID: nil)

    #expect(manager.currentIdentity == anonymous)
    #expect(gateway.deleteCalled == false)
  }

  @Test func loginAfterLogoutKeepsFreshAnonymousIDs() async throws {
    try await client.identify(externalID: "A")
    let accountA = try #require(manager.currentIdentity)
    try await client.logout()
    let loggedOut = try #require(manager.currentIdentity)
    gateway.deleteCalled = false

    try await client.identify(externalID: "B")

    let accountB = try #require(manager.currentIdentity)
    #expect(accountB.anonymousID == loggedOut.anonymousID)
    #expect(accountB.anonymousID != accountA.anonymousID)
    #expect(accountB.externalID == Identity.hashExternalID(from: "B"))
    #expect(gateway.deleteCalled == false)
  }

  @Test func failedSwitchKeepsFreshAnonymousIdentity() async throws {
    try await client.identify(externalID: "A")
    let accountA = try #require(manager.currentIdentity)
    router.nextError = URLError(.timedOut)

    await #expect(throws: URLError(.timedOut)) { try await client.identify(externalID: "B") }

    let anonymous = try #require(manager.currentIdentity)
    #expect(anonymous.externalID == nil)
    #expect(anonymous.anonymousID != accountA.anonymousID)
    #expect(gateway.findReturnValue == anonymous)

    try await client.identify(externalID: "B")
    let accountB = try #require(manager.currentIdentity)
    #expect(accountB.anonymousID == anonymous.anonymousID)
    #expect(accountB.externalID == Identity.hashExternalID(from: "B"))
  }

  @Test(arguments: ["", " ", "\n\t "])
  func emptyAppUserIDIsRejected(appUserID: String) async throws {
    try await client.identify(externalID: "A")
    let accountA = manager.currentIdentity

    let error = await #expect(throws: MobileJoeError.self) { try await client.identify(externalID: appUserID) }

    if case .invalidAppUserID = error {} else { Issue.record("Expected invalid app user ID") }

    #expect(manager.currentIdentity == accountA)
    #expect(router.performCallCount == 1)
    #expect(gateway.deleteCalled == false)
  }

  @Test(arguments: ["", "  "])
  func emptyAppUserIDFailsConfiguration(appUserID: String) async throws {
    let client = NetworkClient(router: router, identityManager: manager)

    let error = await #expect(throws: MobileJoeError.self) {
      try await client.configure(withAPIKey: "api-key", externalID: appUserID)
    }

    if case .invalidAppUserID = error {} else { Issue.record("Expected invalid app user ID") }
    #expect(gateway.findCallCount == 0)
    #expect(router.performCallCount == 0)
    try await client.configure(withAPIKey: "api-key", externalID: "A")
    #expect(manager.currentIdentity?.externalID == Identity.hashExternalID(from: "A"))
  }
}
