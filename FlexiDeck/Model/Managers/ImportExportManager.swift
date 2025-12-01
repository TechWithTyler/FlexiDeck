//
//  ImportExportManager.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 7/7/25.
//  Copyright © 2024-2026 SheftApps. All rights reserved.
//

// MARK: - Imports

import SwiftUI
import SwiftData

class ImportExportManager: ObservableObject {

    // MARK: - Type Aliases

    // The type of deck import results. Import can accept multiple file URLs.
    typealias DeckImportResult = Result<[URL], Error>

    // The type of deck export results. Export can only accept a single file URL.
    typealias DeckExportResult = Result<URL, Error>

    // MARK: - Properties - Booleans

    @AppStorage(UserDefaults.KeyNames.useFilenameAsImportedDeckName) var useFilenameAsImportedDeckName: Bool = true

    // Whether the file importer should be/is being displayed.
    @Published var showingImporter = false

    // Whether the file exporter should be/is being displayed.
    @Published var showingExporter = false

    // Whether an error should be/is being displayed.
    @Published var showingError: Bool = false

    // Whether the import success message should be/is being displayed.
    @Published var showingImportSuccess: Bool = false

    // Whether the export success message should be/is being displayed.
    @Published var showingExportSuccess: Bool = false

    // MARK: - Properties - Strings

    // The message to display in the import success alert.
    @Published var importSuccessMessage: String = String()

    // The message to display in the export success message.
    @Published var exportSuccessMessage: String = String()

    // MARK: - Properties - Decks

    // The deck to export.
    @Published var deckToExport: Deck? = nil

    // MARK: - Properties - Data

    // The deck to export, encoded into data for export.
    @Published var deckDataToExport: Data? = nil

    // MARK: - Properties - URLs

    // The file to export after the deck data to export has been wrapped up in it.
    @Published var fileToExport: URL? = nil

    // MARK: - Properties - Errors

    // The error to be shown in the import/export error dialog.
    @Published var importExportError: DeckImportExportError? = nil

    // MARK: - Encoding/Decoding

    // This method creates a Deck object (including its cards) from the given Data. Decoding is performed after importing a file.
    func decodeDeckForImport(from data: Data) throws -> Deck {
        let decoder = JSONDecoder()
        return try decoder.decode(Deck.self, from: data)
    }

    // This method encodes a Deck instance (including its cards) into Data. Encoding is performed before the file exporter for a file is shown.
    func encodeDeckForExport(_ deck: Deck) throws -> Data {
        let encoder = JSONEncoder()
        let encodedDeck = try encoder.encode(deck)
        deckToExport = deck
        return encodedDeck
    }

    // MARK: - Show Dialog

    // This method shows the deck import dialog.
    func showDeckImport() {
        // Import is shown before processing any data.
        showingImporter = true
    }

    // This method encodes deck, then shows the export dialog if successful.
    func showDeckExport(for deck: Deck) {
        // Export needs to encode a deck to data before it can be shown.
        // 1. Try to encode deck to data for export.
        do {
            let data = try encodeDeckForExport(deck)
            // 2. Set the data property, which is used by the file export dialog.
            deckDataToExport = data
            // 3. Show the file export dialog.
            showingExporter = true
        } catch let error as NSError {
            // 4. If an error is thrown in step 1, show it.
            importExportError = .exportError(deck, error)
        }
    }

    // MARK: - File Operation Handlers

    // This method imports the selected decks.
    func handleDeckImport(result: DeckImportResult, modelContext: ModelContext) {
        // 1. Create a variable to keep track of how many decks were successfully imported. This number will appear in the success dialog which is shown after imports complete or fail, if at least 1 was successfully imported.
        var successfulDeckImportCount = 0
        // 2. Go through each file selected for import.
        switch result {
        case .success(let fileURLs):
            for fileURL in fileURLs {
                // 3. Try to start accessing the security-scoped resource.
                let canAccessSecurityScopedResource = fileURL.startAccessingSecurityScopedResource()
                if canAccessSecurityScopedResource {
                do {
                        // 4. If successful, try to load the data from the file.
                        let data = try Data(contentsOf: fileURL)
                        // 5. Try to decode the data into a Deck object.
                        let importedDeck = try decodeDeckForImport(from: data)
                    // 6. If the option to use an imported deck's filename as the deck name is enabled, change the deck name to its filename.
                    if let deckNameFromFilename = fileURL.deletingPathExtension().lastPathComponent.removingPercentEncoding, useFilenameAsImportedDeckName {
                        importedDeck.name = deckNameFromFilename
                    }
                    // 7. Insert the imported deck into the model context.
                    modelContext.insert(importedDeck)
                    // 8. Increment the successful deck import count by 1.
                    successfulDeckImportCount += 1
                        // 9. Stop accessing the security-scoped resource now that it's no longer needed.
                        fileURL.stopAccessingSecurityScopedResource()
                } catch let error as NSError {
                    // 10. If any try expression above fails, show an error.
                    importExportError = DeckImportExportError
                        .importError(fileURL, error)
                    showingError = true
                }
                    } else {
                        // 11. If accessing the security-scoped resource failed, show an error.
                        importExportError = .securityScopedResourceAccessError(fileURL)
                        showingError = true
                    }
            }
        case .failure(let error as NSError):
            // 12. If the file import result is a failure, show an error.
            importExportError = .fileImportURLResultFailure(error)
            showingError = true
        }
        // 13. If at least one deck was successfully imported, show the import success alert. If not, no alert will be presented here--one will have already been presented for each deck that failed to be imported.
        if successfulDeckImportCount > 0 {
            let deckSingularOrPlural = successfulDeckImportCount == 1 ? "deck has" : "decks have"
            importSuccessMessage = "\(successfulDeckImportCount) \(deckSingularOrPlural) been successfully imported!"
            showingImportSuccess = true
        }
    }

    // This method exports deck.
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
            importExportError = .fileImportURLResultFailure(error)
        }
    }

}
