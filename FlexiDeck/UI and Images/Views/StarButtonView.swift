//
//  StarButtonView.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 9/13/24.
//  Copyright © 2024 SheftApps. All rights reserved.
//

import SwiftUI

struct StarButtonView: View {

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
    }
}

#Preview("Selected Star") {
    StarButtonView(isSelected: true) {}
}

#Preview("Unselected Star") {
    StarButtonView(isSelected: false) {}
}
