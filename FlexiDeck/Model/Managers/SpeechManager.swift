//
//  SpeechManager.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 8/22/24.
//  Copyright © 2024 SheftApps. All rights reserved.
//

import SwiftUI
import AVFoundation
import SheftAppsStylishUI

class SpeechManager: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {

    // MARK: - Properties - Strings

    @AppStorage(UserDefaults.KeyNames.selectedVoiceID) var selectedVoiceID: String = defaultVoiceID

    @Published var textBeingSpoken: String = String()

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
            }
    }

    // MARK: - Speak Text

    func speak(text: String) {
        DispatchQueue.main.async { [self] in
            // 1. Stop any in-progress speech.
            speechSynthesizer.stopSpeaking(at: .immediate)
            // 2. If the text to be spoken is the text currently being spoken, speech is stopped and we don't continue. The exception is the sample text which is spoken when choosing a voice--the sample text is spoken each time the voice is changed regardless of whether it's currently being spoken.
            if textBeingSpoken != text || text == SATextSettingsPreviewString {
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
