//
//  ImportExportManager.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 7/7/25.
//

import SwiftUI
import SwiftData

class ImportExportManager: ObservableObject {

    // MARK: - Typealiases

    typealias DeckImportResult = Result<[URL], Error>

    typealias DeckExportResult = Result<URL, Error>

    // MARK: - Properties - Booleans

    @AppStorage(UserDefaults.KeyNames.useFilenameAsImportedDeckName) var useFilenameAsImportedDeckName: Bool = true

    @Published var showingImporter = false

    @Published var showingExporter = false

    @Published var showingImportExportError: Bool = false

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
        showingImporter = true
    }

    func showDeckExport(deck: Deck) {
        do {
            let data = try encodeDeckForExport(deck)
            deckDataToExport = data
            showingExporter = true
            deckToExport = deck
        } catch let error as NSError {
            importExportError = DeckImportExportError.exportError(deck, error)
        }
    }

    // MARK: - File Operation Handlers

    func handleDeckImport(result: DeckImportResult, modelContext: ModelContext) {
        // 1. Create a variable to keep track of how many decks were successfully imported.
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
                        let importedDeck = try importDeck(from: data)
                        // 6. Insert the imported deck into the model context, using its filename without the extension.
                    if let deckNameFromFilename = url.deletingPathExtension().lastPathComponent.removingPercentEncoding, useFilenameAsImportedDeckName {
                        importedDeck.name = deckNameFromFilename
                    }
                    modelContext.insert(importedDeck)
                    successfulDeckImportCount += 1
                        // 7. Stop accessing the security scoped resource now that it's no longer needed.
                        url.stopAccessingSecurityScopedResource()
                } catch let error as NSError {
                    // 8. If any try expression above fails, show an error.
                    importExportError = DeckImportExportError
                        .importError(url, error)
                    showingImportExportError = true
                }
                    } else {
                        // 9. If accessing the security scoped resource failed, show an error.
                        importExportError = DeckImportExportError.securityScopedResourceAccessError(url)
                        showingImportExportError = true
                    }
            }
        case .failure(let error as NSError):
            // 10. If the file import result is a failure, show an error.
            importExportError = DeckImportExportError.urlResultFailure(error)
            showingImportExportError = true
        }
        // 11. If at least one deck was successfully imported, show the import success alert.
        if successfulDeckImportCount > 0 {
            let deckSingularPlural = successfulDeckImportCount == 1 ? "deck has" : "decks have"
            importSuccessMessage = "\(successfulDeckImportCount) \(deckSingularPlural) been successfully imported!"
            showingImportSuccess = true
        }
    }

    func handleDeckExport(deck: Deck?, result: DeckExportResult) {
        deckDataToExport = nil
        fileToExport = nil
        switch result {
        case .success:
        // 1. If the file export was successful, show a success message.
            exportSuccessMessage = "The deck \"\((deck?.name)!)\" has been successfully exported!"
            showingExportSuccess = true
        case .failure(let error as NSError):
        // 2. If the file export failed, show an error.
            showingImportExportError = true
            importExportError = DeckImportExportError.urlResultFailure(error)
        }
    }

    // MARK: - Encoding/Decoding

    // Decodes a Deck object (including its cards) from the given Data.
    func importDeck(from data: Data) throws -> Deck {
        let decoder = JSONDecoder()
        return try decoder.decode(Deck.self, from: data)
    }

    // Encodes the Deck instance (including its cards) into Data.
    func encodeDeckForExport(_ deck: Deck) throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(deck)
    }

}
