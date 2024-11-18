//
//  DisplaySettingsPageView.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 10/1/24.
//  Copyright © 2024-2025 SheftApps. All rights reserved.
//

import SwiftUI
import SheftAppsStylishUI

struct DisplaySettingsPageView: View {

    // MARK: - Properties - Doubles

    @AppStorage(UserDefaults.KeyNames.cardTextSize) var cardTextSize: Double = SATextViewMinFontSize

    // MARK: - Properties - Booleans

    @AppStorage(UserDefaults.KeyNames.showNumberOfSides) var showNumberOfSides: Bool = false

    @AppStorage(UserDefaults.KeyNames.cardDateTimeDisplay) var cardDateTimeDisplay: Bool = false

    var body: some View {
        Form {
            Section {
                TextSizeSlider(labelText: "Card Text Size", textSize: $cardTextSize, previewText: SATextSettingsPreviewString)
            }
            Section {
                Picker("Card Date/Time In Card List", selection: $cardDateTimeDisplay) {
                    Text("Date Only").tag(false)
                    Text("Date and Time").tag(true)
                }
                Toggle("Show Number Of Sides In Card List", isOn: $showNumberOfSides)
            }
        }
    }
}

#Preview {
    DisplaySettingsPageView()
        .frame(height: 200)
        .formStyle(.grouped)
}
