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

    // MARK: - Properties - Strings

    @State var front: String = String()

    @State var back: String = String()

    // MARK: - Properties - Doubles

    @AppStorage(UserDefaults.KeyNames.cardTextSize) var cardTextSize: Double = SATextViewMinFontSize

    @AppStorage(UserDefaults.KeyNames.speakOnSelectionOrFlip) var speakOnSelectionOrFlip: Bool = false

    // MARK: - Properties - Booleans

    @State var isFlipped: Bool = false

    // MARK: - Properties - Dialog Manager

    @EnvironmentObject var dialogManager: DialogManager

    // MARK: - Body

    var body: some View {
        TranslucentFooterVStack {
            TextEditor(text: isFlipped ? $back : $front)
                .font(.system(size: CGFloat(cardTextSize)))
                .scrollContentBackground(.hidden)
        } translucentFooterContent: {
            Divider()
            Text(DateFormatter.localizedString(from: selectedCard.modifiedDate, dateStyle: .short, timeStyle: .short))
                .foregroundStyle(.secondary)
                StarRatingView(card: selectedCard)
        }
        .navigationTitle((selectedCard.is2Sided)! ? "\(selectedCard.title ?? String()) - \(isFlipped ? "Back" : "Front")" : selectedCard.title ?? String())
                .onAppear {
                    loadCard(card: selectedCard)
                    if speakOnSelectionOrFlip {
                        speechManager.speak(text: front)
                    }
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
                            .keyboardShortcut(.return, modifiers: .command)
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

    // MARK: - Data Management

    func loadCard(card: Card) {
        front = card.front
        back = card.back
    }

    func saveCard(card: Card) {
        // 1. If the card was modified, update the modified date.
        if front != card.front || back != card.back {
            card.modifiedDate = Date()
        }
        // 2. If the title matches the front's first line before the front was changed, set the title to the front's first line. If the front is empty, reset the title to "New Card".
        if card.front.components(separatedBy: .newlines).first! == card.title || card.title == defaultCardName {
            card.title = front.isEmpty ? defaultCardName : front.components(separatedBy: .newlines).first!
        }
        // 3. Set the card's front and back text.
        card.front = front
        card.back = back
        // 4. Create the list of tags for the card by finding any words that begin with a hashtag (#), and set the card's tags to that list.
        let words = front.components(separatedBy: .whitespacesAndNewlines)
        let tags = words.filter { $0.first == "#"}
        card.tags = tags
    }

    func selectedCardChanged(oldCard: Card, newCard: Card) {
        // 1. Flip the card to the front side.
        isFlipped = false
        // 2. Save the previously-selected card.
        saveCard(card: oldCard)
        // 3. Load the newly-selected card.
        loadCard(card: newCard)
        // 4. Stop speech.
        speechManager.speechSynthesizer.stopSpeaking(at: .immediate)
        // 5. If the option to speak card text on selection or flip is enabled, speak the newly-selected card's front side.
        if speakOnSelectionOrFlip {
            speechManager.speak(text: selectedCard.front)
        }
    }

}

// MARK: - Preview

#Preview {
    CardView(selectedCard: Card(title: "Preview Card", is2Sided: true))
        .environmentObject(DialogManager())
        .environmentObject(SpeechManager())
}
