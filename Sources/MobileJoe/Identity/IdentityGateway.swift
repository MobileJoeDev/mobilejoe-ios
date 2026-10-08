// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation
import OSLog

protocol IdentityGateway {
  func find() async throws -> Identity?
  func save(identity: Identity) async throws
  func delete() async throws
}

class FileBasedIdentityGateway: IdentityGateway {
  static let shared = FileBasedIdentityGateway()

  private static let mbjDirectory = URL.applicationSupportDirectory.appending(path: "MobileJoe")
  private let identityURL: URL
  private let logger = Logger(category: "FileBasedIdentityGateway")
  private let fileCoordinator: NSFileCoordinator
  private let fileManager: FileManager

  init(directory: URL = mbjDirectory) {
    self.identityURL = directory.appending(path: "identity.mbj")
    self.fileCoordinator = NSFileCoordinator()
    self.fileManager = .default
    findOrCreateIdentityURL()
  }

  func find() async throws -> Identity? {
    var coordinationError: NSError? = nil
    var identity: Identity?
    var operationError: Error?
    fileCoordinator.coordinate(readingItemAt: identityURL, error: &coordinationError) { url in
      do {
        let identityData = try Data(contentsOf: url)
        identity = try JSONDecoder().decode(Identity.self, from: identityData)
      } catch CocoaError.fileReadNoSuchFile {
        // First launch has no persisted identity.
      } catch {
        operationError = error
        logger.error("Joe says: Failed to find identity file. Error: \(error.localizedDescription)")
      }
    }

    if let coordinationError { throw coordinationError }
    if let operationError { throw operationError }
    return identity
  }

  func save(identity: Identity) async throws {
    var coordinationError: NSError? = nil
    var operationError: Error? = nil
    fileCoordinator.coordinate(writingItemAt: identityURL, options: .forMerging, error: &coordinationError) { url in
      do {
        let identityData = try JSONEncoder().encode(identity)
        try identityData.write(to: url, options: [.atomic, .noFileProtection])
      } catch {
        logger.error("Joe says: Failed to save identity file. Error: \(error.localizedDescription)")
        operationError = error
      }
    }

    if let coordinationError {
      throw coordinationError
    }
    if let operationError {
      throw operationError
    }
  }

  func delete() async throws {
    var coordinationError: NSError? = nil
    var operationError: Error? = nil
    fileCoordinator.coordinate(writingItemAt: identityURL, options: .forDeleting, error: &coordinationError) { url in
      do {
        try fileManager.removeItem(at: url)
      } catch CocoaError.fileNoSuchFile {
        // An absent identity already satisfies deletion.
      } catch {
        logger.error("Joe says: Failed to delete identity file. Error: \(error.localizedDescription)")
        operationError = error
      }
    }

    if let coordinationError {
      throw coordinationError
    }
    if let operationError {
      throw operationError
    }
  }

  private func findOrCreateIdentityURL() {
    do {
      try fileManager.createDirectory(at: identityURL.deletingLastPathComponent(), withIntermediateDirectories: true)
    } catch {
      logger.error("Joe says: Failed to create MobileJoe support directory. Error: \(error.localizedDescription)")
    }
  }
}
