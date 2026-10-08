// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import SwiftUI
import MobileJoe

struct FeaturePlanListRow: View {
  var featurePlan: FeaturePlan
  let vote: (FeaturePlan) -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      HStack(alignment: .top) {
        VStack(alignment: .leading, spacing: 6) {
          Text(featurePlan.title)
            .font(.headline)
            .multilineTextAlignment(.leading)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)

          HStack(spacing: 10) {
            FeaturePlanStatusView(status:  featurePlan.status)
            Text(featurePlan.createdAt, style: .date)
              .foregroundStyle(.secondary)
              .font(.caption)
          }
        }

        Spacer()
        FeaturePlanVoteButton(featurePlan: featurePlan, vote: vote)
      }

      Text(featurePlan.body)
        .lineLimit(2)
    }
    .padding(.vertical, 10)
    .frame(maxWidth: .infinity)
  }
}
