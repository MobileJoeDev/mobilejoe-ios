//
//  Copyright Bytekontor GmbH. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  JoeContentUnavailableView.swift
//
//  Created by Florian on 20.06.25.
//

import SwiftUI

struct JoeContentUnavailableView: View {
  var title: LocalizedStringKey
  var text: LocalizedStringKey

  @ScaledMetric private var joeWidth = 90.0
  @Environment(\.colorScheme) private var colorScheme

  var body: some View {
    ContentUnavailableView {
      Image(.joeSignSorry)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: joeWidth)
        .foregroundStyle(foregroundColor)
      Text(title, bundle: .module)
        .fontWeight(.bold)
        .padding(.top)
    } description: {
      Text(text, bundle: .module)
    }
  }

  private var foregroundColor: Color {
    colorScheme == .dark ? .white : .black
  }
}

struct JoeContentUnavailableFailureView: View {
  var body: some View {
    JoeContentUnavailableView(title: "content-unavailable.failure.title", text: "content-unavailable.failure.text")
  }
}

#Preview {
  JoeContentUnavailableFailureView()
}
