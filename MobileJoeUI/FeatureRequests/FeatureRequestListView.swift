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
  @State private var searchText: String = ""

  public var body: some View {
    let _ = Self._printChanges()
    NavigationView {
      List {
        ForEach(featureRequests.all) { featureRequest in
          FeatureRequestListRow(featureRequest: featureRequest) { vote($0) }
            .onAppear {
              loadMoreIfNeeded(featureRequest)
            }
        }
      }
      .refreshable {
        await reload()
      }
      .overlay {
        Overlay()
      }
      .navigationTitle(String(localized: "feature-request.list.title", bundle: .module))
      .navigationBarTitleDisplayMode(.inline)
      .toolbar(content: ToolbarItems)
    }
    .searchable(text: $searchText)
    .onChange(of: searchText) { _, newValue in
      search(for: newValue)
    }
    .task {
      await reload()
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
    ToolbarItem(placement: .topBarTrailing) {
      CloseButtonToolbarItem {
        dismiss()
      }
    }

    ToolbarItemGroup(placement: .bottomBar) {
      ActionMenu()

      Spacer()

      if let mailToURL = configuration.mailToURL {
        Link(destination: mailToURL) {
          Image(systemName: "square.and.pencil")
        }
      }
    }
  }

  private func ActionMenu() -> some View {
    Menu {
      Picker(String(localized: "feature-request.list.sorting", bundle: .module), selection: $featureRequests.sorting) {
        ForEach(FeatureRequest.Sorting.allCases) { sorting in
          Label(sorting.title, systemImage: sorting.systemImage)
        }
      }

      Picker(String(localized: "feature-request.list.filtering", bundle: .module), selection: $featureRequests.filtering) {
        ForEach(FeatureRequests.Filter.allCases) { filter in
          Text(filter.title)
        }
      }
    } label: {
      Label(String(localized: "feature-request.list.sorting", bundle: .module), systemImage: actionMenuSystemImage)
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

  private var actionMenuSystemImage: String {
    if featureRequests.filtering == .all {
      return "line.3.horizontal.decrease.circle"
    } else {
      return "line.3.horizontal.decrease.circle.fill"
    }
  }
}

extension FeatureRequestListView {
  private func loadMoreIfNeeded(_ featureRequest: FeatureRequest) {
    guard featureRequest == featureRequests.all.last else { return }
    Task {
      await load()
    }
  }

  private func load() async {
    defer { isLoading = false }
    do {
      resetError()
      try await featureRequests.load()
    } catch {
      self.error = error
    }
  }

  private func reload() async {
    defer { isLoading = false }
    do {
      resetError()
      try await featureRequests.reload()
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

  private func search(for text: String) {
    Task {
      try? await featureRequests.search(for: text)
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
