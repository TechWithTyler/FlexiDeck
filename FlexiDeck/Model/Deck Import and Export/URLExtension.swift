//
//  URLExtension.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 3/3/26.
//  Copyright © 2026 SheftApps. All rights reserved.
//

import Foundation

extension URL {

    // Returns the last path component without its extension (if any) and removes percent encoding (e.g. %20 for space).
    var lastPathComponentWithoutExtensionOrPercentEncoding: String? {
        return self.deletingPathExtension().lastPathComponent.removingPercentEncoding
    }

}
