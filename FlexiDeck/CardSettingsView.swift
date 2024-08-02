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

    var card: Card

    @State var newName: String = String()

    @State var is2Sided: Bool = true

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                FormTextField("Card Name", text: $newName)
                Picker("Card Type", selection: $is2Sided) {
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

#Preview {
    CardSettingsView(card: Card(title: "Card", is2Sided: true))
}
