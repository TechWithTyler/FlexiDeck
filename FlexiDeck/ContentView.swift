//
//  ContentView.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 7/26/24.
//  Copyright © 2024 SheftApps. All rights reserved.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @Environment(\.modelContext) private var modelContext

    @Environment(\.openWindow) var openWindow

    @Query private var cards: [Card]

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(cards) { card in
                    Button(card.title) {
                        openWindow(id: "CardView", value: card.id)
                    }
                    .buttonStyle(.borderless)
                }
                .onDelete(perform: deleteItems)
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
                    Button(action: addItem) {
                        Label("Add Card", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select a card to open it in a new window.")
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Card(title: "New Card")
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(cards[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Card.self, inMemory: true)
}
