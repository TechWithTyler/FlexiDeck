//
//  CardMoveManager.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 3/6/26.
//  Copyright © 2024-2026 SheftApps. All rights reserved.
//

// MARK: - Imports

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

class CardMoveManager: ObservableObject {

    // MARK: - Properties - Booleans

    // Whether a draggable item (e.g. a card) is being hovered over the deck list.
    @Published var hoveringItemOverDeck: Bool = false

    // Whether an error should be/is being displayed.
    @Published var showingErrorAlert: Bool = false

    // MARK: - Properties - Errors

    @Published var moveError: CardMoveError? = nil

    // MARK: - Drag and Drop

    // This method handles dragging of a card.
    func handleDrag(of card: Card) -> NSItemProvider {
        // 1. Create an NSItemProvier.
        let provider = NSItemProvider()
        let cardID = card.id
        // 2. Try to create data from the card's ID. The card ID is used to determine which card is to be moved.
        provider.registerDataRepresentation(forTypeIdentifier: UTType.text.identifier, visibility: .all) { [self] completion in
            if let data = encodeCardID(cardID) {
                completion(data, nil)
            } else {
                // 3. If there's no data, show an error.
                moveError = .noData
                showingErrorAlert = true
                completion(nil, nil)
            }
            return nil
        }
        // 4. Return the provider.
        return provider
    }

    // This method handles dropping of a card on destinationDeck and uses the given Deck array to find the source deck.
    func handleDrop(with providers: [NSItemProvider], toMoveToDestinationDeck destinationDeck: Deck, findingSourceDeckIn decks: [Deck]) -> Bool {
        // 1. Make sure the first item provider contains text (the JSON data from the card's ID), but not a deck.
        guard let provider = providers.first(where: {
            let hasCard = $0.hasItemConformingToTypeIdentifier(UTType.text.identifier)
            let hasDeck = $0.hasItemConformingToTypeIdentifier(UTType.flexiDeckDeck.identifier)
            return hasCard && !hasDeck
        }) else { return false }
        // 2. Try to move the card to the destination deck.
        provider.loadDataRepresentation(forTypeIdentifier: UTType.text.identifier) { [self] data, error in
            moveCardWithData(data, toDestinationDeck: destinationDeck, findingSourceDeckIn: decks, error: error)
        }
        // 3. Return whether the drop was successful.
        return !showingErrorAlert
    }

    // MARK: - Move Card

    func moveCardWithData(_ data: Data?, toDestinationDeck destinationDeck: Deck, findingSourceDeckIn decks: [Deck], error: Error?) {
        // 1. If an error occurs, show it.
        if let error = error {
            DispatchQueue.main.async { [self] in
                moveError = .unknown(error)
                showingErrorAlert = true
            }
        } else if let data = data {
            // 2. If there's data, make sure we can get the ID from that data.
            guard let id = decodeCardID(data) else {
                DispatchQueue.main.async { [self] in
                    moveError = .noData
                    showingErrorAlert = true
                }
                return }
            // 3. Make sure we can get the source deck, which contains the card to move. If the source deck can't be found, show an error.
            guard let sourceDeck = deck(containingCardWithID: id, in: decks) else {
                DispatchQueue.main.async { [self] in
                    moveError = .sourceDeckNotFound
                    showingErrorAlert = true
                }
                return }
            // 4. Make sure we can get the card to be moved from the source deck. If not, show an error.
            guard let cardToMove = card(withID: id, in: sourceDeck) else {
                DispatchQueue.main.async { [self] in
                    moveError = .cardNotFoundInSourceDeck
                    showingErrorAlert = true
                }
                return }
            // 5. If the card to be moved is already in the deck to move it to, return.
            if cardToMove.deck == destinationDeck { return }
            DispatchQueue.main.async {
                // 6. Remove the card from the source deck.
                if let index = sourceDeck.cards?.firstIndex(of: cardToMove) {
                    sourceDeck.cards?.remove(at: index)
                }
                // 7. Move the card to the new deck.
                destinationDeck.cards?.append(cardToMove)
                cardToMove.deck = destinationDeck
            }
        } else {
            // 8. If there's no data, show an error.
            DispatchQueue.main.async { [self] in
                moveError = .noData
                showingErrorAlert = true
            }
        }
    }

    // MARK: - Deck/Card Retrieval

    // This method finds a deck containing a card with the given ID.
    func deck(containingCardWithID id: PersistentIdentifier, in decks: [Deck]) -> Deck? {
        return decks.first { deckContainsCard(withID: id, in: $0) }
    }

    // This method returns whether deck contains a card with the given ID.
    func deckContainsCard(withID id: PersistentIdentifier, in deck: Deck) -> Bool {
        guard let cards = deck.cards else { return false }
        return cards.contains { $0.id == id }
    }

    // This method finds a card with the given ID in deck.
    func card(withID id: PersistentIdentifier, in deck: Deck) -> Card? {
        return deck.cards?.first { $0.id == id }
    }

    // MARK: - Card ID Encoding/Decoding

    // This method encodes a card's ID to JSON data (PersistentIdentifier > Data) when it's dragged to a new deck.
    func encodeCardID(_ id: PersistentIdentifier) -> Data? {
        // 1. Create a JSON encoder.
        let encoder = JSONEncoder()
        // 2. Try to encode the ID.
        let data = try? encoder.encode(id)
        // 3. Return the encoded data.
        return data
    }

    // This method decodes a card's ID from JSON data (Data > PersistentIdentifier) when it's dropped on a new deck.
    func decodeCardID(_ data: Data) -> PersistentIdentifier? {
        // 1. Create a JSON decoder.
        let decoder = JSONDecoder()
        let typeToDecode = PersistentIdentifier.self
        // 2. Try to decode the ID from the data.
        let id = try? decoder.decode(typeToDecode, from: data)
        return id
    }

}

