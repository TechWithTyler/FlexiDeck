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

    // MARK: - Properties - Strings

    var searchText: String

    var tagDisplay: String {
        // 1. Create a String from the card's tags array, separating each one with a space.
        let tags = card.tags.joined(separator: " ")
        // 2. Return the tag string.
        return tags
    }

    // MARK: - Body
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(cardWithColoredMatchingTerms(card.title ?? String(), searchText: searchText))
                Text(DateFormatter.localizedString(from: card.creationDate, dateStyle: .short, timeStyle: .short))
                    .foregroundStyle(.secondary)
                Text(tagDisplay)
                    .foregroundStyle(.tint)
            }
            Spacer()
            if let cardIs2Sided = card.is2Sided {
                Text(cardIs2Sided ? "2-sided" : "1-sided")
                    .foregroundStyle(.secondary)
            }
        }
        
    }

    // MARK: - Color Matching Terms

    func cardWithColoredMatchingTerms(_ title: String, searchText: String) -> AttributedString {
        // 1. Convert the card title String to an AttributedString. As AttributedString is a data type, it's declared in the Foundation framework instead of the SwiftUI framework, even though its cross-platform design makes it shine with SwiftUI. Unlike with NSAttributedString, you can simply initialize it with a String argument without having to use an argument label.
        var attributedString = AttributedString(title)
        // 2. Check to see if the fact text contains the entered search text, case insensitive. If so, change the color of the matching part.
        if let range = attributedString.range(of: searchText, options: .caseInsensitive) {
            attributedString[range].backgroundColor = .accentColor
        }
        // 3. Return the attributed string.
        return attributedString
    }

}

// MARK: - Preview

#Preview {
    CardRowView(card: Card(title: "Card", is2Sided: true), searchText: String())
}
