//
//  ExportedDeck.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 7/4/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct ExportedDeck: FileDocument {

    static var readableContentTypes: [UTType] { [.deck] }

    var data: Data?

    var deck: Deck?

    init(data: Data?, deck: Deck?) {
        self.data = data
        self.deck = deck
    }

    init(configuration: ReadConfiguration) throws {
        self.data = configuration.file.regularFileContents
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        guard let data = data else {
            throw DeckImportExportError.fileWrapperError(deck)
        }
        return FileWrapper(regularFileWithContents: data)
    }
}
