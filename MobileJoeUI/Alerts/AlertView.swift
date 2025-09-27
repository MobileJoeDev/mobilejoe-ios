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

  @State private var showingMessage = false

  var body: some View {
    Button(action: toggleShowingMessage) {
      HStack(alignment: .firstTextBaseline, spacing: 10) {
        Image(systemName: "exclamationmark.triangle")
          .fontWeight(.bold)
        AlertText()
          .multilineTextAlignment(.leading)
      }
      .font(.subheadline)
      .foregroundStyle(alert.foregroundColor)
      .padding(12)
      .padding(.horizontal, 14)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(alert.backgroundColor)
    }
    .sheet(isPresented: $showingMessage) {
      NavigationStack {
        AlertDetailsView(alert: alert)
          .foregroundStyle(Color.primary)
      }
    }
  }
}

extension AlertView {
  private func AlertText() -> Text {
    if let _ = alert.message {
      Text(alert.title) +
      Text(verbatim: " ") +
      Text(Image(systemName: "info.circle"))
        .font(.caption)
    } else {
      Text(alert.title)
    }
  }

  private func toggleShowingMessage() {
    showingMessage.toggle()
  }
}

#Preview {
  AlertView(alert: AlertsFixture.one.all.first!)
}
