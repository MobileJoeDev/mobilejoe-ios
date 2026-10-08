// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import SwiftUI
import MobileJoe

public struct AlertDetailView: View {
  let alert: MobileJoe.Alert

  @Environment(\.dismiss) private var dismiss

  public var body: some View {
    List {
      Section(footer: Footer()) {
        VStack(spacing: 16) {
          Image(systemName: "exclamationmark.triangle.fill")
            .symbolRenderingMode(.hierarchical)
            .fontWeight(.bold)
            .font(.system(size: 60.0))
            .foregroundStyle(alert.tertiaryColor)

          VStack(alignment: .leading, spacing: 16) {
            Text(alert.title)
              .font(.title3)
              .fontWeight(.semibold)

            if let message = alert.message {
              Text(message)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
          }
        }
        .padding(8)
        .frame(maxWidth: .infinity)
      }
    }
    .presentationDetents([.medium])
    .presentationDragIndicator(.visible)
    .toolbar {
      ToolbarItem(placement: .cancellationAction) {
        CloseButtonToolbarItem {
          dismiss()
        }
      }
    }
  }
}

extension AlertDetailView {
  private func Footer() -> some View {
    Text(String(localized:"alert.details.occurred:\(alert.occurredAt.formatted(date: .complete, time: .shortened))", bundle: .module))
      .padding(.leading, 10)
  }
}

#Preview("Full") {
  NavigationStack {
    AlertDetailView(alert: Alerts.preview.all.last!)
  }
}
