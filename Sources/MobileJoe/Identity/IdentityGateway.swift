//
//  File.swift
//  MobileJoe
//
//  Created by Florian on 11.05.25.
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
  
  private static let identityURL = URL.applicationSupportDirectory.appending(path: "identity.mbj")
  private let logger: Logger
  private let fileCoordinator: NSFileCoordinator
  
  private init() {
    self.fileCoordinator = NSFileCoordinator()
    self.logger = Logger(subsystem: "MobileJoe", category: "FileBasedIdentityGateway")
  }
  
  func find() async throws -> Identity? {
    var error: NSError? = nil
    var identity: Identity?
    fileCoordinator.coordinate(readingItemAt: Self.identityURL, error: &error) { url in
      do {
        let identityData = try Data(contentsOf: url)
        identity = try JSONDecoder().decode(Identity.self, from: identityData)
      } catch {
        logger.error("Failed to find identity file. Error: \(error.localizedDescription)")
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
        try identityData.write(to: url, options: .atomic)
      } catch {
        logger.error("Failed to save identity file. Error: \(error.localizedDescription)")
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
        try FileManager.default.removeItem(at: url)
      } catch {
        logger.error("Failed to delete identity file. Error: \(error.localizedDescription)")
      }
    }
    
    if let error {
      throw error
    }
  }
}
