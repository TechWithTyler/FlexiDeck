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

    @Query private var decks: [Deck]

    @State private var selectedDeck: Deck? = nil

    @State var deckToRename: Deck? = nil

    var body: some View {
        NavigationSplitView {
            ZStack {
                if decks.count > 0 {
                    List(selection: $selectedDeck) {
                        ForEach(decks) { deck in
                            NavigationLink(deck.name, value: deck)
                                .contextMenu {
                                    Button("Rename…", systemImage: "pencil") {
                                        deckToRename = deck
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
                        .foregroundStyle(.secondary)
                }
            }
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
                            Label("Add Deck", systemImage: "plus")
                        }
                        Divider()
                        Button("Delete All Decks", systemImage: "trash.fill") {
                            selectedDeck = nil
                            for deck in decks {
                                modelContext.delete(deck)
                            }
                        }
                    }
                }
            }
        } detail: {
            if let deck = selectedDeck {
                CardListView(deck: deck)
            } else {
                Text("Select a deck")
            }
        }
        .sheet(item: $deckToRename) { deck in
            DeckRenameView(deck: deck)
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Deck(name: "New Deck")
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
        selectedDeck = nil
        modelContext.delete(deck)
    }

}

#Preview {
    ContentView()
        .modelContainer(for: Card.self, inMemory: true)
}
