//
//  CardListDetailOptions.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 12/12/24.
//  Copyright © 2024-2026 SheftApps. All rights reserved.
//

// MARK: - Imports

import SwiftUI

struct CardListDetailOptions: View {

    // MARK: - Properties - Booleans

    @AppStorage(UserDefaults.KeyNames.showNumberOfSides) var showNumberOfSides: Bool = false

    @AppStorage(UserDefaults.KeyNames.cardDateTimeDisplay) var cardDateTimeDisplay: Bool = false

    // MARK: - Body

    var body: some View {
        Picker("Date/Time", selection: $cardDateTimeDisplay) {
            Text("Date Only").tag(false)
            Text("Date and Time").tag(true)
        }
        Toggle("Show Number of Sides", isOn: $showNumberOfSides)
    }

}

// MARK: - Preview

#Preview {
    CardListDetailOptions()
}
