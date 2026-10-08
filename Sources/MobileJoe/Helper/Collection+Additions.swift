// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation

nonisolated extension Collection {
  public var isNotEmpty: Bool {
    isEmpty == false
  }
}
