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
        }
    }
}

#Preview {
    DecksCardsSettingsPageView()
        .formStyle(.grouped)
}
