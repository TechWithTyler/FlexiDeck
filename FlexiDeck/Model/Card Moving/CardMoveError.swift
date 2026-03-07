//
//  CardMoveError.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 3/6/26.
//  Copyright © 2024-2026 SheftApps. All rights reserved.
//

import Foundation

enum CardMoveError: LocalizedError {

    // MARK: - Error Cases

    case unknown(Error)

    case noData

    case sourceDeckNotFound

    case cardNotFoundInSourceDeck

    // MARK: - Error Description

    var errorDescription: String? {
        switch self {
        case .noData:
            return "Card to move has no data or the dropped item wasn't a card."
        case .sourceDeckNotFound:
            return "Source deck not found."
        case .cardNotFoundInSourceDeck:
            return "Card to move wasn't found in the source deck."
        case .unknown(let error):
            return "Card move failed: \(error.localizedDescription)"
        }
    }

}
