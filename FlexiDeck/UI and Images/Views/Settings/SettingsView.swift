//
//  SettingsView.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 8/6/24.
//  Copyright © 2024 SheftApps. All rights reserved.
//

import SwiftUI
import SheftAppsStylishUI

struct SettingsView: View {

    // MARK: - Properties - Dismiss Action

#if !os(macOS)
    @Environment(\.dismiss) var dismiss
#endif

    // MARK: - Properties - Doubles

    @AppStorage(UserDefaults.KeyNames.cardTextSize) var cardTextSize: Double = SATextViewMinFontSize

    // MARK: - Properties - Booleans

    @AppStorage(UserDefaults.KeyNames.newDecksDefaultTo2SidedCards) var newDecksDefaultTo2SidedCards: Bool = true

    @AppStorage(UserDefaults.KeyNames.showSettingsWhenCreating) var showSettingsWhenCreating: Bool = true

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextSizeSlider(labelText: "Card Text Size", textSize: $cardTextSize, previewText: SATextSettingsPreviewString)
                }
                Section {
                    Picker("Default Card Type for New Decks", selection: $newDecksDefaultTo2SidedCards) {
                        Text("1-Sided").tag(false)
                        Text("2-Sided").tag(true)
                    }
                } footer: {
                    Text("The number of sides a card can have can be changed on a per-card and per-deck basis. This setting specifies the default number of sides for new decks.")
                }
                Section {
                    Toggle("Show Deck/Card Settings When Creating", isOn: $showSettingsWhenCreating)
                } footer: {
                    Text("Turn this on to show the deck/card settings when creating a new deck or card.")
                }
            }
            .formStyle(.grouped)
#if !os(macOS)
            .toolbar {
                ToolbarItem {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
#endif
        }
#if !os(macOS)
        .pickerStyle(.navigationLink)
#endif
    }

}

// MARK: - Preview

#Preview {
    SettingsView()
}
