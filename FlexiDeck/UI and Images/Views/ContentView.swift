//
//  ContentView.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 7/26/24.
//  Copyright © 2024-2025 SheftApps. All rights reserved.
//

import SwiftUI
import SwiftData
import SheftAppsStylishUI

struct ContentView: View {

    // MARK: - Properties - Model Context

    @Environment(\.modelContext) private var modelContext

    // MARK: - Properties - Booleans

    @AppStorage(UserDefaults.KeyNames.newDecksDefaultTo2SidedCards) var newDecksDefaultTo2SidedCards: Bool = true

    @AppStorage(UserDefaults.KeyNames.showSettingsWhenCreating) var showSettingsWhenCreating: Int = 1

    // MARK: - Properties - Decks and Cards

    @Query private var decks: [Deck]

    @State private var selectedDeck: Deck? = nil

    @State private var selectedCard: Card? = nil

    // MARK: - Properties - Managers

    @EnvironmentObject var dialogManager: DialogManager

    @EnvironmentObject var importExportManager: ImportExportManager

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
            allowedContentTypes: [.json],
            allowsMultipleSelection: true
        ) { result in
            importExportManager.handleFileImport(result: result, modelContext: modelContext)
        }
        .fileExporter(
            isPresented: $importExportManager.showingExporter,
            document: ExportedDeck(data: importExportManager.deckDataToExport ?? Data()),
            contentType: .json,
            defaultFilename: selectedDeck?.name ?? "Deck"
        ) { result in
            importExportManager.handleFileExport(result: result)
        }
        .alert(isPresented: $importExportManager.showingImportError, error: importExportManager.importError) {
            Button("OK") {
                importExportManager.showingImportError = false
                importExportManager.importError = nil
            }
        }
    }

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
#if os(macOS)
        .navigationSplitViewColumnWidth(min: 300, ideal: 300)
#endif
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
                    Button {
                        importExportManager.showDeckImport()
                    } label: {
                        Label("Import Deck…", systemImage: "square.and.arrow.down")
                    }
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
#if os(macOS)
        .navigationSplitViewColumnWidth(min: 300, ideal: 300)
#endif
    }

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
#if os(macOS)
        .navigationSplitViewColumnWidth(min: 500, ideal: 600)
#endif
    }

    // MARK: - Data Management

    private func addDeck() {
        withAnimation {
            let newItem = Deck(name: defaultDeckName, newCardsAre2Sided: newDecksDefaultTo2SidedCards)
            modelContext.insert(newItem)
            selectedDeck = newItem
            if showSettingsWhenCreating >= 1 {
                dialogManager.deckToShowSettings = newItem
            }
        }
    }

    private func deleteDecks(at offsets: IndexSet) {
        guard let index = offsets.first else { return }
        withAnimation {
            dialogManager.deckToDelete = decks[index]
            dialogManager.showingDeleteDeck = true
        }
    }

    func deleteDeck(_ deck: Deck) {
        selectedCard = nil
        selectedDeck = nil
        deck.cards?.removeAll()
        DispatchQueue.main.async {
            modelContext.delete(deck)
        }
    }

}

// MARK: - Preview

#Preview {
    ContentView()
        .modelContainer(for: Card.self, inMemory: true)
        .environmentObject(DialogManager())
        .environmentObject(SpeechManager())
}
