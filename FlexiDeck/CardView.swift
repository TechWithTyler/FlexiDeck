//
//  CardView.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 7/29/24.
//  Copyright © 2024 SheftApps. All rights reserved.
//

import SwiftUI

struct CardView: View {

    @Bindable var card: Card

    @State var isFlipped: Bool = false

    var body: some View {
        TextEditor(text: isFlipped ? $card.back : $card.front)
            .padding()
            .navigationTitle("\(card.title) - \(isFlipped ? "Back" : "Front")")
            .toolbar {
                ToolbarItem {
                    Button("Flip", systemImage: "arrow.trianglehead.left.and.right.righttriangle.left.righttriangle.right") {
                        isFlipped.toggle()
                    }
                }
            }
    }

}

#Preview {
    CardView(card: Card(title: "Preview Card"))
}
