//
//  Card.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 7/26/24.
//  Copyright © 2024 SheftApps. All rights reserved.
//

import Foundation
import SwiftData

@Model
final class Card {

    // MARK: - Properties

    var deck: Deck?

    var title: String

    var front: String = String()

    var back: String = String()

    var is2Sided: Bool

    // MARK: - Initialization

    init(title: String, is2Sided: Bool) {
        self.title = title
        self.is2Sided = is2Sided
    }
}
