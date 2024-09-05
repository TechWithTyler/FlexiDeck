//
//  CardView.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 7/29/24.
//  Copyright © 2024 SheftApps. All rights reserved.
//

import SwiftUI
import SheftAppsStylishUI

struct CardView: View {

    @EnvironmentObject var speechManager: SpeechManager

    // MARK: - Properties - Card

    @Bindable var selectedCard: Card

    // MARK: - Properties - Doubles

    @AppStorage(UserDefaults.KeyNames.cardTextSize) var cardTextSize: Double = SATextViewMinFontSize

    @AppStorage(UserDefaults.KeyNames.speakOnSelectionOrFlip) var speakOnSelectionOrFlip: Bool = false

    // MARK: - Properties - Booleans

    @State var isFlipped: Bool = false

    // MARK: - Properties - Dialog Manager

    @EnvironmentObject var dialogManager: DialogManager

    // MARK: - Body

    var body: some View {
        TextEditor(text: isFlipped ? $selectedCard.back : $selectedCard.front)
            .font(.system(size: CGFloat(cardTextSize)))
            .navigationTitle((selectedCard.is2Sided)! ? "\(selectedCard.title ?? String()) - \(isFlipped ? "Back" : "Front")" : selectedCard.title ?? String())
            .padding()
            .onAppear {
                if speakOnSelectionOrFlip {
                    speechManager.speak(text: selectedCard.front)
                }
            }
            .onChange(of: selectedCard) { oldValue, newValue in
                isFlipped = false
                if speakOnSelectionOrFlip {
                    speechManager.speak(text: selectedCard.front)
                }
            }
            .onChange(of: isFlipped) { oldValue, newValue in
                speechManager.speechSynthesizer.stopSpeaking(at: .immediate)
                if speakOnSelectionOrFlip {
                    speechManager.speak(text: isFlipped ? selectedCard.back : selectedCard.front)
                }
            }
            .toolbar {
                ToolbarItemGroup {
                    Button {
                        cardTextSize -= 1
                    } label: {
                        Label("Decrease Text Size", systemImage: "textformat.size.smaller")
                            .frame(width: 30)
                    }
                    .disabled(cardTextSize == SATextViewMinFontSize)
                    Button {
                        cardTextSize += 1
                    } label: {
                        Label("Increase Text Size", systemImage: "textformat.size.larger")
                            .frame(width: 30)
                    }
                    .disabled(cardTextSize == SATextViewMaxFontSize)
                } label: {
                    Text("Text Size")
                }
                ToolbarItem {
                    Spacer()
                }
                ToolbarItem {
                    OptionsMenu(title: .menu) {
                        if (selectedCard.is2Sided)! {
                            Button(isFlipped ? "Flip to Front" : "Flip to Back", systemImage: "arrow.trianglehead.left.and.right.righttriangle.left.righttriangle.right") {
                                isFlipped.toggle()
                            }
                        }
                        if isFlipped ? !selectedCard.back.isEmpty : !selectedCard.front.isEmpty {
                            SpeakButton(for: isFlipped ? selectedCard.back : selectedCard.front)
                        }
                        Button("Card Settings…", systemImage: "gear") {
                            dialogManager.cardToShowSettings = selectedCard
                        }
                        Divider()
                        Button(role: .destructive) {
                            dialogManager.cardToDelete = selectedCard
                            dialogManager.showingDeleteCard = true
                        } label: {
                            Label("Delete…", systemImage: "trash")
                        }
                    }
                }
            }
    }

}

// MARK: - Preview

#Preview {
    CardView(selectedCard: Card(title: "Preview Card", is2Sided: true))
        .environmentObject(DialogManager())
}
