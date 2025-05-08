//
//  Copyright Florian Mielke. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  FeatureRequestListView.swift
//
//  Created by Florian on 20.03.25.
//

import SwiftUI
import MobileJoe

public struct FeatureRequestListView: View {
  @State var featureRequests: FeatureRequests

  @Environment(\.dismiss) private var dismiss
  @State private var error: Error? = nil

  public var body: some View {
    NavigationView {
      List {
        ForEach(featureRequests.all) { feature in
          FeatureRequestListRow(feature: feature) { vote($0) }
        }
      }
      .navigationTitle(String(localized: "feature-request.list.title", bundle: .module))
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Menu {
            Picker(String(localized: "feature-request.list.sorting", bundle: .module), selection: $featureRequests.sorting) {
              ForEach(FeatureRequests.Sorting.allCases) { sorting in
                Label(sorting.title, systemImage: sorting.systemImage)
              }
            }
          } label: {
            Label(String(localized: "feature-request.list.sorting", bundle: .module), systemImage: "line.3.horizontal.decrease.circle")
          }
        }

        ToolbarItem(placement: .topBarTrailing) {
          CloseButtonToolbarItem {
            dismiss()
          }
        }

        ToolbarItemGroup(placement: .bottomBar) {
          Spacer()
          Link(destination: URL(string: "mailto:support@worktimes.app?subject=Feature%20Request")!) {
            Text("New Feature Request")
              .fontWeight(.medium)
          }
          .buttonStyle(.bordered)
          .clipShape(.capsule)
        }
      }
    }
    .task {
      await fetchFeatureRequests()
    }
  }

  public init() {
    self.init(featureRequests: FeatureRequests())
  }

  init(featureRequests: FeatureRequests) {
    self.featureRequests = featureRequests
  }
}

extension FeatureRequestListView {
  private func fetchFeatureRequests() async {
    do {
      try await featureRequests.load()
    } catch {
      self.error = error
    }
  }

  private func vote(_ featureRequest: FeatureRequest) {
    Task {
      do {
        try await featureRequests.vote(featureRequest)
      } catch {
        self.error = error
      }
    }
  }
}

#Preview {
  FeatureRequestListView(featureRequests: FeatureRequestsFixture())
}
