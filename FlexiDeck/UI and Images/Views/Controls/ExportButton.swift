//
//  ExportButton.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 7/7/25.
//

import SwiftUI

struct ExportButton: View {

    @EnvironmentObject var importExportManager: ImportExportManager

    var deck: Deck

    var body: some View {
        Button {
            importExportManager.showDeckExport(deck: deck)
        } label: {
            Label("Export Deck…", systemImage: "square.and.arrow.up")
        }
    }

}

#Preview {
    ExportButton(deck: Deck(name: "Deck", newCardsAre2Sided: true))
        .environmentObject(DialogManager())
}
