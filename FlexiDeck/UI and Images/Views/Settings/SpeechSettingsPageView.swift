//
//  SpeechSettingsPageView.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 10/1/24.
//  Copyright © 2024 SheftApps. All rights reserved.
//

import SwiftUI
import SheftAppsStylishUI

struct SpeechSettingsPageView: View {

    // MARK: - Properties - Speech Manager

    @EnvironmentObject var speechManager: SpeechManager

    // MARK: - Properties - Booleans

    @AppStorage(UserDefaults.KeyNames.speakOnSelectionOrFlip) var speakOnSelectionOrFlip: Bool = false

    var body: some View {
        Form {
            Section {
                VoicePicker(selectedVoiceID: speechManager.$selectedVoiceID, voices: speechManager.voices) { voiceID in
                    speechManager.speak(text: SATextSettingsPreviewString)
                }
            }
            Section {
                Toggle("Speak on Card Selection/Flip", isOn: $speakOnSelectionOrFlip)
            } footer: {
                Text("Turn this on to have the front side of a card spoken when it's selected, or the displayed side of a card spoken when it's flipped.")
            }
        }
    }
}

#Preview {
    SpeechSettingsPageView()
}
