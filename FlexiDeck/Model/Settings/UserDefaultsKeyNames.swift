//
//  UserDefaultsKeyNames.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 8/9/24.
//  Copyright © 2024-2025 SheftApps. All rights reserved.
//

// MARK: - Imports

import Foundation

extension UserDefaults {

    struct KeyNames {

        // MARK: - UserDefaults Key Names

        static let cardTextSize: String = "cardTextSize"

        static let cardSortMode = "cardSortMode"

        static let sortCardsAscending = "sortCardsAscending"

        static let newDecksDefaultTo2SidedCards: String = "newDecksDefaultTo2SidedCards"

        static let showSettingsWhenCreating: String = "showSettingsWhenCreating"

        static let showNumberOfSides: String = "showNumberOfSides"

        static let cardDateTimeDisplay: String = "cardDateTimeDisplay"

        static let selectedVoiceID: String = "selectedVoiceID"

        static let speakOnSelectionOrFlip: String = "speakOnSelectionOrFlip"

        static let useFilenameAsImportedDeckName: String = "useFilenameAsImportedDeckName"

    }

}
