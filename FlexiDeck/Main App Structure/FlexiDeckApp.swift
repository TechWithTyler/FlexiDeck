//
//  FlexiDeckApp.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 7/26/24.
//  Copyright © 2024-2025 SheftApps. All rights reserved.
//

// MARK: - Imports

import SwiftUI
import SwiftData
import SheftAppsStylishUI

@main
struct FlexiDeckApp: App {

    // MARK: - Properties - macOS App Delegate Adaptor

    #if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif

    // MARK: - Properties - Model Container

    // Returns the shared model container for the application. This code uses a file named "default" with extension "store" in the user's Application Support directory.
    var sharedModelContainer: ModelContainer = {
        // 1. Create a schema to define the app's data model.
        let schema = Schema([
            Deck.self,
            Card.self
        ])
        // 2. Set the URL for the store.
        let storeFilename: String = "default"
        let storeFileExtension: String = "store"
        let storeManager: FileManager = .default
        let domain: FileManager.SearchPathDomainMask = .userDomainMask
        let location: FileManager.SearchPathDirectory = .applicationSupportDirectory
        // The URLs for the given location in the given domain.
        let URLs = storeManager.urls(for: location, in: domain)
        // Gets the last URL from the URLs array and adds a new file to it.
        let appSupportURL: URL = URLs.last!
        // Creates a URL with name "default.store"
        // Here, a file or directory is inserted into the specified location in the specified domain.
        // Like with arrays, to append something means "to add."
        let fileURL: URL = appSupportURL.appending(path: storeFilename, directoryHint: .notDirectory)
        // Appends ".store" to the URL. This is the full URL.
        let file: URL = fileURL.appendingPathExtension(storeFileExtension)
        // 3. Create a ModelConfiguration with the schema.
        let modelConfiguration = ModelConfiguration(schema: schema, url: file, allowsSave: true, cloudKitDatabase: .automatic)
        do {
            // 4. Try to create a model container with the schema and model configuration.
            let modelContainer = try ModelContainer(for: schema, migrationPlan: FlexiDeckMigrationPlan.self, configurations: [modelConfiguration])
            return modelContainer
        } catch {
            // 5. If a model container can't be created, throw a fatal error.
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    // MARK: - Windows and Views

    var body: some Scene {
        WindowGroup {
            ContentView()
                .ignoresSafeArea(edges: .all)
        }
        .modelContainer(sharedModelContainer)
        .commands {
            FlexiDeckCommands()
        }
        #if os(macOS)
        Settings {
            SettingsView()
        }
        #endif
    }
    
}
