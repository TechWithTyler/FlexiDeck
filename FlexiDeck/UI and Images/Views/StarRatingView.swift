//
//  StarRatingView.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 9/13/24.
//

// MARK: - Imports

import SwiftUI

struct StarRatingView: View {

    var card: Card

    var body: some View {
        VStack {
            Text("Rating")
            HStack {
                ForEach(1..<6) { rating in
                    StarButton(rating: rating, isSelected: card.starRating >= rating) {
                        setStarRating(to: rating)
                    }
                    .padding(.horizontal, 5)
                }
            }
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
        }
        .padding(.top, 10)
    }

    func setStarRating(to rating: Int) {
        // 1. If the card's star rating is the same as the star that was selected, set the rating to 0. Otherwise, set it to that rating.
        if card.starRating == rating {
            card.starRating = 0
        } else {
            card.starRating = rating
        }
        // 2. Set the card's modified date to the current date/time.
        card.modifiedDate = Date()
    }

}

#Preview {
    StarRatingView(card: Card(title: "Test Card", is2Sided: true))
}
