//
//  DialogManager.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 8/7/24.
//  Copyright © 2024 SheftApps. All rights reserved.
//

import SwiftUI

// Manages the display of dialogs in the app.
class DialogManager: ObservableObject {

    // MARK: - Properties - Selected Settings Page

#if os(macOS)
    // The page currently selected in the Settings window on macOS.
    @AppStorage("selectedSettingsPage") var selectedSettingsPage: SettingsPage = .display
#endif

    // MARK: - Properties - Booleans

    // Whether the "delete this card" alert should be/is being displayed.
    @Published var showingDeleteCard: Bool = false

    // Whether the "delete this deck" alert should be/is being displayed.
    @Published var showingDeleteDeck: Bool = false

    // Whether the "delete all cards" alert should be/is being displayed.
    @Published var showingDeleteAllCards: Bool = false

    // Whether the "delete all decks" alert should be/is being displayed.
    @Published var showingDeleteAllDecks: Bool = false

#if !os(macOS)
    // Whether the settings sheet should be/is being displayed.
    @Published var showingSettings: Bool = false
#endif

    // MARK: - Properties - Decks and Cards

    // The card to be deleted.
    @Published var cardToDelete: Card? = nil

    // The deck to be deleted.
    @Published var deckToDelete: Deck? = nil

    // The card whose settings are being changed.
    @Published var cardToShowSettings: Card? = nil

    // The deck whose settings are being changed.
    @Published var deckToShowSettings: Deck? = nil

}
