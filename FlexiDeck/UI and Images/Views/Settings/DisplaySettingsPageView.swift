//
//  DisplaySettingsPageView.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 10/1/24.
//  Copyright © 2024 SheftApps. All rights reserved.
//

import SwiftUI
import SheftAppsStylishUI

struct DisplaySettingsPageView: View {

    // MARK: - Properties - Doubles

    @AppStorage(UserDefaults.KeyNames.cardTextSize) var cardTextSize: Double = SATextViewMinFontSize

    var body: some View {
        Form {
            Section {
                TextSizeSlider(labelText: "Card Text Size", textSize: $cardTextSize, previewText: SATextSettingsPreviewString)
            }
        }
    }
}

#Preview {
    DisplaySettingsPageView()
        .frame(height: 200)
        .formStyle(.grouped)
}
