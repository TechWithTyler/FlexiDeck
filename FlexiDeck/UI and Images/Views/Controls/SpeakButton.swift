//
//  SpeakButton.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 8/22/24.
//  Copyright © 2024-2025 SheftApps. All rights reserved.
//

// MARK: - Imports

import SwiftUI
import SheftAppsStylishUI

struct SpeakButton: View {

    // MARK: - Properties - Speech Manager

    @EnvironmentObject var speechManager: SpeechManager

    // MARK: - Properties - Strings

    let text: String

    // MARK: - Initialization

    init(for text: String) {
        self.text = text
    }

    // MARK: - Body

    var body: some View {
        Button {
            speechManager.speak(text: text)
        } label: {
            Label(speechManager.textBeingSpoken == text ? "Stop" : "Speak", systemImage: speechManager.textBeingSpoken == text ? "stop" : speechSymbolName)
                .frame(width: 30)
                .animatedSymbolReplacement()
        }
    }

}

// MARK: - Preview

#Preview {
        SpeakButton(for: "This is a test")
            .labelStyle(.topIconBottomTitle)
            .environmentObject(SpeechManager())
}
