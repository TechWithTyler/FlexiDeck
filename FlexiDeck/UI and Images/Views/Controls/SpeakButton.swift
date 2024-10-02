//
//  SpeakButton.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 8/22/24.
//


import SwiftUI
import SheftAppsStylishUI

struct SpeakButton: View {
    
    @EnvironmentObject var speechManager: SpeechManager

    let text: String

    init(for text: String) {
        self.text = text
    }
    
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

#Preview {
        SpeakButton(for: "This is a test")
            .labelStyle(.topIconBottomTitle)
            .environmentObject(SpeechManager())
}
