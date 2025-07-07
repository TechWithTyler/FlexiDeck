//
//  DeckImportError.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 7/4/25.
//

import Foundation

struct DeckImportError: LocalizedError {

    var errorDescription: String?

    init(_ error: Error) {
        let nsError = error as NSError
        self.errorDescription = nsError.localizedDescription
    }

}
