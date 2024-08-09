//
//  FlexiDeckApp.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 7/26/24.
//  Copyright © 2024 SheftApps. All rights reserved.
//

import SwiftUI
import SwiftData
import SheftAppsStylishUI

@main
struct FlexiDeckApp: App {

    // MARK: - Properties - Dialog Manager

    @ObservedObject var dialogManager = DialogManager()

    // MARK: - Properties - Model Container

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Deck.self,
            Card.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    // MARK: - Windows and Views

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dialogManager)
        }
        .modelContainer(sharedModelContainer)
        .commands {
            FlexiDeckCommands()
        }
        #if os(macOS)
        Settings {
            SAMVisualEffectViewSwiftUIRepresentable {
                SettingsView()
            }
            .frame(width: 400, height: 300)
        }
        #endif
    }
}
