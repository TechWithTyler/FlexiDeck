//
//  AppDelegate.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 10/10/24.
//  Copyright © 2024-2025 SheftApps. All rights reserved.
//

#if os(macOS)

// MARK: - Imports

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {

    // MARK: - macOS App Delegate - Quit When Last Window Closed

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

}
#endif

