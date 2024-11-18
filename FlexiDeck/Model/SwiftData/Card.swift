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
final class Card {

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

    // MARK: - Properties

    var deck: Deck?

    var title: String?

    var creationDate = Date()

    var modifiedDate = Date()

    var front: String = String()

    var back: String = String()

    var is2Sided: Bool?

    var tags: [String] = []

    var starRating: Int = 0

    var isCompleted: Bool = false

    // MARK: - Initialization

    init(title: String, is2Sided: Bool) {
        self.title = title
        self.is2Sided = is2Sided
    }
}
