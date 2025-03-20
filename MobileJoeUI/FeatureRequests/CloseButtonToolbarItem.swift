//
//  File.swift
//  MobileJoe
//
//  Created by Florian on 20.03.25.
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
