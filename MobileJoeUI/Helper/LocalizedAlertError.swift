//
//  LocalizedAlertError.swift
//  MobileJoe
//
//  Created by Florian on 08.05.25.
//

import Foundation

struct LocalizedAlertError: LocalizedError {
  let underlyingError: LocalizedError
  var errorDescription: String? {
    underlyingError.errorDescription
  }
  var recoverySuggestion: String? {
    underlyingError.recoverySuggestion
  }

  init?(error: Error?) {
    guard let localizedError = error as? LocalizedError else { return nil }
    underlyingError = localizedError
  }
}
