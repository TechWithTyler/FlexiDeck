//
//  ContentView.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 7/26/24.
//  Copyright © 2024 SheftApps. All rights reserved.
//

import SwiftUI
import SwiftData
import SheftAppsStylishUI

struct ContentView: View {

    // MARK: - Properties - Model Context

    @Environment(\.modelContext) private var modelContext

    // MARK: - Properties - Booleans

    @AppStorage(UserDefaults.KeyNames.newDecksDefaultTo2SidedCards) var newDecksDefaultTo2SidedCards: Bool = true

    @AppStorage(UserDefaults.KeyNames.showSettingsWhenCreating) var showSettingsWhenCreating: Bool = true

    // MARK: - Properties - Decks and Cards

    @Query private var decks: [Deck]

    @State private var selectedDeck: Deck? = nil

    @State private var selectedCard: Card? = nil

    // MARK: - Properties - Dialog Manager

    @EnvironmentObject var dialogManager: DialogManager

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
                                Button("Settings…", systemImage: "gear") {
                                    dialogManager.deckToShowSettings = deck
                                }
                                Button(role: .destructive) {
                                    dialogManager.deckToDelete = deck
                                    dialogManager.showingDeleteDeck = true
                                } label: {
                                    Label("Delete…", systemImage: "trash")
                                        .foregroundStyle(.red)
                                }
                            }

                    }
                    .onDelete(perform: deleteItems)
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
            Button("Delete") {
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
            Button("Delete") {
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
            ToolbarItem {
                OptionsMenu(title: .menu) {
                    Button(action: addItem) {
                        Label("Add Deck", systemImage: "rectangle.stack.badge.plus")
                    }
                    Divider()
                    Button(role: .destructive) {
                        dialogManager.showingDeleteAllDecks = true
                    } label: {
                        Label("Delete All Decks…", systemImage: "trash.fill")
                            .foregroundStyle(.red)
                    }
                    #if !os(macOS)
                    Button("Settings…", systemImage: "gear") {
                        dialogManager.showingSettings = true
                    }
                    #endif
                }
            }
        }
    }

    @ViewBuilder
    var cardList: some View {
        ZStack {
            if let deck = selectedDeck {
                CardListView(deck: deck, selectedCard: $selectedCard)
            } else {
                Text("Select a deck")
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
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
                    CardView(card: card)
                } else {
                    Text("Select a card")
                        .font(.largeTitle)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
            }
        }
#if os(macOS)
        .navigationSplitViewColumnWidth(min: 500, ideal: 600)
#endif
    }

    // MARK: - Data Management

    private func addItem() {
        withAnimation {
            let newItem = Deck(name: "New Deck", newCardsAre2Sided: newDecksDefaultTo2SidedCards)
            modelContext.insert(newItem)
            if showSettingsWhenCreating {
                dialogManager.deckToShowSettings = newItem
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                dialogManager.deckToDelete = decks[index]
                dialogManager.showingDeleteDeck = true
            }
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
}
