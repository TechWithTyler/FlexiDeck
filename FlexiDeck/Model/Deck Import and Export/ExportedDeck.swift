//
//  ExportedDeck.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 7/4/25.
//  Copyright © 2024-2025 SheftApps. All rights reserved.
//

// MARK: - Imports

import SwiftUI
import UniformTypeIdentifiers

struct ExportedDeck: FileDocument {

    // MARK: - Properties - Uniform Types

    static var readableContentTypes: [UTType] { [.flexiDeckDeck] }

    // MARK: - Properties - Data

    var data: Data?

    // MARK: - Properties - Deck

    var deck: Deck?

    // MARK: - Initialization

    init(data: Data?, deck: Deck?) {
        self.data = data
        self.deck = deck
    }

    init(configuration: ReadConfiguration) throws {
        self.data = configuration.file.regularFileContents
    }

    // MARK: - File Wrapper

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        // Make sure we can get the exported deck data. Otherwise, throw an error.
        guard let data = data else {
            throw DeckImportExportError.fileWrapperError(deck)
        }
        return FileWrapper(regularFileWithContents: data)
    }
}
