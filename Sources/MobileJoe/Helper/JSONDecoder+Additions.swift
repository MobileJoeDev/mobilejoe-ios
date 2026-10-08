// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Foundation

extension JSONDecoder {
  static let shared: JSONDecoder = {
    let d = JSONDecoder()
    d.dateDecodingStrategy = .formatted(.apiDateFormatter)
    return d
  }()
}
