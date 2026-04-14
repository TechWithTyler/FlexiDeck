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
    case fileWrapperError(String)

    // Export error.
    case exportError(String, Error)

    // Export preparation error.
    case exportPrepError(String, Error)

    // Import error (URL, resolved).
    case importErrorURL(URL, Error)

    // Import error (URL, can't resolve)
    case importErrorNoURL(Error)

    // Import error (drop).
    case importErrorDrop(Error)

    // Dropped deck had no data.
    case noDeckDataDrop

    // Security-scoped resource access error
    case securityScopedResourceAccessError(URL)

    // MARK: - Error Description

    var errorDescription: String? {
        switch self {
        case .fileWrapperError(let deckName):
            return "The deck \"\(deckName)\" couldn't be wrapped up into an exportable file."
        case .exportPrepError(let deckName, let error):
            return "The deck \"\(deckName)\" couldn't be prepared for export: \(error.localizedDescription)"
        case .exportError(let deckName, let error):
            return "The deck \"\(deckName)\" couldn't be exported: \(error.localizedDescription)"
        case .importErrorURL(let fileURL, let error):
            return "The deck at \(fileURL.path) couldn't be imported: \(error.localizedDescription)"
        case .importErrorNoURL(let error):
            return "Couldn't resolve file URL for deck import: \(error.localizedDescription)"
        case .importErrorDrop(let error):
            return "One or more dropped deck(s) couldn't be imported: \(error.localizedDescription)"
        case .noDeckDataDrop:
            return "One or more dropped decks have no data."
        case .securityScopedResourceAccessError(let fileURL):
            return "The deck at \(fileURL.path) couldn't be imported because the security-scoped resource access failed. Please ensure you have permission to access this resource."
        }
    }

}
