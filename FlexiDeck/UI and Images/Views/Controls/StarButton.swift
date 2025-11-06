//
//  StarButton.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 9/13/24.
//  Copyright © 2024-2025 SheftApps. All rights reserved.
//

// MARK: - Imports

import SwiftUI

struct StarButton: View {

    var rating: Int

    var isSelected: Bool

    var action: () -> Void

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

#Preview("Selected Star") {
    StarButton(rating: 1, isSelected: true) {}
}

#Preview("Unselected Star") {
    StarButton(rating: 1, isSelected: false) {}
}
