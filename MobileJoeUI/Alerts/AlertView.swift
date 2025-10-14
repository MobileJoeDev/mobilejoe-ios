//
//  Copyright Bytekontor GmbH. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  AlertView.swift
//
//  Created by Florian Mielke on 26.09.25.
//

import SwiftUI
import MobileJoe

public struct AlertView: View {
  let alert: MobileJoe.Alert

  @State private var showingDetails = false

  public var body: some View {
    Button(action: toggleShowingDetails) {
      HStack {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
          Image(systemName: "exclamationmark.triangle")
            .fontWeight(.bold)
          Text(alert.title)
            .multilineTextAlignment(.leading)
        }

        Spacer()
        Image(systemName: "chevron.right")
      }
      .font(.subheadline)
      .foregroundStyle(alert.foregroundColor)
      .padding(12)
      .padding(.horizontal, 14)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(alert.backgroundColor)
    }
    .sheet(isPresented: $showingDetails) {
      NavigationStack {
        AlertDetailsView(alert: alert)
          .foregroundStyle(Color.primary)
      }
    }
  }

  public init(alert: MobileJoe.Alert) {
    self.alert = alert
  }
}

extension AlertView {
  private func toggleShowingDetails() {
    showingDetails.toggle()
  }
}

#Preview {
  AlertView(alert: AlertsFixture.one.all.first!)
}
