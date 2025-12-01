//
//  DeckImportExportError.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 7/4/25.
//  Copyright © 2024-2026 SheftApps. All rights reserved.
//

// MARK: - Imports

import Foundation

enum DeckImportExportError: LocalizedError {

    // MARK: - Error Cases

    // Error with wrapping up a deck's data into an exportable file
    case fileWrapperError

    // Imported file URL result failed
    case fileImportURLResultFailure(NSError)

    // Export error.
    case exportError(Deck, NSError)

    // Import error
    case importError(URL, NSError)

    // Security-scoped resource access error
    case securityScopedResourceAccessError(URL)

    // MARK: - Error Description

    var errorDescription: String? {
        switch self {
        case .fileWrapperError:
            return "Deck couldn't be wrapped up into an exportable file."
            case .fileImportURLResultFailure(let error):
            return "The file import URL result was nil or invalid: \(error.localizedDescription)"
            case .exportError(let deck, let error):
            return "The deck \"\(deck.name!)\" couldn't be exported: \(error.localizedDescription)"
            case .importError(let fileURL, let error):
            return "The deck at \(fileURL.path) couldn't be imported: \(error.localizedDescription)"
        case .securityScopedResourceAccessError(let fileURL):
            return "The deck at \(fileURL.path) couldn't be imported because the security-scoped resource access failed. Please ensure you have permission to access this resource."
        }
    }

}
