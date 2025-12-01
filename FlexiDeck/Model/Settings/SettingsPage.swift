//
//  SettingsPage.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 10/1/24.
//  Copyright © 2024-2026 SheftApps. All rights reserved.
//

// MARK: - Imports

import Foundation

// MARK: - Settings Page Enum

// A page in Settings.
enum SettingsPage : String {

    // MARK: - Settings Page Icons Enum

    enum Icons: String {

        case display = "textformat.size"

        case speech = "speaker.wave.2.bubble.left"

        case decksCards = "rectangle.stack"

    }

    // MARK: - Settings Page Enum Cases

    case display

    case speech

    case decksCards = "Decks/Cards"

}
