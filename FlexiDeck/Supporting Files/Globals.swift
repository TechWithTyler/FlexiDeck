//
//  Globals.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 8/22/24.
//  Copyright © 2024-2026 SheftApps. All rights reserved.
//

// MARK: - Imports

import SheftAppsStylishUI

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
let defaultDeckName = "New Deck"

// The default name for new cards.
let defaultCardName = "New Card"

// The name of the filled-bubble speaker SF Symbol used for speech.
let speechSymbolName = "speaker.wave.2.bubble.left"
