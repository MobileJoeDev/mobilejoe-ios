// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation

extension Array where Element: Equatable {
  mutating func replace(_ oldElement: Element, with newElement: Element) throws {
    guard let index = firstIndex(of: oldElement) else { throw ArrayError.unknownElementToReplace }
    remove(at: index)
    insert(newElement, at: index)
  }
}

enum ArrayError: Error {
  case unknownElementToReplace
}
