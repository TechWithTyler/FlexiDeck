//
//  SpeechManager.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 8/22/24.
//  Copyright © 2024-2025 SheftApps. All rights reserved.
//

// MARK: - Imports

import SwiftUI
import AVFoundation
import SheftAppsStylishUI

class SpeechManager: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {

    // MARK: - Properties - Strings

    @AppStorage(UserDefaults.KeyNames.selectedVoiceID) var selectedVoiceID: String = SADefaultVoiceID

    @Published var textBeingSpoken: String = String()

    // MARK: - Properties - Booleans

    @AppStorage(UserDefaults.KeyNames.speakOnSelectionOrFlip) var speakOnSelectionOrFlip: Bool = false

    // MARK: - Properties - Speech

    @Published var voices: [AVSpeechSynthesisVoice] = []

    var speechSynthesizer = AVSpeechSynthesizer()

    // MARK: - Initialization

    override init() {
        super.init()
        loadVoices()
        speechSynthesizer.delegate = self
    }

    // MARK: - Load Voices

    // This method loads all installed voices into the app.
    func loadVoices() {
            AVSpeechSynthesizer.requestPersonalVoiceAuthorization { [self] status in
                voices = AVSpeechSynthesisVoice.speechVoices().filter({$0.language == "en-US"})
                if voices.filter({$0.identifier == selectedVoiceID}).isEmpty {
                    // If the selected voice ID is not available, set it to the default voice ID.
                    selectedVoiceID = SADefaultVoiceID
                }
            }
    }

    // MARK: - Speak Text

    func speak(text: String, forSettingsPreview: Bool = false) {
        DispatchQueue.main.async { [self] in
            // 1. Stop any in-progress speech.
            speechSynthesizer.stopSpeaking(at: .immediate)
            // 2. If the text to be spoken is the text currently being spoken, speech is stopped and we don't continue. The exception is the sample text which is spoken when choosing a voice--the sample text is spoken each time the voice is changed regardless of whether it's currently being spoken.
            if textBeingSpoken != text || forSettingsPreview {
                // 3. If we get here, create an AVSpeechUtterance with the given String (in this case, the text passed into this method).
                let utterance = AVSpeechUtterance(string: text)
                // 4. Set the voice for the utterance.
                utterance.voice = AVSpeechSynthesisVoice(identifier: selectedVoiceID)
                // 5. Speak the utterance.
                speechSynthesizer.speak(utterance)
            }
        }
    }

    // MARK: - Speech Synthesizer Delegate

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        textBeingSpoken = utterance.speechString
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        textBeingSpoken.removeAll()
    }

}
