//
//  DupeRemover.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 9/12/24.
//  Copyright © 2024-2025 SheftApps. All rights reserved.
//

import Foundation

extension Array where Element : Equatable {

    // Swift heavily uses structs for data types. Array is one of them, so we need to use the mutating keyword to mark this method mutating as it modifies Array.
    mutating func removeDuplicates() {
        let emptyArray: [Element] = []
        let reducedArray = reduce(into: emptyArray) { (result: inout [Element], element: Element) in
            // Appends element to the reduced array only once, thus removing duplicates of element.
            if !result.contains(element) {
                result.append(element)
            }
        }
        self = reducedArray
    }

}

