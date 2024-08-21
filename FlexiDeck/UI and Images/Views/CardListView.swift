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

    // MARK: - Properties - Integers

    @State var cardFilter: Int = 0

    // MARK: - Properties - Decks and Cards

    @Bindable var deck: Deck

    @Binding var selectedCard: Card?

    var filteredCards: [Card] {
        guard let cards = deck.cards else {
            fatalError("Couldn't filter cards")
        }
        switch cardFilter {
        case 1: return cards.filter { !$0.is2Sided! }
        case 2: return cards.filter { $0.is2Sided! }
        default: return cards
        }
    }

    // MARK: - Properties - Booleans

    @AppStorage(UserDefaults.KeyNames.showSettingsWhenCreating) var showSettingsWhenCreating: Bool = true

    // MARK: - Body

    var body: some View {
        ZStack {
            if filteredCards.count > 0 {
                List(selection: $selectedCard) {
                    ForEach(filteredCards) { card in
                        NavigationLink(value: card) {
                            CardRowView(card: card)
                        }
                        .contextMenu {
                            Button("Settings…", systemImage: "gear") {
                                dialogManager.cardToShowSettings = card
                            }
                            Divider()
                            Button(role: .destructive) {
                                dialogManager.cardToDelete = card
                                dialogManager.showingDeleteCard = true
                            } label: {
                                Label("Delete…", systemImage: "trash")
                                    .foregroundStyle(.red)
                            }
                        }
                        .onChange(of: card.deck) { oldValue, newValue in
                            selectedCard = nil
                        }
                        .onChange(of: cardFilter) { oldValue, newValue in
                            selectedCard = nil
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
#if !os(macOS)
                .listStyle(.insetGrouped)
#endif
            } else {
                VStack {
                    if cardFilter == 0 {
                        Text("No cards in this deck")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        addCardButton
                            .buttonStyle(.borderedProminent)
                    } else {
                        Text("No \(cardFilter == 1 ? "1-sided" : "2-sided") cards in this deck")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        Text("Adjust your filter or add a new card.")
                            .foregroundStyle(.tertiary)
                    }
                }
            }
        }
        .navigationTitle(deck.name ?? String())
        .sheet(item: $dialogManager.cardToShowSettings) { card in
            CardSettingsView(card: card, selectedDeck: deck)
        }
        .alert("Delete this card?", isPresented: $dialogManager.showingDeleteCard, presenting: $dialogManager.cardToDelete) { card in
            Button("Delete") {
                guard let cards = deck.cards else { return }
                deleteCard(at: cards.firstIndex(of: card.wrappedValue!)!)
                dialogManager.cardToDelete = nil
                dialogManager.showingDeleteCard = false
            }
            Button("Cancel") {
                dialogManager.cardToDelete = nil
                dialogManager.showingDeleteCard = false
            }
        }
        .alert("Delete all cards in deck \"\(deck.name!)\"", isPresented: $dialogManager.showingDeleteAllCards) {
            Button("Delete") {
                selectedCard = nil
                deck.cards?.removeAll()
                dialogManager.showingDeleteAllCards = false
            }
            Button("Cancel", role: .cancel) {
                dialogManager.showingDeleteAllCards = false
            }
        }
        .toolbar {
            ToolbarItem {
                Menu {
                    Picker("Filter", selection: $cardFilter) {
                        Text("Off").tag(0)
                        Text("1-Sided Cards").tag(1)
                        Text("2-Sided Cards").tag(2)
                    }
                    .pickerStyle(.inline)
                    } label: {
                        Label("Filter", systemImage: cardFilter == 0 ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
                    }
                    .menuIndicator(.hidden)
            }
            ToolbarItem {
                OptionsMenu(title: .menu) {
                    addCardButton
                    Divider()
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
                    Button(role: .destructive) {
                        dialogManager.deckToDelete = deck
                        dialogManager.showingDeleteDeck = true
                    } label: {
                        Label("Delete Deck…", systemImage: "trash")
                    }
                }
            }
        }
    }

    // MARK: - Add Card Button

    @ViewBuilder
    var addCardButton: some View {
        Button {
            newCard(is2Sided: deck.newCardsAre2Sided ?? true)
        } label: {
            Label((deck.newCardsAre2Sided)! ? "Add 2-Sided Card" : "Add 1-Sided Card", systemImage: (deck.newCardsAre2Sided)! ? "plus.rectangle.on.rectangle" : "plus.rectangle")
        }
    }

    // MARK: - Data Management

    private func newCard(is2Sided: Bool) {
        withAnimation {
            let newItem = Card(title: "New Card", is2Sided: is2Sided)
            deck.cards?.append(newItem)
            if showSettingsWhenCreating {
                dialogManager.cardToShowSettings = newItem
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                dialogManager.cardToDelete = deck.cards?[index]
                dialogManager.showingDeleteCard = true
            }
        }
    }

    func deleteCard(at index: Int) {
        selectedCard = nil
        deck.cards?.remove(at: index)
    }

}

// MARK: - Preview

#Preview {
    CardListView(deck: Deck(name: "Preview", newCardsAre2Sided: true), selectedCard: .constant(nil))
        .environmentObject(DialogManager())
}
