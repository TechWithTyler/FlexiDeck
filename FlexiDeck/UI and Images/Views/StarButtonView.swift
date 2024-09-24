//
//  StarButtonView.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 9/13/24.
//  Copyright © 2024 SheftApps. All rights reserved.
//

import SwiftUI

struct StarButtonView: View {

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
    StarButtonView(rating: 1, isSelected: true) {}
}

#Preview("Unselected Star") {
    StarButtonView(rating: 1, isSelected: false) {}
}
