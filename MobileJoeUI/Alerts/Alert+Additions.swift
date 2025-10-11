//
//  Copyright Bytekontor GmbH. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  Alert+Additions.swift
//
//  Created by Florian Mielke on 27.09.25.
//

import SwiftUI
import MobileJoe

extension MobileJoe.Alert {
  var backgroundColor: Color {
    switch kind {
    case .info: .warning
    case .warning: .warning
    case .error: .destructive
    }
  }

  var foregroundColor: Color {
    switch kind {
    case .info: .black
    case .warning: .black
    case .error: .white
    }
  }
}
