// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation

final class IdentityOperationQueue {
  enum Operation: Equatable {
    case configuration
    case identification(String?)
    case logout
  }

  private var tail: (id: UUID, operation: Operation, task: Task<Void, Error>)?

  func enqueue(_ operation: Operation, perform: @escaping @MainActor () async throws -> Void) -> Task<Void, Error> {
    if case .identification = operation, let tail, tail.operation == operation {
      return tail.task
    }
    let predecessor = tail?.task
    let id = UUID()
    let task = Task {
      // Failure belongs to that operation's callers; later operations can retry.
      _ = await predecessor?.result
      defer {
        if self.tail?.id == id { self.tail = nil }
      }
      try await perform()
    }
    tail = (id, operation, task)
    return task
  }
}
