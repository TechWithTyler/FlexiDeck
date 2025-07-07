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

    @Published var showingImporter = false

    @Published var showingExporter = false

    @Published var showingImportError: Bool = false

    // MARK: - Properties - URLs

    @Published var fileToExport: URL? = nil

    // MARK: - Properties - Data

    @Published var deckDataToExport: Data? = nil

    // MARK: - Properties - Errors

    @Published var importError: DeckImportError? = nil

    // MARK: - Show Dialog

    func showDeckImport() {
        showingImporter = true
    }

    func showDeckExport(deck: Deck) {
        do {
            let data = try exportDeck(deck)
            deckDataToExport = data
            showingExporter = true
        } catch {
            importError = DeckImportError(error)
        }
    }

    // MARK: - File Operation Handlers

    func handleFileImport(result: DeckImportResult, modelContext: ModelContext) {
        // 1. Go through each file selected for import.
        switch result {
        case .success(let urls):
            for url in urls {
                // 2. Try to start accessing the security scoped resource.
                if url.startAccessingSecurityScopedResource() {
                do {
                        // 3. If successful, try to load the data from the file.
                        let data = try Data(contentsOf: url)
                        // 4. Try to decode the data into a Deck object.
                        let importedDeck = try importDeck(from: data)
                        // 5. Insert the imported deck into the model context.
                    modelContext.insert(importedDeck)
                        // 6. Stop accessing the security scoped resource now that it's no longer needed.
                        url.stopAccessingSecurityScopedResource()
                } catch {
                    // 7. If any try expression above fails, show an error.
                    importError = DeckImportError(error)
                }
                    } else {
                        // 8. If accessing the security scoped resource failed, show an error.
                        importError = DeckImportError(
                            NSError(domain: "Failed to access security scoped resource", code: 123)
                        )
                    }
            }
        case .failure(let error):
            // 9. If the file import result is a failure, show an error.
            importError = DeckImportError(error)
        }
        // 10. If any error occurred above, show the import error.
        showingImportError = importError != nil
    }

    func handleFileExport(result: DeckExportResult) {
        deckDataToExport = nil
        fileToExport = nil
        switch result {
        case .success:
        // 1. If the file export was successful, do nothing.
            break
        case .failure(let error):
        // 2. If the file export failed, show an error.
            showingImportError = true
            importError = DeckImportError(error)
        }
    }

    // MARK: - Encoding/Decoding

    // Decodes a Deck object (including its cards) from the given Data.
    func importDeck(from data: Data) throws -> Deck {
        let decoder = JSONDecoder()
        return try decoder.decode(Deck.self, from: data)
    }

    // Encodes the Deck instance (including its cards) into Data.
    func exportDeck(_ deck: Deck) throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(deck)
    }

}
