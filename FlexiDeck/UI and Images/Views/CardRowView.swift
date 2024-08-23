//
//  CardRowView.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 8/8/24.
//  Copyright © 2024 SheftApps. All rights reserved.
//

import SwiftUI

struct CardRowView: View {
    
    // MARK: - Properties - Card
    
    var card: Card
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(card.title ?? String())
            if let cardIs2Sided = card.is2Sided {
                Text(cardIs2Sided ? "2-sided" : "1-sided")
                    .foregroundStyle(.secondary)
            }
        }
        
    }
}

// MARK: - Preview

#Preview {
    CardRowView(card: Card(title: "Card", is2Sided: true))
}