// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation
import Testing
@testable import MobileJoe

struct FileBasedIdentityGatewayTests {
  private let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)

  @Test func `saving unchanged identity keeps file`() throws {
    defer { try? FileManager.default.removeItem(at: directory) }
    let gateway = FileBasedIdentityGateway(directory: directory)
    let identity = Identity(externalID: "account-id")
    try gateway.save(identity: identity)
    let fileNumber = try identityFileNumber()

    try gateway.save(identity: identity)

    #expect(try identityFileNumber() == fileNumber)
    #expect(try gateway.find() == identity)
  }

  @Test func `saving changed identity replaces file`() throws {
    defer { try? FileManager.default.removeItem(at: directory) }
    let gateway = FileBasedIdentityGateway(directory: directory)
    var identity = Identity(externalID: nil)
    try gateway.save(identity: identity)

    identity.update(externalID: "account-id")
    try gateway.save(identity: identity)

    #expect(try gateway.find() == identity)
  }

  @Test func `corrupt identity file counts as missing`() throws {
    defer { try? FileManager.default.removeItem(at: directory) }
    let gateway = FileBasedIdentityGateway(directory: directory)
    try Data("invalid identity".utf8).write(to: directory.appending(path: "identity.mbj"))

    #expect(try gateway.find() == nil)
  }

  private func identityFileNumber() throws -> Int? {
    let attributes = try FileManager.default.attributesOfItem(atPath: directory.appending(path: "identity.mbj").path)
    return attributes[.systemFileNumber] as? Int
  }
}
