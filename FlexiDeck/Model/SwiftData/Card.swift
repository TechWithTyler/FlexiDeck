//
//  Card.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 7/26/24.
//  Copyright © 2024-2025 SheftApps. All rights reserved.
//

import Foundation
import SwiftData

@Model
final class Card: Codable {

    // MARK: - Enums - Sort Mode

    enum SortMode: Int {

        case titleAscending = 0

        case titleDescending = 1

        case starRatingAscending = 2

        case starRatingDescending = 3

        case creationDateAscending = 4

        case creationDateDescending = 5

        case modifiedDateAscending = 6

        case modifiedDateDescending = 7

    }

    // MARK: - Enums - CodingKeys

    private enum CodingKeys: String, CodingKey {

        case title

        case creationDate

        case modifiedDate

        case front

        case back

        case is2Sided

        case tags

        case starRating

        case isCompleted

    }

    // MARK: - Properties

    // A weak reference to the deck containing this card. This property is excluded from encoding and decoding to prevent recursion and circular references.
    weak var deck: Deck?

    var title: String?

    var creationDate = Date()

    var modifiedDate = Date()

    var front: String = String()

    var back: String = String()

    var is2Sided: Bool?

    var tags: [String] = []

    var starRating: Int = 0

    var isCompleted: Bool = false

    // MARK: - Initialization - New Card

    init(title: String, is2Sided: Bool) {
        self.title = title
        self.is2Sided = is2Sided
    }

    // MARK: - Initialization - Decode Card for Import

    required init(from decoder: Decoder) throws {
        // 1. Create a container for the decoded data.
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // 2. Try to decode the card properties from the container.
        title = try container.decodeIfPresent(String.self, forKey: .title)
        creationDate = try container.decode(Date.self, forKey: .creationDate)
        modifiedDate = try container.decode(Date.self, forKey: .modifiedDate)
        front = try container.decode(String.self, forKey: .front)
        back = try container.decode(String.self, forKey: .back)
        is2Sided = try container.decodeIfPresent(Bool.self, forKey: .is2Sided)
        tags = try container.decode([String].self, forKey: .tags)
        starRating = try container.decode(Int.self, forKey: .starRating)
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        // This is where we would initialize a new Card object with the decoded data, except we don't need to--encoding/decoding Card is only necessary for encoded/decoded Decks to have a cards property.
    }

    func encode(to encoder: Encoder) throws {
        // 1. Create a container for the encoded data.
        var container = encoder.container(keyedBy: CodingKeys.self)
        // 2. Encode the deck properties into the container.
        try container.encodeIfPresent(title, forKey: .title)
        try container.encode(creationDate, forKey: .creationDate)
        try container.encode(modifiedDate, forKey: .modifiedDate)
        try container.encode(front, forKey: .front)
        try container.encode(back, forKey: .back)
        try container.encodeIfPresent(is2Sided, forKey: .is2Sided)
        try container.encode(tags, forKey: .tags)
        try container.encode(starRating, forKey: .starRating)
        try container.encode(isCompleted, forKey: .isCompleted)
    }
}
