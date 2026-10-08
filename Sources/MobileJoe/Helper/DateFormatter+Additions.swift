// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation

extension DateFormatter {
  static let apiDateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    f.timeZone = .utc
    return f
  }()
}
