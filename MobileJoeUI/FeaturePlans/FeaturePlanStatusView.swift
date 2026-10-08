// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import SwiftUI
import MobileJoe

struct FeaturePlanStatusView: View {
  let status: FeaturePlan.Status

  var body: some View {
    if let title = status.title {
      Text(title)
        .font(.caption)
        .fontWeight(.medium)
        .foregroundStyle(status.textColor)
        .padding(.vertical, 2)
        .padding(.horizontal, 6)
        .background(status.color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }
  }
}

#Preview {
  FeaturePlanStatusView(status: .unknown)
  FeaturePlanStatusView(status: .open)
  FeaturePlanStatusView(status: .underReview)
  FeaturePlanStatusView(status: .planned)
  FeaturePlanStatusView(status: .inProgress)
  FeaturePlanStatusView(status: .completed)
  FeaturePlanStatusView(status: .closed)
}
