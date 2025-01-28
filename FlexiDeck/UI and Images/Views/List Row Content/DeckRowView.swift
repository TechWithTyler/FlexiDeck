//
//  DeckRowView.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 8/20/24.
//  Copyright © 2024-2025 SheftApps. All rights reserved.
//

import SwiftUI

struct DeckRowView: View {

    var deck: Deck

    var cardCountText: String {
        guard let cardCount = deck.cards?.count else { fatalError("Card count unavailable") }
        let countSingularOrPlural = cardCount == 1 ? "card" : "cards"
        return "\(cardCount) \(countSingularOrPlural)"
    }

    var body: some View {
        HStack {
            Text(deck.name ?? String())
                .badge(cardCountText)
        }
    }
}

#Preview {
    DeckRowView(deck: Deck(name: "Test Deck", newCardsAre2Sided: true))
}
