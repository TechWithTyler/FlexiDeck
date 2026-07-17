//
//  UserDefaultsKeyNames.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 8/9/24.
//  Copyright © 2024-2026 SheftApps. All rights reserved.
//

// MARK: - Imports

import Foundation

extension UserDefaults {

    // Names of UserDefaults keys.
    struct KeyNames {

        // MARK: - UserDefaults Key Names

        static let cardTextSize: String = "cardTextSize"

        static let cardSortMode: String = "cardSortMode"

        static let deckSortMode: String = "deckSortMode"

        static let selectedSettingsPage: String = "selectedSettingsPage"

        static let newDecksDefaultTo2SidedCards: String = "newDecksDefaultTo2SidedCards"

        static let showSettingsWhenCreating: String = "showSettingsWhenCreating"

        static let cardTitleSuggestions: String = "cardTitleSuggestions"

        static let showNumberOfSides: String = "showNumberOfSides"

        static let cardDateTimeDisplay: String = "cardDateTimeDisplay"

        static let selectedVoiceID: String = "selectedVoiceID"

        static let speakOnSelectionOrFlip: String = "speakOnSelectionOrFlip"

        static let useFilenameAsImportedDeckName: String = "useFilenameAsImportedDeckName"

    }

}
