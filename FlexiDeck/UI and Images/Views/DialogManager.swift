//
//  DialogManager.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 8/7/24.
//

import SwiftUI

class DialogManager: ObservableObject {

    @Published var cardToRename: Card? = nil

    @Published var deckToRename: Deck? = nil

}
