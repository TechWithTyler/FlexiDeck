//
//  ImportExportManager.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 7/7/25.
//  Copyright © 2024-2025 SheftApps. All rights reserved.
//

import SwiftUI
import SwiftData

class ImportExportManager: ObservableObject {

    // MARK: - Type Aliases

    typealias DeckImportResult = Result<[URL], Error>

    typealias DeckExportResult = Result<URL, Error>

    // MARK: - Properties - Booleans

    @AppStorage(UserDefaults.KeyNames.useFilenameAsImportedDeckName) var useFilenameAsImportedDeckName: Bool = true

    @Published var showingImporter = false

    @Published var showingExporter = false

    @Published var showingError: Bool = false

    @Published var showingImportSuccess: Bool = false

    @Published var showingExportSuccess: Bool = false

    // MARK: - Properties - Strings

    @Published var importSuccessMessage: String = String()

    @Published var exportSuccessMessage: String = String()

    // MARK: - Properties - URLs

    @Published var fileToExport: URL? = nil

    // MARK: - Properties - Decks

    @Published var deckToExport: Deck? = nil

    // MARK: - Properties - Data

    @Published var deckDataToExport: Data? = nil

    // MARK: - Properties - Errors

    @Published var importExportError: DeckImportExportError? = nil

    // MARK: - Show Dialog

    func showDeckImport() {
        // Import is shown before processing any data.
        showingImporter = true
    }

    func showDeckExport(for deck: Deck) {
        // Export needs to encode a deck to data before it can be shown.
        // 1. Try to encode deck to data for export.
        do {
            let data = try encodeDeckForExport(deck)
            // 2. Set the deck and data properties, which are used by the file export dialog.
            deckDataToExport = data
            deckToExport = deck
            // 3. Show the file export dialog.
            showingExporter = true
        } catch let error as NSError {
            // 4. If an error is thrown in step 1, show it.
            importExportError = .exportError(deck, error)
        }
    }

    // MARK: - File Operation Handlers

    func handleDeckImport(result: DeckImportResult, modelContext: ModelContext) {
        // 1. Create a variable to keep track of how many decks were successfully imported. This number will appear in the success dialog which is shown after imports complete or fail, if at least 1 was successfully imported.
        var successfulDeckImportCount = 0
        // 2. Go through each file selected for import.
        switch result {
        case .success(let urls):
            for url in urls {
                // 3. Try to start accessing the security scoped resource.
                let canAccessSecurityScopedResource = url.startAccessingSecurityScopedResource()
                if canAccessSecurityScopedResource {
                do {
                        // 4. If successful, try to load the data from the file.
                        let data = try Data(contentsOf: url)
                        // 5. Try to decode the data into a Deck object.
                        let importedDeck = try decodeDeckForImport(from: data)
                    // 6. If the option to use an imported deck's filename as the deck name is enabled, change the deck name to its filename.
                    if let deckNameFromFilename = url.deletingPathExtension().lastPathComponent.removingPercentEncoding, useFilenameAsImportedDeckName {
                        importedDeck.name = deckNameFromFilename
                    }
                    // 7. Insert the imported deck into the model context.
                    modelContext.insert(importedDeck)
                    // 8. Increment the successful deck import count by 1.
                    successfulDeckImportCount += 1
                        // 9. Stop accessing the security scoped resource now that it's no longer needed.
                        url.stopAccessingSecurityScopedResource()
                } catch let error as NSError {
                    // 10. If any try expression above fails, show an error.
                    importExportError = DeckImportExportError
                        .importError(url, error)
                    showingError = true
                }
                    } else {
                        // 11. If accessing the security scoped resource failed, show an error.
                        importExportError = .securityScopedResourceAccessError(url)
                        showingError = true
                    }
            }
        case .failure(let error as NSError):
            // 12. If the file import result is a failure, show an error.
            importExportError = .urlResultFailure(error)
            showingError = true
        }
        // 13. If at least one deck was successfully imported, show the import success alert. If not, no alert will be presented here--one will have already been presented for each deck that failed to be imported.
        if successfulDeckImportCount > 0 {
            let deckSingularPlural = successfulDeckImportCount == 1 ? "deck has" : "decks have"
            importSuccessMessage = "\(successfulDeckImportCount) \(deckSingularPlural) been successfully imported!"
            showingImportSuccess = true
        }
    }

    func handleDeckExport(deck: Deck?, result: DeckExportResult) {
        // 1. Nil-out the deckDataToExport and fileToExport properties as they're no longer needed.
        deckDataToExport = nil
        fileToExport = nil
        switch result {
        case .success:
        // 2. If the file export was successful, show a success message.
            exportSuccessMessage = "The deck \"\((deck?.name)!)\" has been successfully exported!"
            showingExportSuccess = true
        case .failure(let error as NSError):
        // 3. If the file export failed, show an error.
            showingError = true
            importExportError = .urlResultFailure(error)
        }
    }

    // MARK: - Encoding/Decoding

    // Creates a Deck object (including its cards) from the given Data.
    func decodeDeckForImport(from data: Data) throws -> Deck {
        let decoder = JSONDecoder()
        return try decoder.decode(Deck.self, from: data)
    }

    // Encodes a Deck instance (including its cards) into Data.
    func encodeDeckForExport(_ deck: Deck) throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(deck)
    }

}
