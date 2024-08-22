//
//  SpeechManager.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 8/22/24.
//  Copyright © 2024 SheftApps. All rights reserved.
//

import SwiftUI
import AVFoundation

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
        if textBeingSpoken == text {
            speechSynthesizer.stopSpeaking(at: .immediate)
        } else {
            speechSynthesizer.stopSpeaking(at: .immediate)
            let utterance = AVSpeechUtterance(string: text)
            utterance.voice = AVSpeechSynthesisVoice(identifier: selectedVoiceID)
            speechSynthesizer.speak(utterance)
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
