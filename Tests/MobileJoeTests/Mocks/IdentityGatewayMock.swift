//
//  Copyright Bytekontor GmbH. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  IdentityGatewayMock.swift
//
//  Created by Florian Mielke on 20.06.25.
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
