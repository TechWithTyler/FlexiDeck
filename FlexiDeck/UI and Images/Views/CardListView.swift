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

    // MARK: - Properties - Model Context

    @Environment(\.modelContext) var modelContext

    // MARK: - Properties - Dialog Manager

    @EnvironmentObject var dialogManager: DialogManager

    // MARK: - Properties - Decks and Cards

    @Bindable var deck: Deck

    @Binding var selectedCard: Card?

    // MARK: - Body

    var body: some View {
        ZStack {
            if deck.cards.count > 0 {
                List(selection: $selectedCard) {
                    ForEach(deck.cards) { card in
                        NavigationLink(value: card) {
                            CardRowView(card: card)
                        }
                        .contextMenu {
                            Button("Settings…", systemImage: "gear") {
                                dialogManager.cardToShowSettings = card
                            }
                            Button(role: .destructive) {
                                dialogManager.cardToDelete = card
                                dialogManager.showingDeleteCard = true
                            } label: {
                                Label("Delete…", systemImage: "trash")
                                    .foregroundStyle(.red)
                            }
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                #if !os(macOS)
                .listStyle(.insetGrouped)
                #endif
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
        .sheet(item: $dialogManager.cardToShowSettings) { card in
            CardSettingsView(card: card)
        }
        .alert("Delete this card?", isPresented: $dialogManager.showingDeleteCard, presenting: $dialogManager.cardToDelete) { card in
            Button("Delete") {
                deleteCard(at: deck.cards.firstIndex(of: card.wrappedValue!)!)
                dialogManager.cardToDelete = nil
                dialogManager.showingDeleteCard = false
            }
            Button("Cancel") {
                dialogManager.cardToDelete = nil
                dialogManager.showingDeleteCard = false
            }
        }
        .alert("Delete all cards in this deck?", isPresented: $dialogManager.showingDeleteAllCards) {
            Button("Delete") {
                selectedCard = nil
                deck.cards.removeAll()
                dialogManager.showingDeleteAllCards = false
            }
            Button("Cancel", role: .cancel) {
                dialogManager.showingDeleteAllCards = false
            }
        }
        .toolbar {
            ToolbarItem {
                OptionsMenu(title: .menu) {
                    addCardButton
                    Button("Settings…", systemImage: "gear") {
                        dialogManager.deckToShowSettings = deck
                    }
                    Divider()
                    Button(role: .destructive) {
                        dialogManager.showingDeleteAllCards = true
                    } label: {
                        Label("Delete All Cards…", systemImage: "trash.fill")
                            .foregroundStyle(.red)
                    }
                }
            }
        }
    }

    // MARK: - Add Card Button

    @ViewBuilder
    var addCardButton: some View {
        Button {
            newCard(is2Sided: deck.newCardsAre2Sided)
        } label: {
            Label(deck.newCardsAre2Sided ? "Add 2-Sided Card" : "Add 1-Sided Card", systemImage: deck.newCardsAre2Sided ? "plus.rectangle.on.rectangle" : "plus.rectangle")
        }
    }

    // MARK: - Data Management

    private func newCard(is2Sided: Bool) {
        withAnimation {
            let newItem = Card(title: "New Card", is2Sided: is2Sided)
            deck.cards.append(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                dialogManager.cardToDelete = deck.cards[index]
                dialogManager.showingDeleteCard = true
            }
        }
    }

    func deleteCard(at index: Int) {
        selectedCard = nil
        deck.cards.remove(at: index)
    }

}

// MARK: - Preview

#Preview {
    CardListView(deck: Deck(name: "Preview", newCardsAre2Sided: true), selectedCard: .constant(nil))
        .environmentObject(DialogManager())
}
