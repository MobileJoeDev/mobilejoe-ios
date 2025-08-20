//
//  Copyright Bytekontor GmbH. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  IdentityGateway.swift
//
//  Created by Florian Mielke on 11.05.25.
//

import Foundation
import OSLog

@MainActor
protocol IdentityGateway {
  func find() async throws -> Identity?
  func save(identity: Identity) async throws
  func delete() async throws
}

@MainActor
class FileBasedIdentityGateway: IdentityGateway {
  static let shared = FileBasedIdentityGateway()

  private static let mbjDirectory = URL.applicationSupportDirectory.appending(path: "MobileJoe")
  private static let identityURL = mbjDirectory.appending(path: "identity.mbj")
  private let logger: Logger
  private let fileCoordinator: NSFileCoordinator
  private let fileManager: FileManager

  private init() {
    self.fileCoordinator = NSFileCoordinator()
    self.fileManager = .default
    self.logger = Logger(subsystem: "MobileJoe", category: "FileBasedIdentityGateway")
    findOrCreateIdentityURL()
  }

  func find() async throws -> Identity? {
    var error: NSError? = nil
    var identity: Identity?
    fileCoordinator.coordinate(readingItemAt: Self.identityURL, error: &error) { url in
      do {
        let identityData = try Data(contentsOf: url)
        identity = try JSONDecoder().decode(Identity.self, from: identityData)
      } catch {
        logger.error("Joe says: Failed to find identity file. Error: \(error.localizedDescription)")
      }
    }

    if let error {
      throw error
    }

    return identity
  }

  func save(identity: Identity) async throws {
    var error: NSError? = nil
    fileCoordinator.coordinate(writingItemAt: Self.identityURL, options: .forMerging, error: &error) { url in
      do {
        let identityData = try JSONEncoder().encode(identity)
        try identityData.write(to: url, options: [.atomic])
      } catch {
        logger.error("Joe says: Failed to save identity file. Error: \(error.localizedDescription)")
      }
    }

    if let error {
      throw error
    }
  }

  func delete() async throws {
    var error: NSError? = nil
    fileCoordinator.coordinate(writingItemAt: Self.identityURL, options: .forDeleting, error: &error) { url in
      do {
        try fileManager.removeItem(at: url)
      } catch {
        logger.error("Joe says: Failed to delete identity file. Error: \(error.localizedDescription)")
      }
    }

    if let error {
      throw error
    }
  }

  private func findOrCreateIdentityURL() {
    do {
      try fileManager.createDirectory(at: Self.mbjDirectory, withIntermediateDirectories: true)
    } catch {
      logger.error("Joe says: Failed to create MobileJoe support directory. Error: \(error.localizedDescription)")
    }
  }
}
