// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import SwiftUI
import MobileJoe

@MainActor
extension MobileJoe.Alert {
  var backgroundColor: Color {
    switch kind {
    case .warning: .warning
    case .error: .destructive
    }
  }

  var foregroundColor: Color {
    switch kind {
    case .warning: .black
    case .error: .white
    }
  }

  var secondaryColor: Color {
    switch kind {
    case .warning: .warningSecondary
    case .error: .destructiveSecondary
    }
  }

  var tertiaryColor: Color {
    switch kind {
    case .warning: .warningSecondary
    case .error: .destructive
    }
  }
}
