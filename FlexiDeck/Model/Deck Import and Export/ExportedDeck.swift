//
//  ExportedDeck.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 7/4/25.
//  Copyright © 2024-2026 SheftApps. All rights reserved.
//

// MARK: - Imports

import SwiftUI
import UniformTypeIdentifiers

struct ExportedDeck: FileDocument {

    // MARK: - Properties - Uniform Types

    static var readableContentTypes: [UTType] { [.flexiDeckDeck] }

    // MARK: - Properties - Data

    // The deck data to wrap up into a file.
    var data: Data?

    // MARK: - Initialization

    // Creates an ExportedDeck with the encoded data and corresponding deck.
    init(data: Data?) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        self.data = configuration.file.regularFileContents
    }

    // MARK: - File Wrapper

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        // 1. Make sure we can get the exported deck data. Otherwise, throw an error.
        guard let data = data else {
            throw DeckImportExportError.fileWrapperError
        }
        // 2. Return the FileWrapper with the data.
        return FileWrapper(regularFileWithContents: data)
    }
}
