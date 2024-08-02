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

    var deck: Deck?

    var title: String

    var front: String = String()

    var back: String = String()

    init(title: String) {
        self.title = title
    }
}
