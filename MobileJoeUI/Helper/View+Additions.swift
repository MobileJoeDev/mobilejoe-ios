// Copyright Bytekontor GmbH.
// Licensed under the MIT License. See LICENSE for details.

import SwiftUI

extension View {
    @ViewBuilder func minimizedSearch() -> some View {
        if #available(iOS 26.0, *) {
            self.searchToolbarBehavior(.minimize)
        } else { self }
    }
}
