//
//  DeckRenameView.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 8/2/24.
//  Copyright © 2024 SheftApps. All rights reserved.
//

import SwiftUI
import SheftAppsStylishUI

struct DeckRenameView: View {

    var deck: Deck

    @State var newName: String = String()

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                FormTextField("Deck Name", text: $newName)
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
                        dismiss()
                    }
                    .disabled(newName.isEmpty)
                }
            }
        }
        .onAppear {
            newName = deck.name
        }
    }
}

#Preview {
    DeckRenameView(deck: Deck(name: "Deck"))
}
