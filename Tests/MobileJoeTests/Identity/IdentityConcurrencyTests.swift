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

  @Test func `late requests keep later identity changes`() async throws {
    let accountA = try #require(try client.configure(withAPIKey: "key", externalID: "A"))
    let requestA = Task { await client.send(accountA) }
    await router.started.wait()
    let accountB = try #require(try client.identify(externalID: "B"))
    #expect(manager.currentIdentity == accountB)
    #expect(accountB.externalID == Identity.hashExternalID(from: "B"))
    #expect(accountB.anonymousID != accountA.anonymousID)
    router.started = IdentityTestGate()
    let requestB = Task { await client.send(accountB) }
    await router.started.wait()
    _ = try client.logout()
    let loggedOut = try #require(manager.currentIdentity)

    router.release.open()
    await requestA.value
    await requestB.value
    #expect(router.requests.map { $0.value(forHTTPHeaderField: "Identity-External-ID") } == ["A", "B"].map {
      Identity.hashExternalID(from: $0)
    })
    #expect(manager.currentIdentity == loggedOut)
    #expect(gateway.findReturnValue == loggedOut)
  }

  @Test func `repeated identification while sending sends one request`() async throws {
    try gateway.save(identity: Identity(externalID: "A"))
    let persisted = try #require(try client.configure(withAPIKey: "key", externalID: nil))
    let request = Task { await client.send(persisted) }
    await router.started.wait()
    let pendingRelease = router.release
    router.release = IdentityTestGate()
    router.release.open()

    try await client.identifyAndSend(externalID: "A")

    #expect(manager.currentIdentity == persisted)
    #expect(router.requests.count == 1)
    pendingRelease.open()
    await request.value
  }

  @Test func `failed request keeps identity and is not retried by identification`() async throws {
    router.error = URLError(.timedOut)
    router.release.open()
    try await client.configureAndSend(withAPIKey: "key", externalID: "A")
    let identity = try #require(manager.currentIdentity)
    #expect(router.requests.count == 1)
    #expect(manager.currentIdentity == identity)
    router.error = nil
    try await client.identifyAndSend(externalID: "A")
    #expect(router.requests.count == 1)
    #expect(manager.currentIdentity == identity)
  }

  @Test func `identification before configuration does not touch storage`() async {
    #expect(throws: MobileJoeError.self) { try client.identify(externalID: "A") }
    #expect(gateway.findCallCount == 0)
    #expect(gateway.findReturnValue == nil)
    #expect(manager.currentIdentity == nil)
    #expect(router.requests.isEmpty)
  }

  @Test func `failed switch keeps new identity and is not retried by identification`() async throws {
    router.release.open()
    try await client.configureAndSend(withAPIKey: "key", externalID: "A")
    let oldIdentity = try #require(manager.currentIdentity)
    router.error = URLError(.timedOut)
    let accountB = try #require(try client.identify(externalID: "B"))
    #expect(manager.currentIdentity == accountB)
    #expect(accountB.externalID == Identity.hashExternalID(from: "B"))
    #expect(accountB.anonymousID != oldIdentity.anonymousID)
    #expect(gateway.findReturnValue == accountB)
    await client.send(accountB)
    #expect(router.requests.count == 2)
    #expect(manager.currentIdentity == accountB)
    router.error = nil
    try await client.identifyAndSend(externalID: "B")
    #expect(router.requests.count == 2)
    #expect(manager.currentIdentity == accountB)
  }

  @Test func `persistence failure keeps previous identity and skips backend`() async throws {
    router.release.open()
    try await client.configureAndSend(withAPIKey: "key", externalID: nil)
    let oldIdentity = manager.currentIdentity
    gateway.saveError = CocoaError(.fileWriteNoPermission)
    #expect(throws: CocoaError(.fileWriteNoPermission)) { try client.identify(externalID: "B") }
    #expect(manager.currentIdentity == oldIdentity)
    #expect(gateway.findReturnValue == oldIdentity)
    #expect(router.requests.count == 1)
    gateway.saveError = nil
    try await client.identifyAndSend(externalID: "B")
    #expect(router.requests.count == 2)
    #expect(manager.currentIdentity?.anonymousID == oldIdentity?.anonymousID)
    #expect(manager.currentIdentity?.externalID == Identity.hashExternalID(from: "B"))
  }

  @Test func `switch persistence failure blocks identification until logout completes`() async throws {
    router.release.open()
    try await client.configureAndSend(withAPIKey: "key", externalID: "A")
    let oldIdentity = try #require(manager.currentIdentity)
    gateway.saveError = CocoaError(.fileWriteNoPermission)
    #expect(throws: CocoaError(.fileWriteNoPermission)) { try client.identify(externalID: "B") }
    #expect(manager.currentIdentity == nil)
    #expect(gateway.findReturnValue == nil)
    #expect(router.requests.count == 1)
    gateway.saveError = nil
    try await client.identifyAndSend(externalID: "B")
    #expect(router.requests.count == 2)
    #expect(manager.currentIdentity?.anonymousID != oldIdentity.anonymousID)
    #expect(manager.currentIdentity?.externalID == Identity.hashExternalID(from: "B"))
  }

  @Test func `configuration replaces corrupt identity file`() async throws {
    let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
    let gateway = FileBasedIdentityGateway(directory: directory)
    defer { try? FileManager.default.removeItem(at: directory) }
    try Data("invalid identity".utf8).write(to: directory.appending(path: "identity.mbj"))
    let manager = IdentityManager(gateway: gateway)
    let client = NetworkClient(router: router, identityManager: manager)

    router.release.open()
    try await client.configureAndSend(withAPIKey: "key", externalID: "A")

    let identity = try #require(manager.currentIdentity)
    #expect(identity.externalID == Identity.hashExternalID(from: "A"))
    #expect(try gateway.find() == identity)
    #expect(router.requests.count == 1)
  }


  @Test func `logout before configuration propagates storage failure and allows retry`() async throws {
    gateway.saveError = CocoaError(.fileWriteNoPermission)
    #expect(throws: CocoaError(.fileWriteNoPermission)) { try client.logout() }
    #expect(manager.currentIdentity == nil)
    gateway.saveError = nil
    _ = try client.logout()
    #expect(manager.currentIdentity != nil)
    #expect(manager.currentIdentity?.externalID == nil)
    #expect(throws: MobileJoeError.self) { try client.identify(externalID: "A") }
    #expect(router.requests.isEmpty)
  }

  @Test func `persisted identity and failed switch send requests`() async throws {
    router.release.open()
    try gateway.save(identity: Identity(externalID: "A"))
    try await client.configureAndSend(withAPIKey: "key", externalID: "A")
    #expect(router.requests.count == 1)

    router.error = URLError(.timedOut)
    try await client.identifyAndSend(externalID: "B")
    router.error = nil
    try await client.identifyAndSend(externalID: "A")
    #expect(router.requests.count == 3)
    try await client.identifyAndSend(externalID: "A")
    #expect(router.requests.count == 3)
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
