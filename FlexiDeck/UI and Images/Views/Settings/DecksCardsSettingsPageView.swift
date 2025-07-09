//
//  DecksCardsSettingsPageView.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 10/1/24.
//  Copyright © 2024-2025 SheftApps. All rights reserved.
//

import SwiftUI

struct DecksCardsSettingsPageView: View {

    // MARK: - Properties - Booleans

    @AppStorage(UserDefaults.KeyNames.newDecksDefaultTo2SidedCards) var newDecksDefaultTo2SidedCards: Bool = true

    @AppStorage(UserDefaults.KeyNames.useFilenameAsImportedDeckName) var useFilenameAsImportedDeckName: Bool = true

    // MARK: - Properties - Integers

    @AppStorage(UserDefaults.KeyNames.showSettingsWhenCreating) var showSettingsWhenCreating: Int = 1

    var body: some View {
        Form {
            Section {
                Picker("Default Card Type for New Decks", selection: $newDecksDefaultTo2SidedCards) {
                    Text("1-Sided").tag(false)
                    Text("2-Sided").tag(true)
                }
            } footer: {
                Text("The number of sides a card can have can be changed on a per-card and per-deck basis. This setting determines the default number of sides for new decks.")
            }
            Section {
                Picker("Show Settings When Creating", selection: $showSettingsWhenCreating) {
                    Text("Off").tag(0)
                    Text("Decks Only").tag(1)
                    Text("Decks and Cards").tag(2)
                }
            }
            Section {
                Toggle("Use Filename as Imported Deck Name", isOn: $useFilenameAsImportedDeckName)
            } footer: {
                Text("When importing decks, turning this setting on will set the deck's name to the name of the deck file. If turned off, the name of the exported deck itself will be kept.\nFor example, if a deck's name is \"Vocab\", but the filename (excluding the \".flexideck\" extension) is \"Vocab Flashcards\", the filename \"Vocab Flashcards\" will become the deck name upon import if this setting is turned on, or it will remain \"Vocab\" if turned off.")
            }
        }
    }
}

#Preview {
    DecksCardsSettingsPageView()
        .formStyle(.grouped)
}
