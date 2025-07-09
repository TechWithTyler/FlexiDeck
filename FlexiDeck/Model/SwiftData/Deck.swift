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
final class Deck: Codable, Sendable {

    // MARK: - CodingKeys Enum

    enum CodingKeys: String, CodingKey {

        case name

        case newCardsAre2Sided

        case cards

    }

    // MARK: - Properties

    var name: String?

    var newCardsAre2Sided: Bool?

    @Relationship(deleteRule: .cascade, inverse: \Card.deck)
    var cards: [Card]? = []

    // MARK: - Initialization - New Deck

    init(name: String, newCardsAre2Sided: Bool) {
        self.newCardsAre2Sided = newCardsAre2Sided
        self.name = name
    }

    // MARK: - Initialization - Decode Deck for Import

    required convenience init(from decoder: Decoder) throws {
        // 1. Create a container for the decoded data.
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // 2. Try to decode the deck properties from the container.
        let name = try container.decodeIfPresent(String.self, forKey: .name)
        let newCardsAre2Sided = try container.decodeIfPresent(Bool.self, forKey: .newCardsAre2Sided)
        let cards = try container.decodeIfPresent([Card].self, forKey: .cards)
        // 3. Create a new Deck object with the decoded properties by calling the "new deck" initializer above and setting the cards property.
        self.init(name: name ?? "", newCardsAre2Sided: newCardsAre2Sided ?? false)
        self.cards = cards
    }

    func encode(to encoder: Encoder) throws {
        // 1. Create a container for the encoded data.
        var container = encoder.container(keyedBy: CodingKeys.self)
        // 2. Encode the deck properties into the container.
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(newCardsAre2Sided, forKey: .newCardsAre2Sided)
        try container.encodeIfPresent(cards, forKey: .cards)
    }

}
