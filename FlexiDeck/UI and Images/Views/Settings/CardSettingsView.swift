//
//  CardSettingsView.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 8/2/24.
//  Copyright © 2024 SheftApps. All rights reserved.
//

import SwiftUI
import SwiftData
import SheftAppsStylishUI

struct CardSettingsView: View {

    // MARK: - Properties - Card

    var card: Card

    @Query var decks: [Deck] = []

    @State var selectedDeck: Deck

    // MARK: - Properties - Strings

    @State var newName: String = String()

    // MARK: - Properties - Booleans

    @State var is2Sided: Bool = true

    @State var useTitleAsFrontFirstLine: Bool = false

    @FocusState var editingName: Bool

    // MARK: - Properties - Dismiss Action

    @Environment(\.dismiss) var dismiss

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                FormTextField("Name", text: $newName)
                    .focused($editingName, equals: true)
                let firstLineOfFront = card.front.components(separatedBy: .newlines).first!
                if card.front.isEmpty {
                    Toggle("Use Title as Front First Line", isOn: $useTitleAsFrontFirstLine)
                } else if newName == defaultCardName || newName.isEmpty {
                        HStack {
                            Text("Suggested Title")
                            Spacer()
                            Text(firstLineOfFront)
                        }
                        Button("Use Suggested Title") {
                            newName = firstLineOfFront
                        }
                } else if newName == firstLineOfFront {
                    InfoText("The first line of this card's front side will be used as its title.")
                }
                Picker("Type", selection: $is2Sided) {
                    Text("1-Sided").tag(false)
                    Text("2-Sided").tag(true)
                }
                if !is2Sided && (card.is2Sided)! && !card.back.isEmpty {
                    WarningText("Changing to a 1-sided card will remove its back side.", prefix: .important)
                }
                Picker("Deck", selection: $selectedDeck) {
                    ForEach(decks) { deck in
                        if deck.name == card.deck?.name {
                            Text("\(deck.name!) (current)").tag(deck)
                        } else {
                            Text(deck.name!).tag(deck)
                        }
                    }
                }
                if card.deck != selectedDeck {
                    InfoText("This card will be moved from \"\((card.deck?.name)!)\" to \"\((selectedDeck.name)!)\".")
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Card Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveNewSettings()
                        dismiss()
                    }
                    .disabled(newName.isEmpty)
                }
            }
        }
#if !os(macOS)
    .pickerStyle(.navigationLink)
#endif
        .onAppear {
            applyCurrentSettings()
        }
    }

    // MARK: - Reflect Current Settings

    func applyCurrentSettings() {
        newName = card.title ?? String()
        is2Sided = card.is2Sided ?? true
        editingName = true
    }

    // MARK: - Save New Settings

    func saveNewSettings() {
        // 1. Save the new settings.
        card.title = newName
        card.is2Sided = is2Sided
        // 2. If going from a 2-sided card to a 1-sided card and the back side has text on it, clear the back side.
        if !(card.is2Sided)! && !card.back.isEmpty {
            card.back.removeAll()
        }
        // 3. If the card isn't in the selected deck, move it to that deck.
        if card.deck != selectedDeck {
            card.deck?.cards?.remove(at: (card.deck?.cards?.firstIndex(of: card)!)!)
            selectedDeck.cards?.append(card)
        }
        // 4. If the option to use the card's title as the text of the front's first line is enabled, set the card's front side to the title.
        if useTitleAsFrontFirstLine {
            card.front = card.title!
        }
        // 5. Update the card's modified date.
        card.modifiedDate = Date()
    }

}

// MARK: - Preview

#Preview {
    let deck = Deck(name: "Deck", newCardsAre2Sided: true)
    let card = Card(title: "Card", is2Sided: true)
    deck.cards?.append(card)
    card.deck = deck
    return CardSettingsView(card: card, selectedDeck: deck)
        .modelContainer(for: [Deck.self, Card.self], inMemory: true)
}
