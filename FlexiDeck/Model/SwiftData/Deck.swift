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
final class Deck: Codable {

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

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case name
        case newCardsAre2Sided
        case cards
    }

    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decodeIfPresent(String.self, forKey: .name)
        let newCardsAre2Sided = try container.decodeIfPresent(Bool.self, forKey: .newCardsAre2Sided)
        let cards = try container.decodeIfPresent([Card].self, forKey: .cards)

        self.init(name: name ?? "", newCardsAre2Sided: newCardsAre2Sided ?? false)
        self.cards = cards
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(newCardsAre2Sided, forKey: .newCardsAre2Sided)
        try container.encodeIfPresent(cards, forKey: .cards)
    }

}
