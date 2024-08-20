//
//  StringDataConverter.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 8/20/24.
//  Copyright © 2024 SheftApps. All rights reserved.
//


import Foundation

struct StringDataConverter {

    static func convertAttributedStringToArchivedData(_ attributedString: NSAttributedString) -> Data? {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: attributedString, requiringSecureCoding: false)
            return data
        } catch {
            print("Failed to archive NSAttributedString: \(error)")
            return nil
        }
    }
    
    static func convertDataToAttributedString(_ data: Data?) -> NSAttributedString? {
        if let encodedText = data {
            return try? NSAttributedString(data: encodedText, format: .archivedData)
        }
        return nil
    }
}
