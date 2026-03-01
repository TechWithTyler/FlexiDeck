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
import UniformTypeIdentifiers

class ImportExportManager: ObservableObject {

    // MARK: - Result Type Aliases

    // The type of deck import results. Import can accept multiple file URLs. Success is the array of file URLs to create Deck objects from.
    typealias DeckImportResult = Result<[URL], Error>

    // The type of deck export results. Export can only accept a single file URL. Success is the file URL to be exported.
    typealias DeckExportResult = Result<URL, Error>

    // MARK: - Properties - Booleans

    @AppStorage(UserDefaults.KeyNames.useFilenameAsImportedDeckName) var useFilenameAsImportedDeckName: Bool = true

    // Whether the file importer should be/is being displayed.
    @Published var showingImporter = false

    // Whether the file exporter should be/is being displayed.
    @Published var showingExporter = false

    @Published var hoveringItemOverDeckList: Bool = false

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
        let decodedDeck = try decoder.decode(Deck.self, from: data)
        return decodedDeck
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
        } catch {
            // 4. If an error is thrown in step 1, show it.
            importExportError = .exportPrepError(deck, error)
        }
    }

    // MARK: - File Operation Handlers

    // This method imports the selected decks.
    func handleDeckImportFromFiles(result: DeckImportResult, modelContext: ModelContext) {
        // 1. Create a variable to keep track of how many decks were successfully imported. This number will appear in the success dialog which is shown after imports complete or fail, if at least 1 was successfully imported.
        var successfulDeckImportCount = 0
        // 2. Try to import each file selected for import, showing errors for any failed imports.
        switch result {
        case .success(let fileURLs):
            for fileURL in fileURLs {
                let success = importDeckFromFile(at: fileURL, to: modelContext)
                if success {
                    successfulDeckImportCount += 1
                }
            }
        case .failure(let error):
            // 3. If the file import result is a failure, show an error.
            importExportError = .importErrorNoURL(error)
            showingError = true
        }
        // 4. If at least one deck was successfully imported, show the import success alert. If not, no alert will be presented here--an alert will have already been presented for each deck that failed to be imported.
        if successfulDeckImportCount > 0 {
            let deckSingularOrPlural = successfulDeckImportCount == 1 ? "deck has" : "decks have"
            importSuccessMessage = "\(successfulDeckImportCount) \(deckSingularOrPlural) been successfully imported!"
            showingImportSuccess = true
        }
    }

    // This method imports the deck from fileURL.
    func importDeckFromFile(at fileURL: URL, to modelContext: ModelContext) -> Bool {
        // 1. Try to start accessing the security-scoped resource.
        let canAccessSecurityScopedResource = fileURL.startAccessingSecurityScopedResource()
        if canAccessSecurityScopedResource {
            do {
                // 2. If successful, try to load the data from the file.
                let data = try Data(contentsOf: fileURL)
                // 3. Try to decode the data into a Deck object.
                let importedDeck = try decodeDeckForImport(from: data)
                // 4. If the option to use an imported deck's filename as the deck name is enabled, change the deck name to its filename.
                if let deckNameFromFilename = fileURL.deletingPathExtension().lastPathComponent.removingPercentEncoding, useFilenameAsImportedDeckName {
                    importedDeck.name = deckNameFromFilename
                }
                // 5. Insert the imported deck into the model context.
                modelContext.insert(importedDeck)
                // 6. Stop accessing the security-scoped resource now that it's no longer needed.
                fileURL.stopAccessingSecurityScopedResource()
                return true
            } catch {
                // 7. If any try expression above fails, show an error.
                importExportError = DeckImportExportError
                    .importErrorURL(fileURL, error)
                showingError = true
                return false
            }
        } else {
            // 8. If accessing the security-scoped resource failed, show an error.
            importExportError = .securityScopedResourceAccessError(fileURL)
            showingError = true
            return false
        }
    }

    // This method exports deck.
    func handleDeckExportToFile(deck: Deck?, result: DeckExportResult) {
        // 1. Nil-out the deckDataToExport and fileToExport properties as they're no longer needed.
        deckDataToExport = nil
        fileToExport = nil
        guard let deck = deck else {
            return
        }
        switch result {
        case .success:
            // 2. If the file export was successful, show a success message.
            exportSuccessMessage = "The deck \"\((deck.name)!)\" has been successfully exported!"
            showingExportSuccess = true
        case .failure(let error):
            // 3. If the file export failed, show an error.
            showingError = true
            importExportError = .exportError(deck, error)
        }
    }

    // MARK: - Drag-and-Drop

    // This method handles dropping of decks for import.
    func handleDroppedDecks(with providers: [NSItemProvider], modelContext: ModelContext) -> Bool {
        // 1. For each provider, try to have it load deck data. If unsuccessful, show an error.
        let deckTypeIdentifier = UTType.flexiDeckDeck.identifier
        for provider in providers {
            provider.loadFileRepresentation(forTypeIdentifier: deckTypeIdentifier) { [self] url, error in
                handleDeckDropImportResult(from: url, error: error, modelContext: modelContext)
            }
        }
        // 2. Return whether the drop was successful. This is determined by whether the error alert is being displayed.
        return !showingError
    }

    // This method handles the result of dropping a deck for import.
    func handleDeckDropImportResult(from fileURL: URL?, error: Error?, modelContext: ModelContext) {
        // 1. If there's a URL, try to convert it into data and decode the deck for import. If that fails, show an error.
        // While we can simply import as data, importing as a file allows the imported deck's name to be that of the file being imported. The item provider converts the encoded deck data into a temporary file located in the user's temporary directory and imports that file, so the dragged item doesn't have to be a file itself.
        if let fileURL = fileURL {
            do {
                let data = try Data(contentsOf: fileURL)
                let importedDeck = try decodeDeckForImport(from: data)
                if let deckNameFromFilename = fileURL.deletingPathExtension().lastPathComponent.removingPercentEncoding, useFilenameAsImportedDeckName {
                    importedDeck.name = deckNameFromFilename
                }
                DispatchQueue.main.async {
                    modelContext.insert(importedDeck)
                }
            } catch {
                DispatchQueue.main.async { [self] in
                    importExportError = .importErrorDrop(error)
                    showingError = true
                }
            }
        } else if let error = error {
            // 2. If there's no data, show an error.
            DispatchQueue.main.async { [self] in
                importExportError = .importErrorDrop(error)
                showingError = true
            }
        } else {
            // 3. If there's no data or explicit error, show a generic "no deck data" error.
            DispatchQueue.main.async { [self] in
                importExportError = .noDeckDataDrop
                showingError = true
            }
        }
    }

    // This method exports the dragged deck.
    func exportDeck(_ deck: Deck) -> NSItemProvider {
        // 1. Define the filename for the exported deck. The filename is the deck's name.
        let filename = deck.name
        // 2. Create an NSItemProvider that provides deck data. This sets the file extension to ".flexideck".
        let itemProvider = NSItemProvider()
        do {
            let data = try encodeDeckForExport(deck)
            let deckTypeIdentifier = UTType.flexiDeckDeck.identifier
            itemProvider.registerDataRepresentation(forTypeIdentifier: deckTypeIdentifier, visibility: .all) { completion in
                completion(data, nil)
                return nil
            }
            // 3. Set the filename for the exported deck.
            itemProvider.suggestedName = filename
        } catch {
            importExportError = .exportError(deck, error)
            showingError = true
        }
        // 4. Return the provider.
        return itemProvider
    }

}

