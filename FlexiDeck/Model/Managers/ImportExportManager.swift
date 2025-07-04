//
//  ImportExportManager.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 12/26/24.
//  Copyright © 2024-2025 SheftApps. All rights reserved.
//

import Foundation
import SwiftUI
import SwiftData
import UniformTypeIdentifiers
#if os(macOS)
import AppKit
#endif

// MARK: - Data Transfer Objects

struct DeckExportData: Codable {
    let name: String
    let newCardsAre2Sided: Bool
    let cards: [CardExportData]
    let exportDate: Date
    let exportVersion: String
}

struct CardExportData: Codable {
    let title: String
    let front: String
    let back: String
    let is2Sided: Bool
    let tags: [String]
    let starRating: Int
    let isCompleted: Bool
    let creationDate: Date
    let modifiedDate: Date
}

struct FlexiDeckExportData: Codable {
    let decks: [DeckExportData]
    let exportDate: Date
    let exportVersion: String
}

// MARK: - Import/Export Manager

class ImportExportManager: ObservableObject {
    
    // MARK: - Properties
    
    static let shared = ImportExportManager()
    
    @Published var isExporting = false
    @Published var isImporting = false
    @Published var exportError: String?
    @Published var importError: String?
    @Published var importSuccess: String?
    
    private let exportVersion = "1.0"
    private var temporaryFiles: [URL] = []
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Export Functions
    
    func exportDeck(_ deck: Deck) -> URL? {
        guard let deckData = createDeckExportData(from: deck) else {
            exportError = "Failed to prepare deck data for export"
            return nil
        }
        
        let url = exportToFile(deckData, filename: "\(deck.name ?? "Deck").flexideck")
        if let url = url {
            temporaryFiles.append(url)
        }
        return url
    }
    
    func exportAllDecks(_ decks: [Deck]) -> URL? {
        let exportData = FlexiDeckExportData(
            decks: decks.compactMap { createDeckExportData(from: $0) },
            exportDate: Date(),
            exportVersion: exportVersion
        )
        
        let url = exportToFile(exportData, filename: "FlexiDeck_All_Decks.flexideck")
        if let url = url {
            temporaryFiles.append(url)
        }
        return url
    }
    
    // MARK: - Import Functions
    
    func importDecks(from url: URL, into modelContext: ModelContext) {
        isImporting = true
        importError = nil
        importSuccess = nil
        
        do {
            let data = try Data(contentsOf: url)
            
            // Configure decoder with proper date handling
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            // Try to decode as single deck first
            if let deckData = try? decoder.decode(DeckExportData.self, from: data) {
                guard validateDeckData(deckData) else {
                    importError = "Invalid deck data format"
                    isImporting = false
                    return
                }
                let deck = createDeck(from: deckData)
                modelContext.insert(deck)
                importSuccess = "Successfully imported deck: \(deck.name ?? "Unknown")"
            }
            // Try to decode as multiple decks
            else if let allDecksData = try? decoder.decode(FlexiDeckExportData.self, from: data) {
                var importedCount = 0
                for deckData in allDecksData.decks {
                    guard validateDeckData(deckData) else {
                        importError = "Invalid deck data format in file"
                        isImporting = false
                        return
                    }
                    let deck = createDeck(from: deckData)
                    modelContext.insert(deck)
                    importedCount += 1
                }
                importSuccess = "Successfully imported \(importedCount) deck\(importedCount == 1 ? "" : "s")"
            }
            else {
                importError = "Invalid file format. Please select a valid FlexiDeck export file."
            }
        } catch {
            importError = "Failed to import file: \(error.localizedDescription)"
        }
        
        isImporting = false
    }
    
    // MARK: - Private Helper Functions
    
    private func validateDeckData(_ deckData: DeckExportData) -> Bool {
        // Check if deck name is not empty
        guard !deckData.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }
        
        // Validate card data
        for card in deckData.cards {
            guard !card.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  card.starRating >= 0 && card.starRating <= 5 else {
                return false
            }
        }
        
        return true
    }
    
    private func createDeckExportData(from deck: Deck) -> DeckExportData? {
        guard let name = deck.name,
              let newCardsAre2Sided = deck.newCardsAre2Sided else {
            return nil
        }
        
        let cards = deck.cards?.map { card in
            CardExportData(
                title: card.title ?? "Untitled Card",
                front: card.front,
                back: card.back,
                is2Sided: card.is2Sided ?? false,
                tags: card.tags,
                starRating: card.starRating,
                isCompleted: card.isCompleted,
                creationDate: card.creationDate,
                modifiedDate: card.modifiedDate
            )
        } ?? []
        
        return DeckExportData(
            name: name,
            newCardsAre2Sided: newCardsAre2Sided,
            cards: cards,
            exportDate: Date(),
            exportVersion: exportVersion
        )
    }
    
    private func createDeck(from data: DeckExportData) -> Deck {
        let deck = Deck(name: data.name, newCardsAre2Sided: data.newCardsAre2Sided)
        
        for cardData in data.cards {
            let card = Card(title: cardData.title, is2Sided: cardData.is2Sided)
            card.front = cardData.front
            card.back = cardData.back
            card.tags = cardData.tags
            card.starRating = cardData.starRating
            card.isCompleted = cardData.isCompleted
            card.creationDate = cardData.creationDate
            card.modifiedDate = cardData.modifiedDate
            
            deck.cards?.append(card)
        }
        
        return deck
    }
    
    private func exportToFile<T: Codable>(_ data: T, filename: String) -> URL? {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            encoder.dateEncodingStrategy = .iso8601
            
            let jsonData = try encoder.encode(data)
            
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsPath.appendingPathComponent(filename)
            
            try jsonData.write(to: fileURL)
            return fileURL
        } catch {
            exportError = "Failed to export: \(error.localizedDescription)"
            return nil
        }
    }
    
    // MARK: - Cleanup
    
    func cleanupTemporaryFiles() {
        for url in temporaryFiles {
            try? FileManager.default.removeItem(at: url)
        }
        temporaryFiles.removeAll()
    }
    
    deinit {
        cleanupTemporaryFiles()
    }
}

// MARK: - Document Picker

#if os(iOS)
struct DocumentPicker: UIViewControllerRepresentable {
    let onDocumentPicked: (URL) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.json])
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            parent.onDocumentPicked(url)
        }
    }
}
#endif

#if os(macOS)
// MARK: - macOS File Handling

extension ImportExportManager {
    
    func showExportPanel(for url: URL) {
        let panel = NSSavePanel()
        panel.nameFieldStringValue = url.lastPathComponent
        panel.allowedContentTypes = [UTType.json]
        panel.allowsOtherFileTypes = true
        panel.begin { response in
            if response == .OK, let destinationURL = panel.url {
                do {
                    try FileManager.default.copyItem(at: url, to: destinationURL)
                } catch {
                    DispatchQueue.main.async {
                        self.exportError = "Failed to save file: \(error.localizedDescription)"
                    }
                }
            }
        }
    }
    
    func showImportPanel(modelContext: ModelContext) {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [UTType.json]
        panel.allowsOtherFileTypes = true
        panel.allowsMultipleSelection = false
        panel.begin { response in
            if response == .OK, let url = panel.url {
                DispatchQueue.main.async {
                    self.importDecks(from: url, into: modelContext)
                }
            }
        }
    }
}
#endif 
