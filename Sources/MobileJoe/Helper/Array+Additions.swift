//
//  Copyright Bytekontor GmbH. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  Array+Additions.swift
//
//  Created by Florian on 08.07.25.
//

import Foundation

extension Array where Element: Equatable {
  mutating func replace(_ oldElement: Element, with newElement: Element) throws {
    guard let index = firstIndex(of: oldElement) else { throw Error.unknownElementToReplace }
    remove(at: index)
    insert(newElement, at: index)
  }

  enum Error: Swift.Error {
    case unknownElementToReplace
  }
}
