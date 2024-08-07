//
//  DialogManager.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 8/7/24.
//

import SwiftUI

class DialogManager: ObservableObject {

    @Published var showingDeleteCard: Bool = false

    @Published var showingDeleteDeck: Bool = false

    @Published var showingDeleteAllCards: Bool = false

    @Published var showingDeleteAllDecks: Bool = false

#if !os(macOS)
    @Published var showingSettings: Bool = false
#endif

    @Published var cardToDelete: Card? = nil

    @Published var deckToDelete: Deck? = nil

    @Published var cardToRename: Card? = nil

    @Published var deckToRename: Deck? = nil

}
