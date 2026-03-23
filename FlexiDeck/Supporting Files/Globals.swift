//
//  Globals.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 8/22/24.
//  Copyright © 2024-2026 SheftApps. All rights reserved.
//

// MARK: - Imports

import SheftAppsStylishUI
import SheftAppsInternals

// MARK: - Functions

func showHelp() {
    let helpURL = SAAppHelpURL
    #if os(macOS)
    NSWorkspace.shared.open(helpURL)
    #else
    UIApplication.shared.open(helpURL)
    #endif
}

// MARK: - Properties - Strings

// The default name for new decks.
let defaultDeckName: String = "New Deck"

// The default name for new cards.
let defaultCardName: String = "New Card"

// The name used when a deck/card's name is unavailable/missing.
let nameUnavailableString: String = "Unavailable"

// The name of the filled-bubble speaker SF Symbol used for speech.
let speechSymbolName: String = "speaker.wave.2.bubble.left"
