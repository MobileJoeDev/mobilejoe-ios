//
//  Copyright Bytekontor GmbH. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  FeatureRequestListView.swift
//
//  Created by Florian Mielke on 20.03.25.
//

import SwiftUI
import MobileJoe

public struct FeatureRequestListView: View {
  @State var featureRequests: FeatureRequests
  let configuration: Configuration

  @Environment(\.dismiss) private var dismiss
  @State private var error: Error? = nil
  @State private var isLoading = true

  public var body: some View {
    NavigationView {
      List {
        ForEach(featureRequests.all) { featureRequest in
          FeatureRequestListRow(featureRequest: featureRequest) { vote($0) }
        }
      }
      .refreshable {
        await fetchFeatureRequests()
      }
      .overlay {
        Overlay()
      }
      .navigationTitle(String(localized: "feature-request.list.title", bundle: .module))
      .navigationBarTitleDisplayMode(.inline)
      .toolbar(content: ToolbarItems)
    }
    .task {
      await fetchFeatureRequests()
    }
  }

  public init(configuration: Configuration) {
    self.init(featureRequests: FeatureRequests(), configuration: configuration)
  }

  init(featureRequests: FeatureRequests, configuration: Configuration) {
    self.featureRequests = featureRequests
    self.configuration = configuration
  }
}

extension FeatureRequestListView {
  @ToolbarContentBuilder
  private func ToolbarItems() -> some ToolbarContent {
    ToolbarItem(placement: .topBarLeading) {
      Menu {
        Picker(String(localized: "feature-request.list.sorting", bundle: .module), selection: $featureRequests.sorting) {
          ForEach(FeatureRequests.Sorting.allCases) { sorting in
            Label(sorting.title, systemImage: sorting.systemImage)
          }
        }

        Picker(String(localized: "feature-request.list.filtering", bundle: .module), selection: $featureRequests.filtering) {
          ForEach(FeatureRequests.Filter.allCases) { filter in
            Text(filter.title)
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

    if let mailToURL = configuration.mailToURL {
      ToolbarItemGroup(placement: .bottomBar) {
        Spacer()
        Link(destination: mailToURL) {
          Text("feature-request.list.new-feature-request", bundle: .module)
            .font(.footnote)
            .fontWeight(.medium)
        }
        .buttonStyle(.bordered)
        .buttonBorderShape(.capsule)
      }
    }
  }

  @ViewBuilder
  private func Overlay() -> some View {
    if isLoading {
      ProgressView(String(localized: "feature-request.list.loading", bundle: .module))
    } else if error != nil {
      JoeContentUnavailableFailureView()
    } else if featureRequests.all.isEmpty {
      JoeContentUnavailableView(title: "feature-request-list.no-items.title", text: "feature-request-list.no-items.text")
    }
  }
}

extension FeatureRequestListView {
  private func fetchFeatureRequests() async {
    defer { isLoading = false }
    do {
      resetError()
      try await featureRequests.load()
    } catch {
      self.error = error
    }
  }

  private func vote(_ featureRequest: FeatureRequest) {
    resetError()
    Task {
      do {
        try await featureRequests.vote(featureRequest)
      } catch {
        self.error = error
      }
    }
  }

  private func resetError() {
    error = nil
  }
}

#Preview("All") {
  FeatureRequestListView(
    featureRequests: FeatureRequestsFixture.all,
    configuration: FeatureRequestListView.Configuration(recipients: ["support@mobilejoe.dev"])
  )
}

#Preview("Empty") {
  FeatureRequestListView(
    featureRequests: FeatureRequestsFixture.empty,
    configuration: FeatureRequestListView.Configuration(recipients: ["support@mobilejoe.dev"])
  )
}

#Preview("Failure") {
  FeatureRequestListView(
    featureRequests: FeatureRequestsFixture.failedLoading,
    configuration: FeatureRequestListView.Configuration(recipients: ["support@mobilejoe.dev"])
  )
}
