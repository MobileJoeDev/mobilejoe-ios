//
//  Copyright Bytekontor GmbH. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  CloseButtonToolbarItem.swift
//
//  Created by Florian Mielke on 20.03.25.
//

import SwiftUI

struct CloseButtonToolbarItem: View {
  let close: () -> Void

  var body: some View {
    Button(action: close) {
      Image(systemName: "xmark.circle.fill")
        .symbolRenderingMode(.hierarchical)
        .foregroundStyle(Color.secondary)
        .font(.title3)
    }
  }
}
