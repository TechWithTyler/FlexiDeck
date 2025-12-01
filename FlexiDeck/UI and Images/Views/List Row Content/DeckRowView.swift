//
//  DeckRowView.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 8/20/24.
//  Copyright © 2024-2026 SheftApps. All rights reserved.
//

// MARK: - Imports

import SwiftUI

struct DeckRowView: View {

    // MARK: - Properties - Deck

    var deck: Deck

    // MARK: - Properties - Strings

    var cardCountText: String {
        guard let cardCount = deck.cards?.count else { fatalError("Card count unavailable") }
        let countSingularOrPlural = cardCount == 1 ? "card" : "cards"
        return "\(cardCount) \(countSingularOrPlural)"
    }

    // MARK: - Body

    var body: some View {
        HStack {
            Text(deck.name ?? String())
                .badge(cardCountText)
        }
    }

}

// MARK: - Preview

#Preview {
    DeckRowView(deck: Deck(name: "Test Deck", newCardsAre2Sided: true))
}
