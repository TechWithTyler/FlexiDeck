//
//  SettingsView.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 8/6/24.
//  Copyright © 2024 SheftApps. All rights reserved.
//

import SwiftUI
import SheftAppsStylishUI

struct SettingsView: View {

    // MARK: - Properties - Dismiss Action

#if !os(macOS)
    @Environment(\.dismiss) var dismiss
    #endif

    // MARK: - Properties - Doubles

    @AppStorage("cardTextSize") var cardTextSize: Double = SATextViewMinFontSize

    // MARK: - Properties - Booleans

    @AppStorage("newDecksDefaultTo2SidedCards") var newDecksDefaultTo2SidedCards: Bool = true

    // MARK: - Properties - Integers

    var cardTextSizeAsInt: Int {
        return Int(cardTextSize)
    }

    // MARK: - Properties - Text Size Slider Text

    var cardTextSizeSliderText: String {
        return "Card Text Size: \(cardTextSizeAsInt)pt"
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                Section {
#if os(macOS)
                // Sliders show their labels by default on macOS.
                textSizeSlider
#else
                VStack(spacing: 0) {
                    Text(cardTextSizeSliderText)
                        .padding(5)
                    textSizeSlider
                }
#endif
                    Text("The quick brown fox jumps over the lazy dog.")
                        .font(.system(size: CGFloat(cardTextSize)))
                }
                .animation(.default, value: cardTextSize)
                Section {
                    Picker("Default Card Type for New Decks", selection: $newDecksDefaultTo2SidedCards) {
                        Text("1-Sided").tag(false)
                        Text("2-Sided").tag(true)
                    }
                } footer: {
                    Text("The number of sides a card can have can be changed on a per-card and per-deck basis. This setting specifies the default number of sides for new decks.")
                }
            }
            .formStyle(.grouped)
#if !os(macOS)
            .toolbar {
                ToolbarItem {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        #endif
        }
#if !os(macOS)
    .pickerStyle(.navigationLink)
#endif
    }

    // MARK: - Text Size Slider

    @ViewBuilder
    var textSizeSlider: some View {
        Slider(value: $cardTextSize, in: SATextViewFontSizeRange, step: 1) {
            Text(cardTextSizeSliderText)
        } minimumValueLabel: {
            Image(systemName: "textformat.size.smaller")
                .accessibilityLabel("Smaller")
        } maximumValueLabel: {
            Image(systemName: "textformat.size.larger")
                .accessibilityLabel("Larger")
        }
        .accessibilityValue("\(cardTextSizeAsInt)")
    }

}

// MARK: - Preview

#Preview {
    SettingsView()
}
