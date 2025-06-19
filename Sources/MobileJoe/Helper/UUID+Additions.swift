//
//  Copyright Bytekontor GmbH. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  UUID+Additions.swift
//
//  Created by Florian Mielke on 11.05.25.
//

import Foundation

extension UUID {
  /// Returns a compact string representation of the UUID without hyphens and in lowercase
  var compactString: String {
    uuidString.replacingOccurrences(of: "-", with: "").lowercased()
  }
}
