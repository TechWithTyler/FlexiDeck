//
//  ImportButton.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 7/9/25.
//

import SwiftUI

struct ImportButton: View {

    @EnvironmentObject var importExportManager: ImportExportManager

    var body: some View {
        Button {
            importExportManager.showDeckImport()
        } label: {
            Label("Import Deck…", systemImage: "square.and.arrow.down")
        }
    }

}

#Preview {
    ImportButton()
}
