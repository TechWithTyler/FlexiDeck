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
    
    @Environment(\.modelContext) private var modelContext

    @AppStorage("newDecksDefaultTo2SidedCards") var newDecksDefaultTo2SidedCards: Bool = true

    @Query private var decks: [Deck]

    @State private var selectedDeck: Deck? = nil

    @State private var selectedCard: Card? = nil

    @EnvironmentObject var dialogManager: DialogManager

    #if !os(macOS)
    @State var showingSettings: Bool = false
    #endif

    var body: some View {
        NavigationSplitView {
            ZStack {
                if decks.count > 0 {
                    List(selection: $selectedDeck) {
                        ForEach(decks) { deck in
                            NavigationLink(deck.name, value: deck)
                                .contextMenu {
                                    Button("Settings…", systemImage: "gear") {
                                        dialogManager.deckToRename = deck
                                    }
                                    Button(role: .destructive) {
                                        deleteDeck(deck)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
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
            .navigationTitle("FlexiDeck")
            .navigationBarTitleDisplayMode(.large)
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
#endif
                ToolbarItem {
                    OptionsMenu(title: .menu) {
                        Button(action: addItem) {
                            Label("Add Deck", systemImage: "rectangle.stack.badge.plus")
                        }
                        Divider()
                        Button("Delete All Decks", systemImage: "trash.fill") {
                            selectedCard = nil
                            selectedDeck = nil
                            for deck in decks {
                                modelContext.delete(deck)
                            }
                        }
                        #if !os(macOS)
                        Button("Settings…", systemImage: "gear") {
                            showingSettings = true
                        }
                        #endif
                    }
                }
            }
        } content: {
            if let deck = selectedDeck {
                CardListView(deck: deck, selectedCard: $selectedCard)
            } else {
                Text("Select a deck")
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
        } detail: {
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
        .sheet(item: $dialogManager.deckToRename) { deck in
            DeckSettingsView(deck: deck)
        }
#if !os(macOS)
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        #endif
    }

    private func addItem() {
        withAnimation {
            let newItem = Deck(name: "New Deck", newCardsAre2Sided: newDecksDefaultTo2SidedCards)
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                deleteDeck(decks[index])
            }
        }
    }

    func deleteDeck(_ deck: Deck) {
        selectedCard = nil
        selectedDeck = nil
        deck.cards.removeAll()
        DispatchQueue.main.async {
            modelContext.delete(deck)
        }
    }

}

#Preview {
    ContentView()
        .modelContainer(for: Card.self, inMemory: true)
}
