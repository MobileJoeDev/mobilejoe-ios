//
//  Copyright Bytekontor GmbH. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  AlertsStackView.swift
//
//  Created by Florian Mielke on 26.09.25.
//

import SwiftUI
import MobileJoe

struct AlertsStackView: View {
  @State var alerts: Alerts

  var body: some View {
    VStack {
      ForEach(alerts.all) { alert in
        AlertView(alert: alert)
          .clipShape(.containerRelative)
      }
    }
    .task {
      try? await alerts.load()
    }
  }
}

#Preview {
  AlertsStackView(alerts: AlertsFixture.multiple)
}
