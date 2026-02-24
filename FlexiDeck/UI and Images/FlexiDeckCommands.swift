//
//  FlexiDeckCommands.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 8/9/24.
//  Copyright © 2024-2026 SheftApps. All rights reserved.
//

// MARK: - Imports

import SwiftUI
import SheftAppsStylishUI
import SheftAppsInternals

struct FlexiDeckCommands: Commands {

    // MARK: - Properties - Doubles

    @AppStorage(UserDefaults.KeyNames.cardTextSize) var cardTextSize: Double = SATextViewIdealMinFontSize

    // MARK: - Menu Commands

    var body: some Commands {
        TextEditingCommands()
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
        SidebarCommands()
        CommandGroup(replacing: .help) {
            Button("\(SABundleName) Help") {
                showHelp()
            }
                .keyboardShortcut("?", modifiers: .command)
        }
    }

}
