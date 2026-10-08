// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import Testing
@testable import MobileJoe

struct SystemInfoTests {
  @Test
  func `empty preferred languages are omitted`() {
    #expect(SystemInfo.preferredLanguagesHeader(from: []) == nil)
  }

  @Test
  func `preferred languages keep full tags in order`() {
    #expect(SystemInfo.preferredLanguagesHeader(from: ["de-DE", "en-US"]) == "de-DE,en-US")
  }

  @Test
  func `preferred languages are sent in full`() {
    #expect(SystemInfo.preferredLanguagesHeader(from: ["de-DE", "en-US", "fr-FR", "es-ES"]) == "de-DE,en-US,fr-FR,es-ES")
  }
}
