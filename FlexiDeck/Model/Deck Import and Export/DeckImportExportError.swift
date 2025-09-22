//
//  DeckImportExportError.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 7/4/25.
//

import Foundation

enum DeckImportExportError: LocalizedError {

    case fileWrapperError(Deck?)

    case urlResultFailure(NSError)

    case exportError(Deck, NSError)

    case importError(URL, NSError)

    case securityScopedResourceAccessError(URL)

    var errorDescription: String? {
        switch self {
        case .fileWrapperError(let deck):
            return "The deck \"\((deck?.name)!)\" couldn't be wrapped up to prepare for export."
            case .urlResultFailure(let error):
            return "The URL result was nil or invalid: \(error.localizedDescription)"
            case .exportError(let deck, let error):
            return "The deck \"\(deck.name!)\" couldn't be exported: \(error.localizedDescription)"
            case .importError(let url, let error):
            return "The deck at \(url.path) couldn't be imported: \(error.localizedDescription)"
        case .securityScopedResourceAccessError(let url):
            return "The deck at \(url.path) couldn't be imported because the security scoped resource access failed. Please ensure you have permission to access this resource."
        }
    }

}
