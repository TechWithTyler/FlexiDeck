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

    var front: String

    var back: String

    init(front: String, back: String) {
        self.front = front
        self.back = back
    }
}
