//
//  StarRatingView.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 9/13/24.
//

import SwiftUI

struct StarRatingView: View {

    var card: Card

    var body: some View {
        HStack {
            ForEach(1..<6) { rating in
                StarButtonView(isSelected: card.starRating >= rating) {
                    if card.starRating == rating {
                        card.starRating = 0
                    } else {
                        card.starRating = rating
                    }
                }
                    .accessibilityLabel("\(rating) star")
                    .padding(.horizontal, 5)
            }
        }
        .padding(.horizontal, 5)
        .padding(.vertical, 2)
        .accessibilityLabel("\(card.starRating)-star rating")
    }

}

#Preview {
    StarRatingView(card: Card(title: "Test Card", is2Sided: true))
}
