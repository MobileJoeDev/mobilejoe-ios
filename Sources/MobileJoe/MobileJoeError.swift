//
//  MobileJoeError.swift
//  MobileJoe
//
//  Created by Florian on 20.03.25.
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
