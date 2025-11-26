//
//  SpeechSettingsPageView.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 10/1/24.
//  Copyright © 2024-2025 SheftApps. All rights reserved.
//

// MARK: - Imports

import SwiftUI
import SheftAppsStylishUI

struct SpeechSettingsPageView: View {

    // MARK: - Properties - Speech Manager

    @EnvironmentObject var speechManager: SpeechManager

    // MARK: - Body

    var body: some View {
        Form {
            Section {
                VoicePicker(selectedVoiceID: speechManager.$selectedVoiceID, voices: speechManager.voices) { voiceID in
                    speechManager.speak(text: SATextSettingsPreviewString, forSettingsPreview: true)
                }
                PlayButton(noun: "Sample Text", isPlaying: speechManager.textBeingSpoken == SATextSettingsPreviewString) {
                    if speechManager.textBeingSpoken == SATextSettingsPreviewString {
                        speechManager.speechSynthesizer.stopSpeaking(at: .immediate)
                    } else {
                        speechManager.speak(text: SATextSettingsPreviewString, forSettingsPreview: true)
                    }
                }
            }
            Section {
                Toggle("Speak on Card Selection/Flip", isOn: $speechManager.speakOnSelectionOrFlip)
            } footer: {
                Text("Turn this on to have the front side of a card spoken when it's selected, or the displayed side of a card spoken when it's flipped.")
            }
        }
    }

}

// MARK: - Preview

#Preview {
    SpeechSettingsPageView()
        .environmentObject(SpeechManager())
        .formStyle(.grouped)
}
