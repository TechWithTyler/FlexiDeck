//
//  DecksCardsSettingsPageView.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 10/1/24.
//  Copyright © 2024-2026 SheftApps. All rights reserved.
//

// MARK: - Imports

import SwiftUI
import FoundationModels

struct DecksCardsSettingsPageView: View {

    // MARK: - Properties - Strings

    let preferOptionTitle: String = "Prefer Front Side's First Line"

    // MARK: - Properties - Booleans

    @AppStorage(UserDefaults.KeyNames.newDecksDefaultTo2SidedCards) var newDecksDefaultTo2SidedCards: Bool = true

    @AppStorage(UserDefaults.KeyNames.useFilenameAsImportedDeckName) var useFilenameAsImportedDeckName: Bool = true

    @State var foundationModelsSupported: Bool = false

    // MARK: - Properties - Integers

    @AppStorage(UserDefaults.KeyNames.showSettingsWhenCreating) var showSettingsWhenCreating: Int = 1

    @AppStorage(UserDefaults.KeyNames.cardTitleSuggestions) var cardTitleSuggestions: Int = 0

    // MARK: - Body

    var body: some View {
        Form {
            Section {
                Picker("Default Card Type for New Decks", selection: $newDecksDefaultTo2SidedCards) {
                    Text("1-Sided").tag(false)
                    Text("2-Sided").tag(true)
                }
            } footer: {
                Text("The number of sides a card can have can be changed on a per-card and per-deck basis. This setting determines the setting to be used for new decks.")
            }
            Section {
                Picker("Show Settings When Creating", selection: $showSettingsWhenCreating) {
                    Text("Off").tag(0)
                    Text("Decks Only").tag(1)
                    Text("Decks and Cards").tag(2)
                }
            }
            if foundationModelsSupported {
                Section {
                    Picker("Card Title Suggestions", selection: $cardTitleSuggestions) {
                        Text("Always Front Side's First Line").tag(0)
                        Text("Always On-Device AI Suggestions").tag(1)
                        Text(preferOptionTitle).tag(2)
                    }
                } footer: {
                    Text("\"\(preferOptionTitle)\" means card title suggestions will be the front side's first line if it's less than 20 characters. If 20 characters or more, the on-device AI model will be used to generate a short title.")
                }
            }
            Section {
                Toggle("Use Filename as Imported Deck Name", isOn: $useFilenameAsImportedDeckName)
            } footer: {
                Text("When importing decks, turning this setting on will set the deck's name to the name of the deck file. If turned off, the name of the exported deck itself will be kept.\nFor example, if a deck's name is \"Vocab\", but the filename (excluding the \".flexideck\" extension) is \"Vocab Flashcards\", the filename \"Vocab Flashcards\" will become the deck name upon import if this setting is turned on, or it will remain \"Vocab\" if turned off.")
            }
            .onAppear {
                checkForFoundationModels()
            }
        }
    }

        // This method checks whether FoundationModels is supported on the device.
        func checkForFoundationModels() {
            if #available(anyAppleOS 26, *) {
                switch SystemLanguageModel.default.availability {
                case .available:
                    foundationModelsSupported = true
                case .unavailable:
                    foundationModelsSupported = false
                }
            } else {
                foundationModelsSupported = false
            }
        }

    }

    // MARK: - Preview

    #Preview {
        DecksCardsSettingsPageView()
            .formStyle(.grouped)
    }
