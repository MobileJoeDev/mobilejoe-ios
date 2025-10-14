//
//  Copyright Bytekontor GmbH. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  AlertDetailsView.swift
//
//  Created by Florian Mielke on 26.09.25.
//

import SwiftUI
import MobileJoe

public struct AlertDetailsView: View {
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
            .foregroundStyle(alert.backgroundColor)

          Text(alert.title)
            .font(.title3)
            .fontWeight(.semibold)

          if let message = alert.message {
            Text(message)
              .frame(maxWidth: .infinity, alignment: .leading)
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
        Button {
          dismiss()
        } label: {
          Image(systemName: "xmark")
        }
      }
    }
  }
}

extension AlertDetailsView {
  private func Footer() -> some View {
    Text(String(localized:"alert.details.occurred:\(alert.occurredAt.formatted(date: .complete, time: .shortened))", bundle: .module))
  }
}

#Preview("Full") {
  NavigationStack {
    AlertDetailsView(alert: AlertsFixture.multiple.all.last!)
  }
}

#Preview("Sheet") {
  Text("")
    .sheet(isPresented: .constant(true)) {
      NavigationStack {
        AlertDetailsView(alert: AlertsFixture.one.all.first!)
      }
    }
}
