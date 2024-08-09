//
//  FlexiDeckCommands.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 8/9/24.
//

import SwiftUI
import SheftAppsStylishUI

struct FlexiDeckCommands: Commands {

    // MARK: - Properties - Doubles

    @AppStorage("cardTextSize") var cardTextSize: Double = SATextViewMinFontSize

    // MARK: - Menu Commands

    var body: some Commands {
        CommandMenu("Format") {
            Button("Decrease Text Size", systemImage: "textformat.size.smaller") {
                cardTextSize -= 1
            }
            .keyboardShortcut("-", modifiers: .command)
            Button("Increase Text Size", systemImage: "textformat.size.larger") {
                cardTextSize += 1
            }
            .keyboardShortcut("+", modifiers: .command)
        }
    }

}
