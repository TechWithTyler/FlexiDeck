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

    // MARK: - Properties - Objects

    @EnvironmentObject var importExportManager: ImportExportManager

    var deck: Deck

    // MARK: - Body

    var body: some View {
        Button {
            importExportManager.showDeckExport(for: deck)
        } label: {
            Label("Export Deck…", systemImage: "square.and.arrow.up")
        }
    }

}

// MARK: - Preview

#Preview {
    ExportButton(deck: Deck(name: "Deck", newCardsAre2Sided: true))
        .environmentObject(DialogManager())
}
