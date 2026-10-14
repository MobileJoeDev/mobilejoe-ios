// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import SwiftUI
import MobileJoe

public struct FeaturePlanDetailView: View {
  let featurePlan: FeaturePlan
  let featurePlans: FeaturePlans

  @Environment(\.dismiss) private var dismiss

  @State private var error: Error?
  @State private var isLoading = true

  public var body: some View {
    Form {
      VStack(alignment: .leading, spacing: 26) {
        HStack(alignment: .top) {
          VStack(alignment: .leading, spacing: 10) {
            Text(featurePlan.title)
              .font(.title3)
              .fontWeight(.semibold)
              .multilineTextAlignment(.leading)
              .lineLimit(nil)
              .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 10) {
              FeaturePlanStatusView(status: featurePlan.status)
              Text(featurePlan.createdAt, style: .date)
                .foregroundStyle(.secondary)
                .font(.caption)
            }
          }

          Spacer()
          FeaturePlanVoteButton(featurePlan: featurePlan) { vote($0) }
        }

        Text(featurePlan.body)
      }
      .padding(.vertical, 10)
      .frame(maxWidth: .infinity)
    }
    .navigationTitle(String(localized: "feature-plan.detail.title", bundle: .module))
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .automatic) {
        CloseButtonToolbarItem {
          dismiss()
        }
      }
    }
  }

  init(featurePlan: FeaturePlan, featurePlans: FeaturePlans) {
    self.featurePlan = featurePlan
    self.featurePlans = featurePlans
  }
}

extension FeaturePlanDetailView {
  @ViewBuilder
  private func Overlay() -> some View {
    if isLoading {
      ProgressView(String(localized: "feature-plan.detail.loading", bundle: .module))
    } else if error != nil {
      JoeContentUnavailableFailureView()
    }
  }
}

extension FeaturePlanDetailView {
  private func vote(_ featurePlan: FeaturePlan) {
    Task {
      do {
        resetError()
        try await featurePlans.vote(featurePlan)
      } catch {
        self.error = error
      }
    }
  }

  private func resetError() {
    error = nil
  }
}

#Preview {
  let featurePlans = FeaturePlans.preview
  NavigationStack {
    FeaturePlanDetailView(
      featurePlan: featurePlans.all.first!,
      featurePlans: featurePlans
    )
  }
}
