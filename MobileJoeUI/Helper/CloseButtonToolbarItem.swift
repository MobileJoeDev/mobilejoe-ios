// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import SwiftUI

struct CloseButtonToolbarItem: View {
  let close: () -> Void

  var body: some View {
    if #available(iOS 26.0, *) {
      Button(role: .close, action: close)
    } else {
      Button(role: .cancel, action: close) {
        Image(systemName: "xmark.circle.fill")
          .symbolRenderingMode(.hierarchical)
          .foregroundStyle(Color.secondary)
          .font(.title3)
      }
    }
  }
}
