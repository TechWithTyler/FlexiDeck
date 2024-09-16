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
    
    @Bindable var card: Card

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
            Toggle(isOn: $card.isCompleted) {
                Text("Completed")
            }
            .toggleStyle(CircleCheckboxToggleStyle())
            .padding(.trailing, 5)
            VStack(alignment: .leading) {
                Text(cardWithColoredMatchingTerms(card.title ?? String(), searchText: searchText))
                Text(DateFormatter.localizedString(from: card.modifiedDate, dateStyle: .short, timeStyle: .short))
                    .foregroundStyle(.secondary)
                StarRatingView(card: card)
                if !card.tags.isEmpty {
                    Text(tagDisplay)
                        .foregroundStyle(.tint)
                }
            }
            Spacer()
            if let cardIs2Sided = card.is2Sided {
                Text(cardIs2Sided ? "2-sided" : "1-sided")
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityAction(named: "Mark \(card.isCompleted ? "Not Completed" : "Completed")") {
            card.isCompleted.toggle()
        }
        .accessibilityAction(named: "Clear Star Rating") {
            card.starRating = 0
        }
        .accessibilityAction(named: "Rate 1 Star") {
            card.starRating = 1
        }
        .accessibilityAction(named: "Rate 2 Stars") {
            card.starRating = 2
        }
        .accessibilityAction(named: "Rate 3 Stars") {
            card.starRating = 3
        }
        .accessibilityAction(named: "Rate 4 Stars") {
            card.starRating = 4
        }
        .accessibilityAction(named: "Rate 5 Stars") {
            card.starRating = 5
        }
        .accessibilityLabel("\(card.title!), \(card.starRating)-star rating, \(card.tags.isEmpty ? "no tags" : tagDisplay), \(card.is2Sided! ? "2-sided" : "1-sided"), \(card.isCompleted ? "completed" : "not completed")")
        .accessibilityHint("Select an action to change completed status or star rating.")
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
