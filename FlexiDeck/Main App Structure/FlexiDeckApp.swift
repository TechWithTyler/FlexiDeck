//
//  FlexiDeckApp.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 7/26/24.
//  Copyright © 2024-2025 SheftApps. All rights reserved.
//

import SwiftUI
import SwiftData
import SheftAppsStylishUI

@main
struct FlexiDeckApp: App {

    // MARK: - Properties - macOS App Delegate Adaptor

    #if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif

    // MARK: - Properties - Objects

    // Handles the display of dialogs in the app.
    @ObservedObject var dialogManager = DialogManager()

    // Handles speech in the app.
    @ObservedObject var speechManager = SpeechManager()

    // MARK: - Properties - Model Container

    // Returns the shared model container for the application.
    var sharedModelContainer: ModelContainer = {
        // 1. Create a schema to define the app's data model.
        let schema = Schema([
            Deck.self,
            Card.self
        ])
        // 2. Create a ModelConfiguration with the schema.
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false, allowsSave: true, cloudKitDatabase: .automatic)
        do {
            // 3. Try to create a model container with the schema and model configuration.
            let modelContainer = try ModelContainer(for: schema, migrationPlan: FlexiDeckMigrationPlan.self, configurations: [modelConfiguration])
            return modelContainer
        } catch {
            // 4. If a model container can't be created, throw a fatal error.
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    // MARK: - Windows and Views

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dialogManager)
                .environmentObject(speechManager)
                .ignoresSafeArea(edges: .all)
        }
        .modelContainer(sharedModelContainer)
        .commands {
            FlexiDeckCommands()
        }
        #if os(macOS)
        Settings {
                SettingsView()
                    .environmentObject(dialogManager)
                    .environmentObject(speechManager)
        }
        #endif
    }
    
}
