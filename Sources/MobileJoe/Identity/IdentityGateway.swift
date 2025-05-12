//
//  File.swift
//  MobileJoe
//
//  Created by Florian on 11.05.25.
//

import Foundation

@MainActor
protocol IdentityGateway {
  func find() async throws -> Identity?
  func save(identity: Identity) async throws
}

@MainActor
class FileBasedIdentityGateway: IdentityGateway {
  static let shared = FileBasedIdentityGateway()

  private static let identityURL = URL.applicationSupportDirectory.appending(path: "identity.mbj")

  func find() async throws -> Identity? {
    let identityData = try Data(contentsOf: Self.identityURL)
    return try JSONDecoder().decode(Identity.self, from: identityData)
  }

  func save(identity: Identity) async throws {
    let identityData = try JSONEncoder().encode(identity)
    try identityData.write(to: Self.identityURL)
  }
}
