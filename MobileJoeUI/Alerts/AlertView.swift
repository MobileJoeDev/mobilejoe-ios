//
//  Copyright Bytekontor GmbH. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  AlertsView.swift
//
//  Created by Florian Mielke on 26.09.25.
//

import SwiftUI
import MobileJoe

struct AlertView: View {
  let alert: MobileJoe.Alert

  var body: some View {
    HStack(alignment: .firstTextBaseline, spacing: 10) {
      Image(systemName: "exclamationmark.triangle")
        .fontWeight(.bold)
        .symbolRenderingMode(.hierarchical)
      VStack(alignment: .leading) {
        if let title = alert.title {
          Text(title)
            .fontWeight(.bold)
        }

        Text(alert.message)
      }
    }
    .font(.subheadline)
    .foregroundStyle(foregroundColor)
    .padding(12)
    .padding(.horizontal, 14)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(backgroundColor)
  }
}

extension AlertView {
  private var backgroundColor: Color {
    switch alert.kind {
    case .info: .warning
    case .warning: .warning
    case .error: .destructive
    }
  }

  private var foregroundColor: Color {
    switch alert.kind {
    case .info: .black
    case .warning: .black
    case .error: .white
    }
  }
}

#Preview {
  AlertView(alert: AlertsFixture.one.all.first!)
}
