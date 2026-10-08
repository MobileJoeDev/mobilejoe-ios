// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation
import Testing
@testable import MobileJoe

struct IdentityConcurrencyTests {
  private let router = SuspendedIdentityRouter()
  private let gateway = IdentityGatewayMock()
  private let manager: IdentityManager
  private let client: NetworkClient

  init() {
    manager = IdentityManager(gateway: gateway)
    client = NetworkClient(router: router, identityManager: manager)
  }

  @Test func configurationAndDuplicateIdentificationShareOneRequest() async throws {
    let configuration = await start { try await client.configure(withAPIKey: "key", externalID: "A") }
    await router.started.wait()
    let first = await start { try await client.identify(externalID: "A") }
    let second = await start { try await client.identify(externalID: "A") }
    #expect(router.requests.count == 1)
    #expect(manager.currentIdentity == nil)
    router.release.open()
    try await configuration.value
    try await first.value
    try await second.value
    try await client.identify(externalID: "A")
    #expect(router.requests.count == 1)
    #expect(manager.currentIdentity?.externalID == Identity.hashExternalID(from: "A"))
  }

  @Test func switchesAndLogoutPreserveOrder() async throws {
    let configuration = await start { try await client.configure(withAPIKey: "key", externalID: "A") }
    await router.started.wait()
    let switchB = await start { try await client.identify(externalID: "B") }
    let switchA = await start { try await client.identify(externalID: "A") }
    let logout = await start { try await client.logout() }
    let login = await start { try await client.identify(externalID: "A") }
    #expect(router.requests.count == 1)
    router.release.open()
    for task in [configuration, switchB, switchA, logout, login] { try await task.value }
    #expect(router.requests.map { $0.value(forHTTPHeaderField: "Identity-External-ID") } == ["A", "B", "A", "A"].map {
      Identity.hashExternalID(from: $0)
    })
    #expect(router.requests[2].value(forHTTPHeaderField: "Identity-Anonymous-ID") !=
      router.requests[3].value(forHTTPHeaderField: "Identity-Anonymous-ID"))
  }

  @Test func failedConfigurationRejectsQueuedOperationsAndAllowsRetry() async throws {
    router.error = URLError(.timedOut)
    let configuration = await start { try await client.configure(withAPIKey: "key", externalID: "A") }
    await router.started.wait()
    let identify = await start { try await client.identify(externalID: "B") }
    let logout = await start { try await client.logout() }
    router.release.open()
    for task in [configuration, identify, logout] {
      await #expect(throws: URLError(.timedOut)) { try await task.value }
    }
    #expect(router.requests.count == 1)
    #expect(manager.currentIdentity == nil)
    #expect(gateway.findReturnValue == nil)
    await #expect(throws: MobileJoeError.self) { try await client.getAlerts() }
    await #expect(throws: MobileJoeError.self) { try await client.identify(externalID: "B") }
    #expect(router.requests.count == 1)
    router.error = nil
    try await client.configure(withAPIKey: "key", externalID: "B")
    #expect(manager.currentIdentity?.externalID == Identity.hashExternalID(from: "B"))
  }

  @Test func identificationBeforeConfigurationDoesNotTouchStorage() async {
    await #expect(throws: MobileJoeError.self) { try await client.identify(externalID: "A") }
    #expect(gateway.findCallCount == 0)
    #expect(gateway.findReturnValue == nil)
    #expect(manager.currentIdentity == nil)
    #expect(router.requests.isEmpty)
  }

  @Test func failedSharedSwitchKeepsFreshAnonymousIdentityAndCanBeRetried() async throws {
    router.release.open()
    try await client.configure(withAPIKey: "key", externalID: "A")
    let oldIdentity = try #require(manager.currentIdentity)
    router.release = IdentityTestGate()
    router.started = IdentityTestGate()
    router.error = URLError(.timedOut)
    let first = await start { try await client.identify(externalID: "B") }
    await router.started.wait()
    let duplicate = await start { try await client.identify(externalID: "B") }
    let anonymousIdentity = try #require(manager.currentIdentity)
    #expect(anonymousIdentity.externalID == nil)
    #expect(anonymousIdentity.anonymousID != oldIdentity.anonymousID)
    #expect(gateway.findReturnValue == anonymousIdentity)
    router.release.open()
    for task in [first, duplicate] {
      await #expect(throws: URLError(.timedOut)) { try await task.value }
    }
    #expect(router.requests.count == 2)
    #expect(manager.currentIdentity == anonymousIdentity)
    router.error = nil
    try await client.identify(externalID: "B")
    #expect(router.requests.count == 3)
    #expect(manager.currentIdentity?.anonymousID == anonymousIdentity.anonymousID)
    #expect(manager.currentIdentity?.externalID == Identity.hashExternalID(from: "B"))
  }

  @Test func persistenceFailureKeepsAnonymousIdentityAndRetriesBackend() async throws {
    router.release.open()
    try await client.configure(withAPIKey: "key", externalID: nil)
    let oldIdentity = manager.currentIdentity
    gateway.saveError = CocoaError(.fileWriteNoPermission)
    await #expect(throws: CocoaError(.fileWriteNoPermission)) { try await client.identify(externalID: "B") }
    #expect(manager.currentIdentity == oldIdentity)
    #expect(gateway.findReturnValue == oldIdentity)
    gateway.saveError = nil
    try await client.identify(externalID: "B")
    #expect(router.requests.count == 3)
    #expect(manager.currentIdentity?.anonymousID == oldIdentity?.anonymousID)
    #expect(manager.currentIdentity?.externalID == Identity.hashExternalID(from: "B"))
  }

  @Test func switchPersistenceFailureBlocksIdentificationUntilLogoutCompletes() async throws {
    router.release.open()
    try await client.configure(withAPIKey: "key", externalID: "A")
    let oldIdentity = try #require(manager.currentIdentity)
    gateway.saveError = CocoaError(.fileWriteNoPermission)
    await #expect(throws: CocoaError(.fileWriteNoPermission)) { try await client.identify(externalID: "B") }
    #expect(manager.currentIdentity == nil)
    #expect(gateway.findReturnValue == nil)
    #expect(router.requests.count == 1)
    gateway.saveError = nil
    try await client.identify(externalID: "B")
    #expect(router.requests.count == 2)
    #expect(manager.currentIdentity?.anonymousID != oldIdentity.anonymousID)
    #expect(manager.currentIdentity?.externalID == Identity.hashExternalID(from: "B"))
  }

  @Test func cancellingOneWaiterDoesNotCancelSharedOperation() async throws {
    let configuration = await start { try await client.configure(withAPIKey: "key", externalID: "A") }
    await router.started.wait()
    let identify = await start { try await client.identify(externalID: "A") }
    configuration.cancel()
    router.release.open()
    try await configuration.value
    try await identify.value
    #expect(router.requests.count == 1)
    #expect(manager.currentIdentity != nil)
  }

  @Test func identityChangesWaitForPersistenceToFinish() async throws {
    let gateway = SuspendedIdentityGateway()
    let manager = IdentityManager(gateway: gateway)
    let client = NetworkClient(router: router, identityManager: manager)
    router.release.open()
    let configuration = await start { try await client.configure(withAPIKey: "key", externalID: "A", debugMode: true) }
    await gateway.started.wait()
    #expect(router.requests.first?.value(forHTTPHeaderField: "Authorization") == "Bearer key")
    #expect(router.requests.first?.value(forHTTPHeaderField: "Debug-Mode") == "true")
    let error = await #expect(throws: MobileJoeError.self) { try await client.getAlerts() }
    if case .notConfigured = error {} else { Issue.record("Expected configuration to wait for persistence") }
    let identify = await start { try await client.identify(externalID: "B") }
    #expect(router.requests.count == 1)
    #expect(manager.currentIdentity == nil)
    gateway.release.open()
    try await configuration.value
    try await identify.value
    #expect(router.requests.count == 2)
    #expect(manager.currentIdentity?.externalID == Identity.hashExternalID(from: "B"))
    _ = try await client.getAlerts()
    #expect(router.requests.last?.value(forHTTPHeaderField: "Authorization") == "Bearer key")
    #expect(router.requests.last?.value(forHTTPHeaderField: "Debug-Mode") == "true")
  }

  @Test func logoutRecoversCorruptStorageAfterFailedConfiguration() async throws {
    let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
    let gateway = FileBasedIdentityGateway(directory: directory)
    defer { try? FileManager.default.removeItem(at: directory) }
    let file = directory.appending(path: "identity.mbj")
    try Data("invalid identity".utf8).write(to: file)
    let manager = IdentityManager(gateway: gateway)
    let client = NetworkClient(router: router, identityManager: manager)
    await #expect(throws: DecodingError.self) {
      try await client.configure(withAPIKey: "key", externalID: "A")
    }
    #expect(router.requests.isEmpty)
    #expect(manager.currentIdentity == nil)
    await #expect(throws: DecodingError.self) {
      try await client.configure(withAPIKey: "key", externalID: "A")
    }
    try await client.logout()
    let anonymousIdentity = try #require(manager.currentIdentity)
    #expect(anonymousIdentity.externalID == nil)
    #expect(try await gateway.find() == anonymousIdentity)
    #expect(router.requests.isEmpty)
    let error = await #expect(throws: MobileJoeError.self) { try await client.getAlerts() }
    switch error {
    case .notConfigured: break
    default: Issue.record("Logout must not enable backend requests before configuration")
    }
    router.release.open()
    try await client.configure(withAPIKey: "key", externalID: "A")
    #expect(router.requests.count == 1)
    #expect(manager.currentIdentity?.anonymousID == anonymousIdentity.anonymousID)
    #expect(manager.currentIdentity?.externalID == Identity.hashExternalID(from: "A"))
  }

  @Test func logoutBeforeConfigurationPropagatesStorageFailureAndAllowsRetry() async throws {
    gateway.saveError = CocoaError(.fileWriteNoPermission)
    await #expect(throws: CocoaError(.fileWriteNoPermission)) { try await client.logout() }
    #expect(manager.currentIdentity == nil)
    gateway.saveError = nil
    try await client.logout()
    #expect(manager.currentIdentity != nil)
    #expect(manager.currentIdentity?.externalID == nil)
    await #expect(throws: MobileJoeError.self) { try await client.identify(externalID: "A") }
    #expect(router.requests.isEmpty)
  }

  @Test func persistedIdentityAndFailedSwitchRequireBackendSynchronization() async throws {
    router.release.open()
    try await gateway.save(identity: Identity(externalID: "A"))
    try await client.configure(withAPIKey: "key", externalID: "A")
    #expect(router.requests.count == 1)

    router.error = URLError(.timedOut)
    await #expect(throws: URLError(.timedOut)) { try await client.identify(externalID: "B") }
    router.error = nil
    try await client.identify(externalID: "A")
    #expect(router.requests.count == 3)
    try await client.identify(externalID: "A")
    #expect(router.requests.count == 3)
  }

  private func start(_ operation: @escaping @MainActor () async throws -> Void) async -> Task<Void, Error> {
    let started = IdentityTestGate()
    let task = Task {
      // Both closures run on MainActor. The SDK enqueues before yielding back to this test.
      started.open()
      try await operation()
    }
    await started.wait()
    return task
  }
}

private final class IdentityTestGate {
  private var isOpen = false
  private var waiters: [CheckedContinuation<Void, Never>] = []

  func wait() async {
    if isOpen { return }
    await withCheckedContinuation { waiters.append($0) }
  }

  func open() {
    isOpen = true
    let pending = waiters
    waiters.removeAll()
    for waiter in pending { waiter.resume() }
  }
}

private final class SuspendedIdentityRouter: Router {
  var started = IdentityTestGate()
  var release = IdentityTestGate()
  var requests: [URLRequest] = []
  var error: Error?

  func perform(_ request: URLRequest) async throws -> (data: Data, response: HTTPURLResponse) {
    requests.append(request)
    started.open()
    await release.wait()
    if let error { throw error }
    let url = try #require(request.url)
    let response = try #require(HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil))
    return (Data(), response)
  }
}

private final class SuspendedIdentityGateway: IdentityGateway {
  private let storage = IdentityGatewayMock()

  func find() async throws -> Identity? { try await storage.find() }
  func delete() async throws { try await storage.delete() }
  let started = IdentityTestGate()
  let release = IdentityTestGate()

  func save(identity: Identity) async throws {
    started.open()
    await release.wait()
    try await storage.save(identity: identity)
  }
}
