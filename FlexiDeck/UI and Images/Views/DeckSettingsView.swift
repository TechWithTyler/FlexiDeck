//
//  DeckSettingsView.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 8/2/24.
//  Copyright © 2024 SheftApps. All rights reserved.
//

import SwiftUI
import SheftAppsStylishUI

struct DeckSettingsView: View {

    var deck: Deck

    @State var newName: String = String()

    @State var newCardsAre2Sided: Bool = true

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                FormTextField("Deck Name", text: $newName)
                Picker("Card Type for New Cards", selection: $newCardsAre2Sided) {
                    Text("1-Sided").tag(false)
                    Text("2-Sided").tag(true)
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
                        deck.name = newName
                        deck.newCardsAre2Sided = newCardsAre2Sided
                        dismiss()
                    }
                    .disabled(newName.isEmpty)
                }
            }
        }
        .onAppear {
            newName = deck.name
            newCardsAre2Sided = deck.newCardsAre2Sided
        }
    }
}

#Preview {
    DeckSettingsView(deck: Deck(name: "Deck", newCardsAre2Sided: true))
}
