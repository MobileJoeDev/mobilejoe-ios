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

struct LocalizedAlertError: LocalizedError {
  let underlyingError: LocalizedError
  var errorDescription: String? {
    underlyingError.errorDescription
  }
  var recoverySuggestion: String? {
    underlyingError.recoverySuggestion
  }

  init?(error: Error?) {
    guard let localizedError = error as? LocalizedError else { return nil }
    underlyingError = localizedError
  }
}

public struct FeatureRequestListView: View {
  @State var featureRequests: FeatureRequests
  let configuration: Configuration

  @Environment(\.dismiss) private var dismiss
  @State private var error: Error? = nil
  @State private var isLoading = false

  public var body: some View {
    NavigationView {
      List {
        ForEach(featureRequests.all) { feature in
          FeatureRequestListRow(feature: feature) { vote($0) }
        }
      }
      .overlay {
        Overlay()
      }
      .navigationTitle(String(localized: "feature-request.list.title", bundle: .module))
      .navigationBarTitleDisplayMode(.inline)
      .toolbar(content: ToolbarItems)
    }
    .errorAlert(error: $error)
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

  private var showingError: Binding<Bool> {
    return .init {
      self.error != nil
    } set: { newValue in
      if !newValue {
        self.error = nil
      }
    }
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
  func Overlay() -> some View {
    if isLoading {
      ProgressView(String(localized: "feature-request.list.loading", bundle: .module))
    } else if featureRequests.all.isEmpty {
      NoFeatureRequestsView()
    }
  }

  func NoFeatureRequestsView() -> some View {
    ContentUnavailableView(
      String(localized: "feature-request-list.no-items.title", bundle: .module),
      systemImage: "magnifyingglass",
      description: Text("feature-request-list.no-items.text", bundle: .module)
    )
  }
}

extension FeatureRequestListView {
  private func fetchFeatureRequests() async {
    do {
      isLoading = true
      try await featureRequests.load()
      isLoading = false
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

extension View {
  func errorAlert(error: Binding<Error?>) -> some View {
    let localizedAlertError = LocalizedAlertError(error: error.wrappedValue)
    return alert(isPresented: .constant(localizedAlertError != nil), error: localizedAlertError) { _ in
      Button {
        error.wrappedValue = nil
      } label: {
        Text("OK", bundle: .module)
      }
    } message: { error in
      Text(error.recoverySuggestion ?? "")
    }
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
