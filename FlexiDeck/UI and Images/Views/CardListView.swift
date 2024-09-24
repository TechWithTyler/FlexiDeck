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

    @State var cardFilterSides: Int = 0

    @State var cardFilterTags: String = "none"

    @State var cardFilterComplete: Int = 0

    @State var cardFilterRating: Int = 0

    @AppStorage(UserDefaults.KeyNames.cardSortMode) var cardSortMode: Card.SortMode = .creationDateDescending

    // MARK: - Properties - Decks and Cards

    @Bindable var deck: Deck

    @Binding var selectedCard: Card?

    var allTags: [String] {
        guard let cards = deck.cards else {
            fatalError("Couldn't get tags")
        }
        var tags: [String] = []
        for card in cards {
            for tag in card.tags {
                tags.append(tag)
            }
        }
        tags.removeDuplicates()
        return tags.sorted(by: <)
    }

    var sortedCards: [Card] {
        guard let cards = deck.cards else {
            fatalError("Couldn't sort cards")
        }
        switch cardSortMode {
        case .titleAscending:
            return cards.sorted { cardA, cardB in
                return cardA.title! < cardB.title!
            }
        case .titleDescending:
            return cards.sorted { cardA, cardB in
                return cardA.title! > cardB.title!
            }
        case .starRatingAscending:
            return cards.sorted { cardA, cardB in
                return cardA.starRating < cardB.starRating
            }
        case .starRatingDescending:
            return cards.sorted { cardA, cardB in
                return cardA.starRating > cardB.starRating
            }
        case .creationDateAscending:
            return cards.sorted { cardA, cardB in
                return cardA.creationDate < cardB.creationDate
            }
        case .creationDateDescending:
            return cards.sorted { cardA, cardB in
                return cardA.creationDate > cardB.creationDate
            }
        case .modifiedDateAscending:
            return cards.sorted { cardA, cardB in
                return cardA.modifiedDate < cardB.modifiedDate
            }
        default:
            return cards.sorted { cardA, cardB in
                return cardA.modifiedDate > cardB.modifiedDate
            }
        }
    }

    var sidesFilteredCards: [Card] {
        switch cardFilterSides {
        case 1: return sortedCards.filter { !$0.is2Sided! }
        case 2: return sortedCards.filter { $0.is2Sided! }
        default: return sortedCards
        }
    }

    var tagsFilteredCards: [Card] {
        switch cardFilterTags {
        case "none": return sidesFilteredCards
        default: return sidesFilteredCards.filter { $0.tags.contains(cardFilterTags) }
        }
    }

    var completeFilteredCards: [Card] {
        switch cardFilterComplete {
        case 1: return tagsFilteredCards.filter { !$0.isCompleted }
        case 2: return tagsFilteredCards.filter { $0.isCompleted }
        default: return tagsFilteredCards
        }
    }

    var ratingFilteredCards: [Card] {
        switch cardFilterRating {
        case -1:
            return completeFilteredCards.filter { $0.starRating == 0 }
        case 0:
            return completeFilteredCards
        default:
            return completeFilteredCards.filter { $0.starRating == cardFilterRating }
        }
    }

    var filteredCards: [Card] {
        // Return the last filter.
        return ratingFilteredCards
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

    var cardFilterEnabled: Bool {
        return cardFilterTags != "none" || cardFilterSides != 0 || cardFilterRating != 0
    }

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
                        .onChange(of: card.starRating) { oldValue, newValue in
                            if !ratingFilteredCards.contains(selectedCard!) {
                                selectedCard = nil
                            }
                        }
                        .onChange(of: card.tags) { oldValue, newValue in
                            if !newValue.contains(cardFilterTags) {
                                cardFilterTags = "none"
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
                    if !searchText.isEmpty {
                        Text("No cards with titles containing \"\(searchText)\"")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    } else if cardFilterSides == 0 && cardFilterTags == "none" {
                        Text("No cards in this deck")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        addCardButton
                            .buttonStyle(.borderedProminent)
                    } else {
                        Text("No cards matching the selected filters")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        Text("Adjust your filters or add a new card.")
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding()
            }
        }
        .onChange(of: allTags) { oldValue, newValue in
            if !allTags.contains(cardFilterTags) {
                cardFilterTags = "none"
            }
        }
        .onChange(of: cardFilterSides) { oldValue, newValue in
            selectedCard = nil
        }
        .onChange(of: cardFilterTags) { oldValue, newValue in
            selectedCard = nil
        }
        .onChange(of: cardFilterComplete) { oldValue, newValue in
            selectedCard = nil
        }
        .onChange(of: cardFilterRating) { oldValue, newValue in
            selectedCard = nil
        }
        .onChange(of: searchText) {
            oldValue, newValue in
            selectedCard = nil
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
                    Picker("Sides (\(cardFilterSides == 0 ? "off" : "on"))", selection: $cardFilterSides) {
                            Text("Off").tag(0)
                        Divider()
                            Text("1-Sided Cards").tag(1)
                            Text("2-Sided Cards").tag(2)
                        }
                    Picker("Tags (\(cardFilterTags == "none" ? "off" : "on"))", selection: $cardFilterTags) {
                            // All tags are prefixed with #, so there can't be any confusion between "Off" and a tag "#none".
                            Text("Off").tag("none")
                        Divider()
                        ForEach(allTags, id: \.self) { tag in
                                Text(tag).tag(tag)
                            }
                        }
                    Picker("Completed Status (\(cardFilterComplete == 0 ? "off" : "on"))", selection: $cardFilterComplete) {
                            Text("Off").tag(0)
                        Divider()
                            Text("Not Completed").tag(1)
                            Text("Completed").tag(2)
                        }
                    Picker("Star Rating (\(cardFilterRating == 0 ? "off" : "on"))", selection: $cardFilterRating) {
                            Text("Off").tag(0)
                        Divider()
                            Text("No Rating").tag(-1)
                            Text("1 Star").tag(1)
                            Text("2 Stars").tag(2)
                            Text("3 Stars").tag(3)
                            Text("4 Stars").tag(4)
                            Text("5 Stars").tag(5)
                        }
                    Divider()
                    Button("Reset") {
                        cardFilterTags = "none"
                        cardFilterSides = 0
                        cardFilterComplete = 0
                        cardFilterRating = 0
                    }
                    } label: {
                        Label("Filter", systemImage: cardFilterEnabled ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                    }
                    .accessibilityLabel("Filter (\(cardFilterEnabled ? "on" : "off"))")
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
                        Text("Modified Date (ascending)").tag(Card.SortMode.modifiedDateAscending)
                        Text("Modified Date (descending)").tag(Card.SortMode.modifiedDateDescending)
                        Text("Star Rating (ascending)").tag(Card.SortMode.starRatingAscending)
                        Text("Star Rating (descending)").tag(Card.SortMode.starRatingDescending)
                    }
                    .pickerStyle(.menu)
                    Divider()
                    if searchResults.count > 1 {
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
            let newItem = Card(title: defaultCardName, is2Sided: is2Sided)
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
