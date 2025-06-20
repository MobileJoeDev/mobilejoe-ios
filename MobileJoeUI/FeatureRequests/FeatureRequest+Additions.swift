//
//  Copyright Bytekontor GmbH. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  FeatureRequest+Additions.swift
//
//  Created by Florian Mielke on 02.04.25.
//

import SwiftUI
import MobileJoe

extension FeatureRequest {
  var statusColor: Color {
    Color(hex: statusHexColor) ?? .accentColor
  }
}
