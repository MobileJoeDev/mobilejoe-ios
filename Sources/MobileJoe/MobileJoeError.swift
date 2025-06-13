//
//  Copyright Florian Mielke. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  MobileJoeError.swift
//
//  Created by Florian Mielke on 20.03.25.
//

import Foundation

enum MobileJoeError: Error, LocalizedError {
  case generic(String)

  var errorDescription: String? {
    switch self {
    case .generic(let string):
      return string
    }
  }
}
