//
//  CardListView.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 8/2/24.
//  Copyright © 2024 SheftApps. All rights reserved.
//

import SwiftUI
import SwiftData
import SheftAppsStylishUI

struct CardListView: View {

    @Bindable var deck: Deck

    @Environment(\.openWindow) var openWindow

    @Environment(\.modelContext) var modelContext

    var body: some View {
        Form {
            if deck.cards.count > 0 {
                List {
                    ForEach(deck.cards) { card in
                        Button(card.title) {
                            openWindow(id: "CardView", value: card.id)
                        }
                        .buttonStyle(.borderless)
                        .frame(width: .infinity)
                        .contextMenu {
                            Button(role: .destructive) {
                                deleteCard(at: deck.cards.firstIndex(of: card)!)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
            } else {
                Text("No cards in this deck")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
            }
        }
        .toolbar {
#if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
#endif
            ToolbarItem {
                OptionsMenu(title: .menu) {
                    Button(action: addItem) {
                        Label("Add Card", systemImage: "plus")
                    }
                    Divider()
                    Button("Delete All Cards", systemImage: "trash.fill") {
                        deck.cards.removeAll()
                    }
                }
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Card(title: "New Card")
            deck.cards.append(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                deleteCard(at: index)
            }
        }
    }

    func deleteCard(at index: Int) {
        deck.cards.remove(at: index)
    }

}

#Preview {
    CardListView(deck: Deck(name: "Preview"))
}
