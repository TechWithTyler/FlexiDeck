//
//  FlexiDeckCommands.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 8/9/24.
//  Copyright © 2024 SheftApps. All rights reserved.
//

import SwiftUI
import SheftAppsStylishUI

struct FlexiDeckCommands: Commands {

    // MARK: - Properties - Doubles

    @AppStorage(UserDefaults.KeyNames.cardTextSize) var cardTextSize: Double = SATextViewMinFontSize

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
            Button("\(appName!) Help") {
                showHelp()
            }
                .keyboardShortcut("?", modifiers: .command)
        }
    }

}
