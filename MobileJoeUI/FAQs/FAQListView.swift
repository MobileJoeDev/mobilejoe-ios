// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import SwiftUI
import MobileJoe

struct FAQListView: View {
  @State var faqs: FAQs
  let presentationMode: PresentationMode
  let configuration: FAQView.Configuration

  @Environment(\.dismiss) private var dismiss
  @State private var error: Error? = nil
  @State private var isLoading = true

  var body: some View {
    List {
      Section {
        ForEach(faqs.all) { faqItem in
          NavigationLink {
            FAQDetailView(faqItem: faqItem, configuration: configuration)
          } label: {
            FAQListRow(faqItem: faqItem)
          }
        }
      }

      if !faqs.isEmpty, let mailToURL = configuration.mailToURL {
        Section {
          FAQContactSupportView(configuration: configuration, mailToURL: mailToURL)
            .padding(.vertical, 8)
        }
      }
    }
    .refreshable {
      await reload()
    }
    .overlay {
      Overlay()
    }
    .navigationTitle(String(localized: "faq.list.title", bundle: .module))
    .navigationBarTitleDisplayMode(.inline)
    .toolbar(content: ToolbarItems)
    .task {
      await reload()
    }
  }

  init(faqs: FAQs, presentationMode: PresentationMode, configuration: FAQView.Configuration) {
    _faqs = State<FAQs>(wrappedValue: faqs)
    self.presentationMode = presentationMode
    self.configuration = configuration
  }
}

extension FAQListView {
  @ToolbarContentBuilder
  private func ToolbarItems() -> some ToolbarContent {
    if presentationMode == .asSheet {
      ToolbarItem(placement: .topBarTrailing) {
        CloseButtonToolbarItem {
          dismiss()
        }
      }
    }
  }

  @ViewBuilder
  private func Overlay() -> some View {
    if isLoading {
      ProgressView(String(localized: "faq.list.loading", bundle: .module))
    } else if faqs.isEmpty {
      if error != nil {
        JoeContentUnavailableFailureView()
      } else {
        JoeContentUnavailableView(title: "faq-list.no-items.title", text: "faq-list.no-items.text")
      }
    }
  }
}

extension FAQListView {
  private func reload() async {
    defer { isLoading = false }
    do {
      resetError()
      try await faqs.load()
    } catch {
      self.error = error
    }
  }

  private func resetError() {
    error = nil
  }
}
