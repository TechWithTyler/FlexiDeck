//
//  ContentView.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 7/26/24.
//  Copyright © 2024-2025 SheftApps. All rights reserved.
//

// MARK: - Imports

import SwiftUI
import SwiftData
import SheftAppsStylishUI

struct ContentView: View {

    // MARK: - Properties - Model Context

    // The model context.
    @Environment(\.modelContext) private var modelContext

    // MARK: - Properties - Booleans

    @AppStorage(UserDefaults.KeyNames.newDecksDefaultTo2SidedCards) var newDecksDefaultTo2SidedCards: Bool = true

    @AppStorage(UserDefaults.KeyNames.showSettingsWhenCreating) var showSettingsWhenCreating: Int = 1

    // MARK: - Properties - Decks and Cards

    // The decks loaded from the model context.
    @Query private var decks: [Deck]

    // The selected deck.
    @State private var selectedDeck: Deck? = nil

    // The selected card.
    @State private var selectedCard: Card? = nil

    // MARK: - Properties - Managers

    // Handles the display of dialogs in the app.
    @ObservedObject var dialogManager = DialogManager()

    // Handles import/export of decks.
    @ObservedObject var importExportManager = ImportExportManager()

    // Handles speech in the app.
    @ObservedObject var speechManager = SpeechManager()

    // MARK: - Body

    var body: some View {
        NavigationSplitView {
            sidebar
        } content: {
            cardList
        } detail: {
            cardView
        }
        .sheet(item: $dialogManager.deckToShowSettings) { deck in
            DeckSettingsView(deck: deck)
        }
#if !os(macOS)
        .sheet(isPresented: $dialogManager.showingSettings) {
            SettingsView()
        }
#endif
        .fileImporter(
            isPresented: $importExportManager.showingImporter,
            allowedContentTypes: [.flexiDeckDeck],
            allowsMultipleSelection: true,
        ) { result in
            importExportManager.handleDeckImport(result: result, modelContext: modelContext)
        }
        .fileDialogMessage("Select deck(s) to import")
        .fileExporter(
            isPresented: $importExportManager.showingExporter,
            document: ExportedDeck(data: importExportManager.deckDataToExport, deck: importExportManager.deckToExport
            ),
            contentType: .flexiDeckDeck,
            defaultFilename: importExportManager.deckToExport?.name ?? defaultDeckName
        ) { result in
            importExportManager.handleDeckExport(deck: importExportManager.deckToExport, result: result)
        }
        .alert(isPresented: $importExportManager.showingError, error: importExportManager.importExportError) {
            Button("OK") {
                importExportManager.showingError = false
                importExportManager.importExportError = nil
            }
        }
        .alert(
            importExportManager.importSuccessMessage,
            isPresented: $importExportManager.showingImportSuccess) {
                Button("OK") {
                    importExportManager.showingImportSuccess = false
                    importExportManager.importSuccessMessage = String()
                }
            }
            .alert(
                importExportManager.exportSuccessMessage,
                isPresented: $importExportManager.showingExportSuccess) {
                    Button("OK") {
                        importExportManager.showingExportSuccess = false
                        importExportManager.exportSuccessMessage = String()
                    }
                }
                .focusedSceneObject(dialogManager)
                .environmentObject(dialogManager)
                .focusedSceneObject(speechManager)
                .environmentObject(speechManager)
                .focusedSceneObject(importExportManager)
                .environmentObject(importExportManager)
    }

    // MARK: - Sidebar

    @ViewBuilder
    var sidebar: some View {
        ZStack {
            if decks.count > 0 {
                List(selection: $selectedDeck) {
                    ForEach(decks) { deck in
                        NavigationLink(value: deck) {
                            DeckRowView(deck: deck)
                        }
                        .contextMenu {
                            ExportButton(deck: deck)
                            Divider()
                            Button("Deck Settings…", systemImage: "gear") {
                                dialogManager.deckToShowSettings = deck
                            }
                            Divider()
                            Button(role: .destructive) {
                                dialogManager.deckToDelete = deck
                                dialogManager.showingDeleteDeck = true
                            } label: {
                                Label("Delete…", systemImage: "trash")
                                    .foregroundStyle(.red)
                            }
                        }
                    }
                    .onDelete(perform: deleteDecks)
                }
            } else {
                Text("No decks")
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
        }
        .onChange(of: selectedDeck) { oldValue, newValue in
            selectedCard = nil
        }
        .navigationTitle("FlexiDeck")
#if !os(macOS)
        .navigationBarTitleDisplayMode(.large)
#endif
        .navigationSplitViewColumnWidth(min: 300, ideal: 300)
        .alert("Delete this deck?", isPresented: $dialogManager.showingDeleteDeck, presenting: $dialogManager.deckToDelete) { deck in
            Button("Delete", role: .destructive) {
                deleteDeck(deck.wrappedValue!)
                dialogManager.deckToDelete = nil
                dialogManager.showingDeleteDeck = false
            }
            Button("Cancel", role: .cancel) {
                dialogManager.deckToDelete = nil
                dialogManager.showingDeleteDeck = false
            }
        } message: { deck in
            Text("All cards in this deck will be deleted.")
        }
        .alert("Delete all decks?", isPresented: $dialogManager.showingDeleteAllDecks) {
            Button("Delete", role: .destructive) {
                selectedCard = nil
                selectedDeck = nil
                for deck in decks {
                    modelContext.delete(deck)
                }
                dialogManager.showingDeleteAllDecks = false
            }
            Button("Cancel", role: .cancel) {
                dialogManager.showingDeleteAllDecks = false
            }
        } message: {
            Text("If you have any decks you may want to keep, export them before deletion.")
        }
        .toolbar {
#if os(macOS)
            ToolbarItem {
                newDeckButton
            }
#else
            ToolbarItem(placement: .bottomBar) {
                newDeckButton
                    .labelStyle(.titleAndIcon)
            }
#endif
            ToolbarItem {
                OptionsMenu(title: .menu) {
                    ImportButton()
                    Divider()
                    Button(role: .destructive) {
                        dialogManager.showingDeleteAllDecks = true
                    } label: {
                        Label("Delete All Decks…", systemImage: "trash.fill")
                            .foregroundStyle(.red)
                    }
#if !os(macOS)
                    Divider()
                    Button("Settings…", systemImage: "gear") {
                        dialogManager.showingSettings = true
                    }
#endif
                }
            }
        }
    }

    @ViewBuilder
    var newDeckButton: some View {
        Button(action: addDeck) {
            Label("Add Deck", systemImage: "rectangle.stack.badge.plus")
        }
    }

    // MARK: - Card List

    @ViewBuilder
    var cardList: some View {
        ZStack {
            if let deck = selectedDeck {
                CardListView(deck: deck, selectedCard: $selectedCard)
            } else {
                if !decks.isEmpty {
                    Text("Select a deck")
                        .font(.largeTitle)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationSplitViewColumnWidth(min: 300, ideal: 300)
    }

    // MARK: - Card View

    @ViewBuilder
    var cardView: some View {
        ZStack {
            if selectedDeck != nil {
                if let card = selectedCard {
                    CardView(selectedCard: card)
                } else {
                    Text("Select a card")
                        .font(.largeTitle)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .focusable(false)
                }
            }
        }
        .navigationSplitViewColumnWidth(min: 500, ideal: 600)
    }

    // MARK: - Data Management

    // This method creates a new Deck object and inserts it into the model context.
    private func addDeck() {
        withAnimation {
            // 1. Create a new Deck object with the default name and default number of sides.
            let newItem = Deck(name: defaultDeckName, newCardsAre2Sided: newDecksDefaultTo2SidedCards)
            // 2. INsert the new deck into the model context.
            modelContext.insert(newItem)
            // 3. Select the new deck.
            selectedDeck = newItem
            // 4. If set to show deck settings upon creation, show the new deck's settings.
            if showSettingsWhenCreating >= 1 {
                dialogManager.deckToShowSettings = newItem
            }
        }
    }

    // This method deletes the deck at the given index set.
    private func deleteDecks(at offsets: IndexSet) {
        guard let index = offsets.first else { return }
        withAnimation {
            dialogManager.deckToDelete = decks[index]
            dialogManager.showingDeleteDeck = true
        }
    }

    // This method deletes the given deck.
    func deleteDeck(_ deck: Deck) {
        // 1. Nil-out all selections.
        selectedCard = nil
        selectedDeck = nil
        // 2. Delete all cards from the deck.
        deck.cards?.removeAll()
        // 3. Delete the deck.
        DispatchQueue.main.async {
            modelContext.delete(deck)
        }
    }

}

// MARK: - Preview

#Preview {
    ContentView()
        .modelContainer(for: Card.self, inMemory: true)
}
