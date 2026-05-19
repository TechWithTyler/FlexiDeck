//
//  DisplaySettingsPageView.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 10/1/24.
//  Copyright © 2024-2026 SheftApps. All rights reserved.
//

// MARK: - Imports

import SwiftUI
import SheftAppsStylishUI

struct DisplaySettingsPageView: View {

    // MARK: - Properties - Doubles

    @AppStorage(UserDefaults.KeyNames.cardTextSize) var cardTextSize: Double = SATextViewIdealMinFontSize

    // MARK: - Body

    var body: some View {
        Form {
            Section {
                TextSizeSlider("Card Text Size", textSize: $cardTextSize, previewText: SATextSettingsPreviewString)
            }
            Section("Card List Detail") {
                CardListDetailOptions()
            }
        }
    }
    
}

// MARK: - Preview

#Preview {
    DisplaySettingsPageView()
        .frame(height: 200)
        .formStyle(.grouped)
}
