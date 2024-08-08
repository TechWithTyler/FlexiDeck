//
//  DialogManager.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 8/7/24.
//  Copyright © 2024 SheftApps. All rights reserved.
//

import SwiftUI

class DialogManager: ObservableObject {

    // MARK: - Properties - Booleans

    @Published var showingDeleteCard: Bool = false

    @Published var showingDeleteDeck: Bool = false

    @Published var showingDeleteAllCards: Bool = false

    @Published var showingDeleteAllDecks: Bool = false

#if !os(macOS)
    @Published var showingSettings: Bool = false
#endif

    // MARK: - Properties - Decks and Cards

    @Published var cardToDelete: Card? = nil

    @Published var deckToDelete: Deck? = nil

    @Published var cardToShowSettings: Card? = nil

    @Published var deckToShowSettings: Deck? = nil

}
