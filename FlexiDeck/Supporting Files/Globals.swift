//
//  Globals.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 8/22/24.
//  Copyright © 2024-2025 SheftApps. All rights reserved.
//

// MARK: - Imports

import SwiftUI

// MARK: - Functions

func showHelp() {
    let helpURL = URL(string: "https://techwithtyler20.weebly.com/\((appName?.lowercased())!)help")!
    #if os(macOS)
    NSWorkspace.shared.open(helpURL)
    #else
    UIApplication.shared.open(helpURL)
    #endif
}

// MARK: - Properties - Strings

// The application name.
let appName: String? = (Bundle.main.infoDictionary?[String(kCFBundleNameKey)] as? String)!

// The default name for new decks.
let defaultDeckName = "New Deck"

// The default name for new cards.
let defaultCardName = "New Card"

// The name of the filled-bubble speaker SF Symbol used for speech.
let speechSymbolName = "speaker.wave.2.bubble.left"
