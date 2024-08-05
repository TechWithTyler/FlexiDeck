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

    @State var cardToRename: Card? = nil

    @Binding var selectedCard: Card?

    var body: some View {
        Form {
            if deck.cards.count > 0 {
                List(selection: $selectedCard) {
                    ForEach(deck.cards) { card in
                        NavigationLink(card.title, value: card)
                        .contextMenu {
                            Button("Settings…", systemImage: "gear") {
                                cardToRename = card
                            }
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
                VStack {
                    Text("No cards in this deck")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Button {
                        newCard(is2Sided: true)
                    } label: {
                        Label("Add 2-Sided Card", systemImage: "plus.rectangle.on.rectangle")
                    }
                    Button {
                        newCard(is2Sided: false)
                    } label: {
                        Label("Add 1-Sided Card", systemImage: "plus.rectangle")
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .navigationTitle(deck.name)
        .sheet(item: $cardToRename) { card in
            CardSettingsView(card: card)
        }
        .toolbar {
#if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
#endif
            ToolbarItem {
                OptionsMenu(title: .menu) {
                    Button {
                        newCard(is2Sided: true)
                    } label: {
                        Label("Add 2-Sided Card", systemImage: "plus.rectangle.on.rectangle")
                    }
                    Button {
                        newCard(is2Sided: false)
                    } label: {
                        Label("Add 1-Sided Card", systemImage: "plus.rectangle")
                    }
                    Divider()
                    Button("Delete All Cards", systemImage: "trash.fill") {
                        deck.cards.removeAll()
                    }
                }
            }
        }
    }

    private func newCard(is2Sided: Bool) {
        withAnimation {
            let newItem = Card(title: "New Card", is2Sided: is2Sided)
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
        selectedCard = nil
        deck.cards.remove(at: index)
    }

}

#Preview {
    CardListView(deck: Deck(name: "Preview"), selectedCard: .constant(nil))
}
