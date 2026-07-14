//
//  CardSettingsView.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 8/2/24.
//  Copyright © 2024-2026 SheftApps. All rights reserved.
//

// MARK: - Imports

import SwiftUI
import SwiftData
import SheftAppsStylishUI
import FoundationModels

struct CardSettingsView: View {

    // MARK: - Properties - Decks and Cards

    var card: Card

    @Query var decks: [Deck] = []

    @State var selectedDeck: Deck

    // MARK: - Properties - Strings

    @State var newName: String = String()

    @State private var suggestedTitle: String?

    // MARK: - Properties - Booleans

    @State var is2Sided: Bool = true

    @FocusState var editingName: Bool

    // MARK: - Properties - Dismiss Action

    @Environment(\.dismiss) var dismiss

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                FormTextField("Title", text: $newName)
                    .focused($editingName, equals: true)
                let firstLineOfFront = card.front.components(separatedBy: .newlines).first!
                if let suggestedTitle,
                   (newName == defaultCardName || newName.isEmpty),
                   !suggestedTitle.isEmpty {
                    HStack {
                        Text("Suggested Title")
                        Spacer()
                        Text(suggestedTitle)
                    }
                    Button("Use Suggested Title") {
                        newName = suggestedTitle
                    }
                } else if newName == firstLineOfFront && !firstLineOfFront.isEmpty {
                    InfoText("The first line of this card's front side will be used as its title.")
                }
                Picker("Type", selection: $is2Sided) {
                    Text("1-Sided").tag(false)
                    Text("2-Sided").tag(true)
                }
                if !is2Sided && (card.is2Sided)! && !card.back.isEmpty {
                    WarningText("Changing to a 1-sided card will remove its back side!", prefix: .warning)
                }
                Picker("Deck", selection: $selectedDeck) {
                    ForEach(decks) { deck in
                        if deck.name == card.deck?.name {
                            Text("\(deck.name!) (current)").tag(deck)
                        } else {
                            Text(deck.name!).tag(deck)
                        }
                    }
                }
                if card.deck != selectedDeck {
                    InfoText("This card will be moved from \"\((card.deck?.name)!)\" to \"\((selectedDeck.name)!)\" when saving settings.")
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Card Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveNewSettings()
                        dismiss()
                    }
                    .disabled(newName.isEmpty)
                }
            }
        }
#if !os(macOS)
        .pickerStyle(.navigationLink)
#endif
        .onAppear {
            applyCurrentSettings()
            Task {
                suggestedTitle = await generateSuggestedTitle()
            }
        }
    }

    // MARK: - Reflect Current Settings

    func applyCurrentSettings() {
        newName = card.title ?? String()
        is2Sided = card.is2Sided ?? true
        editingName = true
    }

    // MARK: - Generate Suggested Title

    // This method generates a suggested title for the card.
    func generateSuggestedTitle() async -> String? {
        // 1. If on OS 26 or later, try to use FoundationModels to generate a suggested title.
        if #available(anyAppleOS 26, *) {
            do {
                let title = try await generateSuggestedTitleWithFoundationModels()
                return title
            } catch {
                // 2. If an error occurs or Apple Intelligence isn't enabled/supported, fallback to using the front side's first line as the title.
                let titleFallback = getSuggestedTitleFromCardFront()
                return titleFallback
            }
        } else {
            // 3. Fallback on older OS versions.
            let titleFallback = getSuggestedTitleFromCardFront()
            return titleFallback
        }
    }

    // This method tries to use the FoundationModels framework to generate a suggested title.
    @available(anyAppleOS 26, *)
    func generateSuggestedTitleWithFoundationModels() async throws -> String? {
        // 1. Create a language model session, telling it that it's a flashcard title generator.
        let instructions = "You are a flashcard title generator."
        let session = LanguageModelSession(instructions: instructions)
        // 2. Define the prompt and its requirements.
        let prompt = "Generate a concise title for this flashcard."
        let requirements = [
            "2–5 words",
            "No Markdown",
            "No quotes",
            "No punctuation unless required by the title",
            "Return only the title as plain text."
        ]
        // 3. Format the requirements by adding a bullet to each one. Join the requirements together as a single String.
        let formattedRequirements = requirements
            .map { "• \($0)" }
            .joined(separator: "\n")
        let fullPrompt = """
        \(prompt)
        Requirements:
        \(formattedRequirements)
        Front:
        \(card.front)
        Back:
        \(card.back)
        """
        // 3. Respond to the prompt.
        let response = try await session.respond(to: fullPrompt)
        // 4. Return the suggested title.
        return response.content.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // This method returns the first line of the card's front side as its title.
    func getSuggestedTitleFromCardFront() -> String? {
        // 1. Get all lines of the card's front side.
        let linesOfFront = card.front.components(separatedBy: .newlines)
        // 2. Return the first line.
        let firstLine = linesOfFront.first
        return firstLine
    }

    // MARK: - Save New Settings

    func saveNewSettings() {
        // 1. Save the new settings.
        card.title = newName
        card.is2Sided = is2Sided
        // 2. If going from a 2-sided card to a 1-sided card and the back side has text on it, clear the back side.
        if !(card.is2Sided)! && !card.back.isEmpty {
            card.back.removeAll()
        }
        // 3. If the card isn't in the selected deck, move it to that deck by first removing it from its current deck, then adding it to the selected deck.
        if card.deck != selectedDeck {
            card.deck?.cards?.remove(at: (card.deck?.cards?.firstIndex(of: card)!)!)
            selectedDeck.cards?.append(card)
        }
        // 4. Update the card's modified date.
        card.modifiedDate = Date()
    }

}

// MARK: - Preview

#Preview {
    let deck = Deck(name: "Deck", newCardsAre2Sided: true)
    let card = Card(title: "Card", is2Sided: true)
    deck.cards?.append(card)
    card.deck = deck
    return CardSettingsView(card: card, selectedDeck: deck)
        .modelContainer(for: [Deck.self, Card.self], inMemory: true)
}
