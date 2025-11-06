//
//  ExportButton.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 7/7/25.
//  Copyright © 2024-2025 SheftApps. All rights reserved.
//

// MARK: - Imports

import SwiftUI

struct ExportButton: View {

    @EnvironmentObject var importExportManager: ImportExportManager

    var deck: Deck

    var body: some View {
        Button {
            importExportManager.showDeckExport(for: deck)
        } label: {
            Label("Export Deck…", systemImage: "square.and.arrow.up")
        }
    }

}

#Preview {
    ExportButton(deck: Deck(name: "Deck", newCardsAre2Sided: true))
        .environmentObject(DialogManager())
}
