//
//  FlexiDeckApp.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 7/26/24.
//  Copyright © 2024 SheftApps. All rights reserved.
//

import SwiftUI
import SwiftData

@main
struct FlexiDeckApp: App {

    @AppStorage("cardTextSize") var cardTextSize: Double = 14

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Deck.self,
            Card.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
        WindowGroup(id: "CardView", for: Card.ID.self) { $cardID in
            if let cardID = cardID, let card = sharedModelContainer.mainContext.model(for: cardID) as? Card {
                CardView(card: card)
            }
        }
        .modelContainer(sharedModelContainer)
        .commands {
            CommandMenu("Format") {
                Button("Decrease Text Size", systemImage: "textformat.size.smaller") {
                    cardTextSize -= 1
                }
                .keyboardShortcut("-", modifiers: .command)
                Button("Increase Text Size", systemImage: "textformat.size.larger") {
                    cardTextSize += 1
                }
                .keyboardShortcut("+", modifiers: .command)
            }
        }
    }
}
