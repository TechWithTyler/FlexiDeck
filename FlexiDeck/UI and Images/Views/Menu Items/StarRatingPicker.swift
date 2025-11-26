//
//  StarRatingPicker.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 11/13/25.
//  Copyright © 2024-2025 SheftApps. All rights reserved.
//

// MARK: - Imports

import SwiftUI

struct StarRatingPicker: View {

    // MARK: - Properties - Card

    @Bindable var card: Card

    // MARK: - Body

    var body: some View {
        Picker(selection: $card.starRating) {
            Text("No Rating").tag(0)
            Divider()
            Text("1 Star").tag(1)
            Text("2 Stars").tag(2)
            Text("3 Stars").tag(3)
            Text("4 Stars").tag(4)
            Text("5 Stars").tag(5)
        } label: {
            Label("Star Rating", systemImage: "star")
        }
    }

}

// MARK: - Preview

#Preview {
    StarRatingPicker(card: Card(title: "Card", is2Sided: true))
}
