//
//  CardView.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 7/29/24.
//  Copyright © 2024-2025 SheftApps. All rights reserved.
//

import SwiftUI
import SheftAppsStylishUI

struct CardView: View {

    @EnvironmentObject var speechManager: SpeechManager

    // MARK: - Properties - Card

    @Bindable var selectedCard: Card

    // MARK: - Properties - Strings

    @State var front: String = String()

    @State var back: String = String()

    // MARK: - Properties - Doubles

    @AppStorage(UserDefaults.KeyNames.cardTextSize) var cardTextSize: Double = SATextViewMinFontSize

    // MARK: - Properties - Booleans

    @State var isFlipped: Bool = false

    @FocusState var frontFocused: Bool

    @FocusState var backFocused: Bool

    // MARK: - Properties - Dialog Manager

    @EnvironmentObject var dialogManager: DialogManager

    // MARK: - Body

    var body: some View {
        TranslucentFooterVStack {
            ZStack {
                // The flip animation is achieved by stacking 2 TextEditors on top of each other, one for the front side and one for the back side. The visible side's TextEditor is at the top of the ZStack and the hidden one is disabled.
                TextEditor(text: $front)
                    .rotation3DEffect(.degrees(isFlipped ? 90 : 0), axis: (x: 0, y: 1, z: 0))
                    .animation(isFlipped ? .linear : .linear.delay(0.35), value: isFlipped)
                    .font(.system(size: CGFloat(cardTextSize)))
                    .scrollContentBackground(.hidden)
                    .scrollClipDisabled(true)
                    .disabled(isFlipped)
                    .focused($frontFocused)
                    .zIndex(isFlipped ? 0 : 1)
                TextEditor(text: $back)
                    .rotation3DEffect(.degrees(isFlipped ? 0 : -90), axis: (x: 0, y: 1, z: 0))
                    .animation(isFlipped ? .linear.delay(0.35) : .linear, value: isFlipped)
                    .font(.system(size: CGFloat(cardTextSize)))
                    .scrollContentBackground(.hidden)
                    .scrollClipDisabled(true)
                    .disabled(!isFlipped)
                    .focused($backFocused)
                    .zIndex(isFlipped ? 1 : 0)
            }
        } translucentFooterContent: {
            Text(DateFormatter.localizedString(from: selectedCard.modifiedDate, dateStyle: .short, timeStyle: .short))
                .foregroundStyle(.secondary)
            StarRatingView(card: selectedCard)
        }
        .navigationTitle((selectedCard.is2Sided)! ? "\(selectedCard.title ?? String()) - \(isFlipped ? "Back" : "Front")" : selectedCard.title ?? String())
        .toolbar {
            if (selectedCard.is2Sided)! {
                ToolbarItem {
                    Button(isFlipped ? "Flip to Front" : "Flip to Back", systemImage: "arrow.trianglehead.left.and.right.righttriangle.left.righttriangle.right") {
                        isFlipped.toggle()
                    }
                    .keyboardShortcut(.return, modifiers: .command)
                }
            }
            ToolbarItem {
                OptionsMenu(title: .menu) {
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
        .onAppear {
            loadCard(card: selectedCard)
        }
        .onDisappear {
            saveCard(card: selectedCard)
        }
        .onChange(of: front, { oldValue, newValue in
            saveCard(card: selectedCard)
        })
        .onChange(of: back, { oldValue, newValue in
            saveCard(card: selectedCard)
        })
        .onChange(of: selectedCard) { oldCard, newCard in
            selectedCardChanged(oldCard: oldCard, newCard: newCard)
        }
        .onChange(of: selectedCard.is2Sided!, { oldValue, newValue in
            backFocused = false
            isFlipped = false
            if !newValue {
                back.removeAll()
            }
        })
        .onChange(of: isFlipped) { oldValue, newValue in
            frontFocused = false
            backFocused = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                if isFlipped {
                    backFocused = true
                } else {
                    frontFocused = true
                }
            }
            speechManager.speechSynthesizer.stopSpeaking(at: .immediate)
            if speechManager.speakOnSelectionOrFlip {
                speechManager.speak(text: isFlipped ? selectedCard.back : selectedCard.front)
            }
        }
    }

    // MARK: - Data Management

    func loadCard(card: Card) {
        // 1. Set the front and back text to the card's front and back text. For a 1-sided card, the back text is removed instead.
        front = card.front
        if card.is2Sided! {
            back = card.back
        } else {
            backFocused = false
            isFlipped = false
            back.removeAll()
        }
        // 2. If the option to speak card text on selection or flip is enabled, speak the newly-selected card's front side.
        if speechManager.speakOnSelectionOrFlip {
            speechManager.speak(text: front)
        }
        // 3. Set focus to the front side.
        frontFocused = true
        backFocused = false
    }

    func saveCard(card: Card) {
        // 1. If the card was modified, update the modified date.
        if front != card.front || back != card.back {
            card.modifiedDate = Date()
        }
        // 2. If the title matches the front's first line before the front was changed to a new card's front, set the title to the front's first line. If the front is empty, reset the title to "New Card".
        let firstLineOfCardFront = card.front.components(separatedBy: .newlines).first!
        let firstLineOfFront = front.components(separatedBy: .newlines).first!
        if firstLineOfCardFront == card.title || card.title == defaultCardName {
            card.title = front.isEmpty ? defaultCardName : firstLineOfFront
        }
        // 3. Set the card's front and back text.
        card.front = front
        if card.is2Sided! {
            card.back = back
        } else {
            backFocused = false
            isFlipped = false
            card.back.removeAll()
        }
        // 4. Create the list of tags for the card by finding any words that begin with a hashtag (#), and set the card's tags to that list.
        let words = front.components(separatedBy: .whitespacesAndNewlines)
        let tags = words.filter { $0.first == "#" }
        card.tags = tags
        // 5. Stop speech.
        speechManager.speechSynthesizer.stopSpeaking(at: .immediate)
    }

    func selectedCardChanged(oldCard: Card, newCard: Card) {
        // 1. Flip the card to the front side.
        isFlipped = false
        // 2. Save the previously-selected card.
        saveCard(card: oldCard)
        // 3. Stop speech.
        speechManager.speechSynthesizer.stopSpeaking(at: .immediate)
        // 4. Load the newly-selected card.
        if newCard != oldCard {
            loadCard(card: newCard)
        }
    }

}

// MARK: - Preview

#Preview {
    CardView(selectedCard: Card(title: "Preview Card", is2Sided: true))
        .environmentObject(DialogManager())
        .environmentObject(SpeechManager())
}
