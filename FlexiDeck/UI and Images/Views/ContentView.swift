//
//  ContentView.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 7/26/24.
//  Copyright © 2024-2026 SheftApps. All rights reserved.
//

// MARK: - Imports

import SwiftUI
import SwiftData
import SheftAppsStylishUI
import UniformTypeIdentifiers

struct ContentView: View {

    // MARK: - Properties - Model Context

    // The model context, which stores data for the app.
    @Environment(\.modelContext) private var modelContext

    // MARK: - Properties - Booleans

    // Whether new decks default to creating new cards with 2 sides.
    @AppStorage(UserDefaults.KeyNames.newDecksDefaultTo2SidedCards) var newDecksDefaultTo2SidedCards: Bool = true

    // Whether deck/card settings are shown upon creating.
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
    @StateObject var dialogManager = DialogManager()

    // Handles import/export of decks.
    @StateObject var importExportManager = ImportExportManager()

    // Handles speech in the app.
    @StateObject var speechManager = SpeechManager()

    // MARK: - Body

    var body: some View {
        NavigationSplitView {
            sidebar
        } content: {
            cardList
        } detail: {
            cardView
        }
        // Settings
        .sheet(item: $dialogManager.deckToShowSettings) { deck in
            DeckSettingsView(deck: deck)
        }
#if !os(macOS)
        .sheet(isPresented: $dialogManager.showingSettings) {
            SettingsView()
        }
#endif
        // Import/Export
        .fileImporter(
            isPresented: $importExportManager.showingImporter,
            allowedContentTypes: [.flexiDeckDeck],
            allowsMultipleSelection: true
        ) { result in
            importExportManager.handleDeckImport(result: result, modelContext: modelContext)
        }
        .fileDialogMessage("Select deck(s) to import")
        .fileExporter(
            isPresented: $importExportManager.showingExporter,
            document: ExportedDeck(data: importExportManager.deckDataToExport
            ),
            contentType: .flexiDeckDeck,
            defaultFilename: importExportManager.deckToExport?.name ?? defaultDeckName
        ) { result in
            importExportManager.handleDeckExportToFile(deck: importExportManager.deckToExport, result: result)
        }
        .alert(isPresented: $importExportManager.showingError, error: importExportManager.importExportError) {
            Button("OK") {
                importExportManager.importExportError = nil
            }
        }
        .alert(
            importExportManager.importSuccessMessage,
            isPresented: $importExportManager.showingImportSuccess) {
                Button("OK") {
                    importExportManager.importSuccessMessage = String()
                }
            }
            .alert(
                importExportManager.exportSuccessMessage,
                isPresented: $importExportManager.showingExportSuccess) {
                    Button("OK") {
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
                deckList
            } else {
                // Use a VStack and spacers to increase the drop target area.
                VStack {
                    Spacer()
                    Text("No decks")
                        .font(.largeTitle)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            }
        }
        .onDrop(of: [.flexiDeckDeck], isTargeted: $importExportManager.hoveringItemOverDeckList) { providers in
            importExportManager.handleDroppedDeck(with: providers, modelContext: modelContext)
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
            }
            Button("Cancel", role: .cancel) {
                dialogManager.deckToDelete = nil
                dialogManager.showingDeleteDeck = false
            }
        } message: { deck in
            Text("All cards in deck \"\((deck.wrappedValue?.name)!)\" will be deleted!")
        }
        .alert("Delete all decks?", isPresented: $dialogManager.showingDeleteAllDecks) {
            Button("Delete", role: .destructive) {
                deleteAllDecks()
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
    var deckList: some View {
        List(selection: $selectedDeck) {
            ForEach(decks) { deck in
                NavigationLink(value: deck) {
                    DeckRowView(deck: deck)
                }
                .onDrag {
                    // Provide an item for drag-and-drop export of a single deck
                    importExportManager.exportDeck(deck: deck)
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
            // 2. Insert the new deck into the model context.
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
        // 1. Nil-out the selected card and deck.
        selectedCard = nil
        selectedDeck = nil
        // 2. Delete all cards from the deck.
        deck.cards?.removeAll()
        // 3. Delete the deck.
        DispatchQueue.main.async {
            modelContext.delete(deck)
        }
        // 4. Dismiss the delete alert.
        dialogManager.deckToDelete = nil
        dialogManager.showingDeleteDeck = false
    }

    // This method deletes all decks.
    func deleteAllDecks() {
        // 1. Nil-out the selected card and deck.
        selectedCard = nil
        selectedDeck = nil
        // 2. Delete each deck.
        for deck in decks {
            modelContext.delete(deck)
        }
        // 3. Dismiss the delete alert.
        dialogManager.showingDeleteAllDecks = false
    }

}

// MARK: - Preview

#Preview {
    ContentView()
        .modelContainer(for: Card.self, inMemory: true)
}

