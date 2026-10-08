// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import SwiftUI

struct JoeContentUnavailableView: View {
  var title: LocalizedStringKey
  var text: LocalizedStringKey

  @ScaledMetric private var joeWidth = 120.0
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
