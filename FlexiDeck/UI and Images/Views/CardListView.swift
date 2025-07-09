//
//  CardListView.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 8/2/24.
//  Copyright © 2024-2025 SheftApps. All rights reserved.
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

    @State var cardFilterTags: String = "off"

    var allTags: [String] {
        // 1. Try to get all cards in the selected deck.
        guard let cards = deck.cards else {
            fatalError("Couldn't get tags")
        }
        // 2. Create a set to hold the tags.
        var tags: Set<String> = []
        // 3. Loop through each card in the deck.
        for card in cards {
            // 4. Loop through each tag in the card's tags array and add it to the tags set.
            for tag in card.tags {
                tags.insert(tag)
            }
        }
        // 5. Return the tags set as a sorted array.
        return tags.sorted(by: <)
    }

    // MARK: - Properties - Integers

    @State var cardFilterSides: Int = 0

    @State var cardFilterComplete: Int = 0

    @State var cardFilterRating: Int = 0

    // MARK: - Properties - Card Sort Mode

    @AppStorage(UserDefaults.KeyNames.cardSortMode) var cardSortMode: Card.SortMode = .creationDateDescending

    // MARK: - Properties - Decks and Cards

    @Bindable var deck: Deck

    @Binding var selectedCard: Card?

    var sortedCards: [Card] {
        // 1. Try to get all cards in the selected deck.
        guard let cards = deck.cards else {
            fatalError("Couldn't sort cards")
        }
        // 2. Choose how to sort the cards based on the selected card sort mode.
        return cards.sorted { cardA, cardB in
            switch cardSortMode {
            case .titleAscending:
                return cardA.title! < cardB.title!
            case .titleDescending:
                return cardA.title! > cardB.title!
            case .starRatingAscending:
                return cardA.starRating < cardB.starRating
            case .starRatingDescending:
                return cardA.starRating > cardB.starRating
            case .creationDateAscending:
                return cardA.creationDate < cardB.creationDate
            case .creationDateDescending:
                return cardA.creationDate > cardB.creationDate
            case .modifiedDateAscending:
                return cardA.modifiedDate < cardB.modifiedDate
            default:
                return cardA.modifiedDate > cardB.modifiedDate
            }
        }
    }

    var sidesFilteredCards: [Card] {
        switch cardFilterSides {
            // 1. If cardFilterSides is 1, return only 1-sided cards.
        case 1: return sortedCards.filter { !$0.is2Sided! }
            // 2. If cardFilterSides is 2, return only 2-sided cards.
        case 2: return sortedCards.filter { $0.is2Sided! }
            // 3. If cardFilterSides isn't 1 or 2, return all cards.
        default: return sortedCards
        }
    }

    var tagsFilteredCards: [Card] {
        switch cardFilterTags {
            // 1. If the tags filter is turned off, return all cards returned by sidesFilteredCards.
        case "off": return sidesFilteredCards
            // 2. If the tags filter is set to "No Filter", return only cards without tags.
        case "none": return sidesFilteredCards.filter { $0.tags.isEmpty }
            // 3. If the tags filter is set to a tag, return only cards that contain that tag.
        default: return sidesFilteredCards.filter { $0.tags.contains(cardFilterTags) }
        }
    }

    var completeFilteredCards: [Card] {
        switch cardFilterComplete {
            // 1. If cardFilterComplete is 1, return only non-completed cards.
        case 1: return tagsFilteredCards.filter { !$0.isCompleted }
            // 2. If cardFilterComplete is 2, return only completed cards.
        case 2: return tagsFilteredCards.filter { $0.isCompleted }
            // 3. IF cardFilterComplete isn't 1 or 2, return all cards returned by tagsFilteredCards.
        default: return tagsFilteredCards
        }
    }

    var ratingFilteredCards: [Card] {
        switch cardFilterRating {
            // 1. If cardFilterRating is -1, return only cards without a star rating.
        case -1: return completeFilteredCards.filter { $0.starRating == 0 }
            // 2. If cardFilterRating is 0, return all cards returned by completeFilteredCards.
        case 0: return completeFilteredCards
            // 3. If cardFilterRating is 1-5, return only cards with that star rating.
        default: return completeFilteredCards.filter { $0.starRating == cardFilterRating }
        }
    }

    var filteredCards: [Card] {
        // Return the last filter.
        return ratingFilteredCards
    }

    var searchResults: [Card] {
        // 1. Define the content being searched.
        let content = filteredCards
        // 2. If searchText is empty, return all cards.
        if searchText.isEmpty {
            return content
        } else {
            // 3. Return cards with titles or text that contain all or part of the search text.
            return content.filter { card in
                let titleRange = card.title?.range(of: searchText, options: .caseInsensitive)
                let frontRange = card.front.range(of: searchText, options: .caseInsensitive)
                let backRange = card.back.range(of: searchText, options: .caseInsensitive)
                let textMatchesSearchTerm = titleRange != nil || frontRange != nil || backRange != nil
                return textMatchesSearchTerm
            }
        }
    }

    // MARK: - Properties - Booleans

    @AppStorage(UserDefaults.KeyNames.showSettingsWhenCreating) var showSettingsWhenCreating: Int = 1

    var cardFilterEnabled: Bool {
        return cardFilterTags != "off" || cardFilterSides != 0 || cardFilterRating != 0 || cardFilterComplete != 0
    }

    var shouldCreate2SidedCards: Bool {
        // 1. If the sides filter is enabled, decide based on it.
        switch cardFilterSides {
        case 1: return false
        case 2: return true
        default:
            // 2. Otherwise, decide based on the deck's "number of sides" setting.
            guard let deckDefaultsTo2SidedCards = deck.newCardsAre2Sided else { return true }
            if deckDefaultsTo2SidedCards {
                return true
            } else {
                return false
            }
        }
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
                            if let card = selectedCard, !ratingFilteredCards.contains(card) {
                                selectedCard = nil
                            }
                        }
                        .onChange(of: card.tags) { oldValue, newValue in
                            if !newValue.contains(cardFilterTags) {
                                cardFilterTags = "off"
                            }
                        }
                    }
                    .onDelete(perform: deleteCards)
                }
#if !os(macOS)
                .listStyle(.insetGrouped)
#endif
            } else {
                VStack {
                    if !searchText.isEmpty {
                        Text("No cards containing \"\(searchText)\"")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        Text("Please check your search terms.")
                            .font(.callout)
                            .foregroundStyle(.tertiary)
                    } else if cardFilterEnabled {
                        Text("No cards matching the selected filters")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        Text("Adjust your filters or add a new card.")
                            .font(.callout)
                            .foregroundStyle(.tertiary)
                        addCardButton
                            .buttonStyle(.borderedProminent)
                    } else {
                        Text("No cards in this deck")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        addCardButton
                            .buttonStyle(.borderedProminent)
                    }
                }
                .padding()
            }
        }
        .contextMenu {
            CardListDetailOptions()
        }
        .onChange(of: allTags) { oldValue, newValue in
            if !allTags.contains(cardFilterTags) {
                cardFilterTags = "off"
            }
        }
        .onChange(of: searchResults) { oldValue, newValue in
            if let card = selectedCard, !newValue.contains(card) {
                selectedCard = nil
            }
        }
        .animation(.default, value: searchResults)
        .searchable(text: $searchText, placement: .automatic, prompt: Text("Search \((deck.name)!)"))
        .navigationTitle(deck.name ?? String())
        .sheet(item: $dialogManager.cardToShowSettings) { card in
            CardSettingsView(card: card, selectedDeck: deck)
        }
        .alert("Delete this card?", isPresented: $dialogManager.showingDeleteCard, presenting: $dialogManager.cardToDelete) { card in
            Button("Delete", role: .destructive) {
                guard let cards = deck.cards else { return }
                deleteCard(at: cards.firstIndex(of: card.wrappedValue!)!)
                dialogManager.cardToDelete = nil
                dialogManager.showingDeleteCard = false
            }
            Button("Cancel", role: .cancel) {
                dialogManager.cardToDelete = nil
                dialogManager.showingDeleteCard = false
            }
        }
        .alert("Delete all cards in deck \"\(deck.name!)\"", isPresented: $dialogManager.showingDeleteAllCards) {
            Button("Delete", role: .destructive) {
                selectedCard = nil
                deck.cards?.removeAll()
                dialogManager.showingDeleteAllCards = false
            }
            Button("Cancel", role: .cancel) {
                dialogManager.showingDeleteAllCards = false
            }
        }
        .toolbar {
            toolbarContent
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
#if os(macOS)
        ToolbarItem {
            filterToolbarItem
        }
        ToolbarItem {
            addCardButton
        }
#else
        ToolbarItem(placement: .bottomBar) {
            filterToolbarItem
        }
        ToolbarItem(placement: .bottomBar) {
            Spacer()
        }
        ToolbarItem(placement: .bottomBar) {
            addCardButton
                .labelStyle(.titleAndIcon)
        }
#endif
        ToolbarItem {
            OptionsMenu(title: .menu) {
                Menu("Card List Detail") {
                    CardListDetailOptions()
                }
                .pickerStyle(.menu)
                .toggleStyle(.automatic)
                Divider()
                Picker(selection: $cardSortMode) {
                    Text("Title (Ascending)").tag(Card.SortMode.titleAscending)
                    Text("Title (Descending)").tag(Card.SortMode.titleDescending)
                    Divider()
                    Text("Creation Date (Ascending)").tag(Card.SortMode.creationDateAscending)
                    Text("Creation Date (Descending)").tag(Card.SortMode.creationDateDescending)
                    Divider()
                    Text("Modified Date (Ascending)").tag(Card.SortMode.modifiedDateAscending)
                    Text("Modified Date (Descending)").tag(Card.SortMode.modifiedDateDescending)
                    Divider()
                    Text("Star Rating (Ascending)").tag(Card.SortMode.starRatingAscending)
                    Text("Star Rating (Descending)").tag(Card.SortMode.starRatingDescending)
                } label: {
                    Label("Sort Cards By", systemImage: "arrow.up.arrow.down")
                }
                .pickerStyle(.menu)
                Divider()
                ExportButton(deck: deck)
                Divider()
                if searchResults.count > 1 {
                    Button("Show Random Card", systemImage: "questionmark.square") {
                        showRandomCard()
                    }
                    Menu("Mark All Cards As", systemImage: "checkmark.circle") {
                        Button("Completed") {
                            markCardsAs(completed: true)
                        }
                        Button("Not Completed") {
                            markCardsAs(completed: false)
                        }
                    }
                }
                Button(role: .destructive) {
                    dialogManager.showingDeleteAllCards = true
                } label: {
                    Label("Delete All Cards…", systemImage: "trash.fill")
                        .foregroundStyle(.red)
                }
                Divider()
                Button("Deck Settings…", systemImage: "gear") {
                    dialogManager.deckToShowSettings = deck
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

    @ViewBuilder
    var filterToolbarItem: some View {
        Menu {
            Picker("Sides (\(cardFilterSides == 0 ? "Off" : "On"))", selection: $cardFilterSides) {
                Text("Off").tag(0)
                Divider()
                Text("1-Sided Cards").tag(1)
                Text("2-Sided Cards").tag(2)
            }
            if !allTags.isEmpty {
                Picker("Tags (\(cardFilterTags == "off" ? "Off" : "On"))", selection: $cardFilterTags) {
                    // All tags are prefixed with #, so there can't be any confusion between "Off"/"Without Tags" and a tag "#off"/"#none".
                    Text("Off").tag("off")
                    Divider()
                    Text("Without Tags").tag("none")
                    Divider()
                    ForEach(allTags, id: \.self) { tag in
                        Text(tag).tag(tag)
                    }
                }
            }
            Picker("Completed Status (\(cardFilterComplete == 0 ? "Off" : "On"))", selection: $cardFilterComplete) {
                Text("Off").tag(0)
                Divider()
                Text("Not Completed").tag(1)
                Text("Completed").tag(2)
            }
            Picker("Star Rating (\(cardFilterRating == 0 ? "off" : "on"))", selection: $cardFilterRating) {
                Text("Off").tag(0)
                Divider()
                Text("Without Rating").tag(-1)
                Divider()
                Text("1 Star").tag(1)
                Text("2 Stars").tag(2)
                Text("3 Stars").tag(3)
                Text("4 Stars").tag(4)
                Text("5 Stars").tag(5)
            }
            Divider()
            Button("Reset") {
                resetCardFilter()
            }
        } label: {
            Label("Filter", systemImage: cardFilterEnabled ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                .animatedSymbolReplacement()
        }
        .accessibilityLabel("Filter (\(cardFilterEnabled ? "On" : "Off"))")
        .menuIndicator(.hidden)
        .pickerStyle(.menu)

    }

    // MARK: - Add Card Button

    @ViewBuilder
    var addCardButton: some View {
        Button {
            newCard(is2Sided: shouldCreate2SidedCards)
        } label: {
            Label(shouldCreate2SidedCards ? "Add 2-Sided Card" : "Add 1-Sided Card", systemImage: shouldCreate2SidedCards ? "plus.rectangle.on.rectangle" : "plus.rectangle")
        }
    }

    // MARK: - Show Random Card

    func showRandomCard() {
        // 1. Get a random card.
        let randomCard = searchResults.randomElement()!
        // 2. If the random card is different than the selected card, show it.
        if randomCard != selectedCard {
            selectedCard = randomCard
        } else{
            // 3. Otherwise, call this method until a different card is found.
            showRandomCard()
        }
    }

    // MARK: - Mark All Cards As Completed/Not Completed

    func markCardsAs(completed: Bool) {
        for card in searchResults {
            card.isCompleted = completed
        }
    }

    // MARK: - Reset Card Filter

    func resetCardFilter() {
        cardFilterTags = "off"
        cardFilterSides = 0
        cardFilterComplete = 0
        cardFilterRating = 0
    }

    // MARK: - Data Management

    private func newCard(is2Sided: Bool) {
        withAnimation {
            let newItem = Card(title: defaultCardName, is2Sided: is2Sided)
            deck.cards?.append(newItem)
            selectedCard = newItem
            if showSettingsWhenCreating == 2 {
                dialogManager.cardToShowSettings = newItem
            }
            cardFilterRating = 0
            cardFilterComplete = 0
            cardFilterTags = "off"
        }
    }

    private func deleteCards(at offsets: IndexSet) {
        guard let index = offsets.first else { return }
        withAnimation {
            dialogManager.cardToDelete = searchResults[index]
            dialogManager.showingDeleteCard = true
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
