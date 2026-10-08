// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import SwiftUI
import MobileJoe

public struct AlertView: View {
  let alert: MobileJoe.Alert

  @State private var showingDetails = false

  public var body: some View {
    Button(action: toggleShowingDetails) {
      HStack {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
          Image(systemName: "exclamationmark.triangle.fill")
            .foregroundStyle(alert.secondaryColor)
          Text(alert.title)
            .multilineTextAlignment(.leading)
        }

        Spacer()
        Image(systemName: "chevron.right")
      }
      .font(.subheadline)
      .foregroundStyle(alert.foregroundColor)
      .padding(12)
      .padding(.horizontal, 8)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(alert.backgroundColor)
    }
    .sheet(isPresented: $showingDetails) {
      NavigationStack {
        AlertDetailView(alert: alert)
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
