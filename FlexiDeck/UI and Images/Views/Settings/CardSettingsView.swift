//
//  CardSettingsView.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 8/2/24.
//  Copyright © 2024 SheftApps. All rights reserved.
//

import SwiftUI
import SheftAppsStylishUI

struct CardSettingsView: View {

    // MARK: - Properties - Card

    var card: Card

    // MARK: - Properties - Strings

    @State var newName: String = String()

    // MARK: - Properties - Booleans

    @State var is2Sided: Bool = true

    // MARK: - Properties - Dismiss Action

    @Environment(\.dismiss) var dismiss

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                FormTextField("Card Name", text: $newName)
                Picker("Card Type", selection: $is2Sided) {
                    Text("1-Sided").tag(false)
                    Text("2-Sided").tag(true)
                }
                if !is2Sided && card.is2Sided {
                    WarningText("Changing to a 1-sided card will remove the back side of the card.", prefix: .important)
                }
            }
            .formStyle(.grouped)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        card.title = newName
                        card.is2Sided = is2Sided
                        if !card.is2Sided && !card.back.isEmpty {
                            card.back.removeAll()
                        }
                        dismiss()
                    }
                    .disabled(newName.isEmpty)
                }
            }
        }
        .onAppear {
            newName = card.title
            is2Sided = card.is2Sided
        }
    }
}

// MARK: - Preview

#Preview {
    CardSettingsView(card: Card(title: "Card", is2Sided: true))
}
