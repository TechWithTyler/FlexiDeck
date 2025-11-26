//
//  FlexiDeckDeck.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 7/8/25.
//

// MARK: - Imports

import Foundation
import UniformTypeIdentifiers

extension UTType {

    // MARK: - Properties Uniform Types

    static var flexiDeckDeck: UTType {
        let typeName = "com.tylersheft.FlexiDeckDeck"
        return UTType(importedAs: typeName)
    }

}
