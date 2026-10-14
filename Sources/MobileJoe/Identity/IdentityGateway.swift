// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation
import OSLog

protocol IdentityGateway {
  func find() throws -> Identity?
  func save(identity: Identity) throws
  func delete() throws
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

  func find() throws -> Identity? {
    var coordinationError: NSError? = nil
    var identity: Identity?
    var operationError: Error?
    fileCoordinator.coordinate(readingItemAt: identityURL, error: &coordinationError) { url in
      do {
        identity = try readIdentity(at: url)
      } catch CocoaError.fileReadNoSuchFile {
        // First launch has no persisted identity.
      } catch is DecodingError {
        logger.error("Joe says: Identity file is corrupt. Replacing it with a new identity.")
      } catch {
        operationError = error
        logger.error("Joe says: Failed to find identity file. Error: \(error.localizedDescription)")
      }
    }

    if let coordinationError { throw coordinationError }
    if let operationError { throw operationError }
    return identity
  }

  func save(identity: Identity) throws {
    var coordinationError: NSError? = nil
    var operationError: Error? = nil
    fileCoordinator.coordinate(writingItemAt: identityURL, options: .forMerging, error: &coordinationError) { url in
      guard !isStored(identity, at: url) else { return }
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

  func delete() throws {
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

  private func isStored(_ identity: Identity, at url: URL) -> Bool {
    (try? readIdentity(at: url)) == identity
  }

  private func readIdentity(at url: URL) throws -> Identity {
    try JSONDecoder().decode(Identity.self, from: Data(contentsOf: url))
  }

  private func findOrCreateIdentityURL() {
    do {
      try fileManager.createDirectory(at: identityURL.deletingLastPathComponent(), withIntermediateDirectories: true)
    } catch {
      logger.error("Joe says: Failed to create MobileJoe support directory. Error: \(error.localizedDescription)")
    }
  }
}
