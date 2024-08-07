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
        ZStack {
            if deck.cards.count > 0 {
                List(selection: $selectedCard) {
                    ForEach(deck.cards) { card in
                        NavigationLink(value: card) {
                            Text(card.title)
                        }
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
                .listStyle(.insetGrouped)
            } else {
                VStack {
                    Text("No cards in this deck")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    addCardButton
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
                    addCardButton
                    Divider()
                    Button("Delete All Cards", systemImage: "trash.fill") {
                        selectedCard = nil
                        deck.cards.removeAll()
                    }
                }
            }
        }
    }

    @ViewBuilder
    var addCardButton: some View {
        Button {
            newCard(is2Sided: deck.newCardsAre2Sided)
        } label: {
            Label(deck.newCardsAre2Sided ? "Add 2-Sided Card" : "Add 1-Sided Card", systemImage: deck.newCardsAre2Sided ? "plus.rectangle.on.rectangle" : "plus.rectangle")
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
    CardListView(deck: Deck(name: "Preview", newCardsAre2Sided: true), selectedCard: .constant(nil))
}
