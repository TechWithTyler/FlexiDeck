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

    // MARK: - Properties - Strings

    @State var searchText: String = String()

    // MARK: - Properties - Integers

    @State var cardFilter: Int = 0

    @AppStorage(UserDefaults.KeyNames.cardSortMode) var cardSortMode: Card.SortMode = .creationDateDescending

    // MARK: - Properties - Decks and Cards

    @Bindable var deck: Deck

    @Binding var selectedCard: Card?

    var sortedCards: [Card] {
        guard let cards = deck.cards else {
            fatalError("Couldn't sort cards")
        }
        if cardSortMode == .titleAscending {
            return cards.sorted { cardA, cardB in
                return cardA.title! < cardB.title!
            }
        } else if cardSortMode == .titleDescending {
            return cards.sorted { cardA, cardB in
                return cardA.title! > cardB.title!
            }
        } else if cardSortMode == .creationDateAscending {
            return cards.sorted { cardA, cardB in
                return cardA.creationDate < cardB.creationDate
            }
        } else {
            return cards.sorted { cardA, cardB in
                return cardA.creationDate > cardB.creationDate
            }
        }
    }

    var filteredCards: [Card] {
        switch cardFilter {
        case 1: return sortedCards.filter { !$0.is2Sided! }
        case 2: return sortedCards.filter { $0.is2Sided! }
        default: return sortedCards
        }
    }

    var searchResults: [Card] {
        // Define the content being searched.
        let content = filteredCards
        // If searchText is empty, return all cards.
        if searchText.isEmpty {
            return content
        } else {
            // Return cards with titles that contain all or part of the search text.
            return content.filter { card in
                let range = card.title?.range(of: searchText, options: .caseInsensitive)
                let textMatchesSearchTerm = range != nil
                return textMatchesSearchTerm
            }
        }
    }

    // MARK: - Properties - Booleans

    @AppStorage(UserDefaults.KeyNames.showSettingsWhenCreating) var showSettingsWhenCreating: Bool = true

    // MARK: - Body

    var body: some View {
        ZStack {
            if searchResults.count > 0 {
                List(selection: $selectedCard) {
                    ForEach(searchResults) { card in
                        NavigationLink(value: card) {
                            CardRowView(card: card, searchText: searchText)
                        }
                        .contextMenu {
                            Button("Card Settings…", systemImage: "gear") {
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
                .padding()
            }
        }
        .animation(.default, value: searchResults)
        .searchable(text: $searchText, placement: .automatic, prompt: Text("Search"))
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
                    Picker("Sort", selection: $cardSortMode) {
                        Text("Title (ascending)").tag(Card.SortMode.titleAscending)
                        Text("Title (descending)").tag(Card.SortMode.titleDescending)
                        Text("Creation Date (ascending)").tag(Card.SortMode.creationDateAscending)
                        Text("Creation Date (descending)").tag(Card.SortMode.creationDateDescending)
                    }
                    Divider()
                    if !searchResults.isEmpty {
                        Button("Show Random Card", systemImage: "questionmark.square") {
                            showRandomCard()
                        }
                    }
                    Divider()
                    Button("Deck Settings…", systemImage: "gear") {
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

    // MARK: - Show Random Card

    func showRandomCard() {
        let randomCard = deck.cards?.randomElement()!
        if randomCard != selectedCard {
            selectedCard = randomCard
        } else {
            showRandomCard()
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
