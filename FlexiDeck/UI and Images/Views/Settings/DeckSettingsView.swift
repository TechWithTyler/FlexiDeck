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

    // MARK: - Properties - Deck

    var deck: Deck

    // MARK: - Properties - Strings

    @State var newName: String = String()

    // MARK: - Properties - Booleans

    @State var newCardsAre2Sided: Bool = true

    @FocusState var editingName: Bool

    // MARK: - Properties - Dismiss Action

    @Environment(\.dismiss) var dismiss

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                FormTextField("Name", text: $newName)
                    .focused($editingName, equals: true)
                Picker("Card Type for New Cards", selection: $newCardsAre2Sided) {
                    Text("1-Sided").tag(false)
                    Text("2-Sided").tag(true)
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Deck Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveNewSettings()
                        dismiss()
                    }
                    .disabled(newName.isEmpty)
                }
            }
        }
#if !os(macOS)
    .pickerStyle(.navigationLink)
#endif
        .onAppear {
            applyCurrentSettings()
        }
    }

    // MARK: - Reflect Current Settings

    func applyCurrentSettings() {
        newName = deck.name ?? String()
        newCardsAre2Sided = deck.newCardsAre2Sided ?? true
        editingName = true
    }

    // MARK: - Save New Settings

    func saveNewSettings() {
        deck.name = newName
        deck.newCardsAre2Sided = newCardsAre2Sided
    }

}

// MARK: - Preview

#Preview {
    DeckSettingsView(deck: Deck(name: "Deck", newCardsAre2Sided: true))
}
