//
//  DeckSettingsView.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 8/2/24.
//  Copyright © 2024-2025 SheftApps. All rights reserved.
//

import SwiftUI
import SheftAppsStylishUI
import UniformTypeIdentifiers

struct DeckSettingsView: View {

    // MARK: - Properties - Deck

    var deck: Deck

    // MARK: - Properties - Strings

    @State var newName: String = String()

    // MARK: - Properties - Booleans

    @State var newCardsAre2Sided: Bool = true

    @State var applyCardTypeToExistingCards: Bool = false

    @FocusState var editingName: Bool

    // MARK: - Properties - Dismiss Action

    @Environment(\.dismiss) var dismiss
    
    // MARK: - Properties - Import/Export
    
    @ObservedObject private var importExportManager = ImportExportManager.shared
    @State private var showingExportShare = false
    @State private var exportFileURL: URL?

    var cardsWillLoseBackSide: Bool {
        guard let cards = deck.cards else { return false }
        return !cards.filter { $0.is2Sided! }.isEmpty && !newCardsAre2Sided
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                FormTextField("Name", text: $newName)
                    .focused($editingName, equals: true)
                Picker("Card Type for New Cards", selection: $newCardsAre2Sided) {
                    Text("1-Sided").tag(false)
                    Text("2-Sided").tag(true)
                }
                InfoText("This setting only applies when the sides filter is turned off.")
                Toggle("Apply Card Type To Existing Cards", isOn: $applyCardTypeToExistingCards)
                InfoText("Turn this on to apply this deck's default card type to all existing cards in it when saving settings.")
                if applyCardTypeToExistingCards && cardsWillLoseBackSide {
                    WarningText("This will cause all existing cards in this deck to lose their back side.", prefix: .warning)
                }
            }
            .formStyle(.grouped)
            .toggleStyle(.stateLabelCheckbox(stateLabelPair: .yesNo))
            .navigationTitle("Deck Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveNewSettings()
                        dismiss()
                    }
                    .disabled(newName.isEmpty)
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Export Deck", systemImage: "square.and.arrow.up") {
                        exportDeck()
                    }
                }
            }
        }
#if !os(macOS)
    .pickerStyle(.navigationLink)
#endif
        .onAppear {
            applyCurrentSettings()
        }
        .sheet(isPresented: $showingExportShare) {
            if let url = exportFileURL {
                #if os(iOS)
                ShareSheet(items: [url])
                #endif
            }
        }
        .onChange(of: showingExportShare) { oldValue, newValue in
            if !newValue && oldValue {
                // Cleanup temporary files after sharing is dismissed
                importExportManager.cleanupTemporaryFiles()
            }
        }
        .alert("Export Error", isPresented: .constant(importExportManager.exportError != nil)) {
            Button("OK") {
                importExportManager.exportError = nil
            }
        } message: {
            Text(importExportManager.exportError ?? "")
        }
    }

    // MARK: - Reflect Current Settings

    func applyCurrentSettings() {
        newName = deck.name ?? String()
        newCardsAre2Sided = deck.newCardsAre2Sided ?? true
        editingName = true
    }

    // MARK: - Save New Settings

    func saveNewSettings() {
        deck.name = newName
        deck.newCardsAre2Sided = newCardsAre2Sided
        if applyCardTypeToExistingCards {
            if let cards = deck.cards {
                for card in cards {
                    card.is2Sided = newCardsAre2Sided
                    // If the new card type is 1-sided, remove the back side.
                    if !newCardsAre2Sided {
                        card.back.removeAll()
                    }
                }
                }
            }
    }
    
    // MARK: - Export Deck
    
    func exportDeck() {
        if let url = importExportManager.exportDeck(deck) {
            #if os(macOS)
            importExportManager.showExportPanel(for: url)
            #else
            exportFileURL = url
            showingExportShare = true
            #endif
        }
    }

}

// MARK: - Preview

#Preview {
    DeckSettingsView(deck: Deck(name: "Deck", newCardsAre2Sided: true))
}
