// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation
import OSLog

extension Logger {
  init(category: String) {
    self.init(subsystem: "MobileJoe", category: category)
  }
}
