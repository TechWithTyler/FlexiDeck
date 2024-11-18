//
//  SettingsPage.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 10/1/24.
//  Copyright © 2024-2025 SheftApps. All rights reserved.
//

import Foundation

// A page in Settings.
enum SettingsPage : String {

    enum Icons: String {

        case display = "textformat.size"

        case speech = "speaker.wave.2.bubble.left"

        case decksCards = "rectangle.stack"

    }

    case display

    case speech

    case decksCards = "Decks/Cards"

}
