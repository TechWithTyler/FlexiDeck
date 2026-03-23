//
//  StarButton.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 9/13/24.
//  Copyright © 2024-2026 SheftApps. All rights reserved.
//

// MARK: - Imports

import SwiftUI

struct StarButton: View {

    // MARK: - Properties - Integers

    var rating: Int

    // MARK: - Properties - Booleans

    var isSelected: Bool

    // MARK: - Properties - Selection Action

    var action: () -> Void

    // MARK: - Body

    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: isSelected ? "star.fill" : "star")
                .symbolRenderingMode(.multicolor)
        }
        .buttonStyle(.borderless)
        .accessibilityLabel("\(rating)-star")
        .accessibilityConditionalTrait(.isSelected, condition: isSelected)
    }

}

// MARK: - Preview

#Preview("Selected Star") {
    StarButton(rating: 1, isSelected: true) {}
}

#Preview("Unselected Star") {
    StarButton(rating: 1, isSelected: false) {}
}
