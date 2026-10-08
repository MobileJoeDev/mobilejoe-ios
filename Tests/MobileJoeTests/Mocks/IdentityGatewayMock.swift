// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation
@testable import MobileJoe

class IdentityGatewayMock: IdentityGateway {
  var findReturnValue: Identity? = nil
  var findCallCount = 0
  func find() async throws -> Identity? {
    findCallCount += 1
    return findReturnValue
  }

  var saveIdentityCalledWithIdentity: Identity?
  var saveError: Error?
  func save(identity: Identity) async throws {
    if let saveError { throw saveError }
    saveIdentityCalledWithIdentity = identity
    findReturnValue = identity
  }

  var deleteCalled: Bool = false
  var deleteError: Error?
  func delete() async throws {
    deleteCalled = true
    if let deleteError { throw deleteError }
    findReturnValue = nil
  }
}
