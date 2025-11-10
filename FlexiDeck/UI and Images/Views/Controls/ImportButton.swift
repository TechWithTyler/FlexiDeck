//
//  ImportButton.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 7/9/25.
//

// MARK: - Imports

import SwiftUI

struct ImportButton: View {

    // MARK: - Properties - Import/Export Manager

    @EnvironmentObject var importExportManager: ImportExportManager

    // MARK: - Body

    var body: some View {
        Button {
            importExportManager.showDeckImport()
        } label: {
            Label("Import Decks…", systemImage: "square.and.arrow.down")
        }
    }

}

// MARK: - Preview

#Preview {
    ImportButton()
}
