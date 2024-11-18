//
//  Deck.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 8/2/24.
//  Copyright © 2024-2025 SheftApps. All rights reserved.
//

import Foundation
import SwiftData

@Model
final class Deck {

    // MARK: - Properties

    var name: String?

    var newCardsAre2Sided: Bool?

    @Relationship(deleteRule: .cascade, inverse: \Card.deck)
    var cards: [Card]? = []

    // MARK: - Initialization

    init(name: String, newCardsAre2Sided: Bool) {
        self.newCardsAre2Sided = newCardsAre2Sided
        self.name = name
    }

}
