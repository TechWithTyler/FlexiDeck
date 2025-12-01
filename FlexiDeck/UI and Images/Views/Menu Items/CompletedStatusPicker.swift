//
//  CompletedStatusPicker.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 11/13/25.
//  Copyright © 2024-2026 SheftApps. All rights reserved.
//

// MARK: - Imports

import SwiftUI

struct CompletedStatusPicker: View {

    // MARK: - Properties - Card

    @Bindable var card: Card

    // MARK: - Body

    var body: some View {

        Picker(selection: $card.isCompleted) {
            Text("Completed").tag(true)
            Text("Not Completed").tag(false)
        } label: {
            Label("Mark As", systemImage: "checkmark.circle")
        }
    }

}

// MARK: - Preview

#Preview {
    CompletedStatusPicker(card: Card(title: "Card", is2Sided: true))
}
