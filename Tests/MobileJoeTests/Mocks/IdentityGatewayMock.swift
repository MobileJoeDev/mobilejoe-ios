//
//  File.swift
//  MobileJoe
//
//  Created by Florian on 20.06.25.
//

import Foundation
@testable import MobileJoe

class IdentityGatewayMock: IdentityGateway {
  var findReturnValue: Identity? = nil
  func find() async throws -> Identity? {
    findReturnValue
  }

  var saveIdentityCalledWithIdentity: Identity?
  func save(identity: Identity) async throws {
    saveIdentityCalledWithIdentity = identity
  }

  var deleteCalled: Bool = false
  func delete() async throws {
    deleteCalled = true
  }
}
