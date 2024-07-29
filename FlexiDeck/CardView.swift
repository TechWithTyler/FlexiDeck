//
//  CardView.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 7/29/24.
//  Copyright © 2024 SheftApps. All rights reserved.
//

import SwiftUI
import SheftAppsStylishUI

struct CardView: View {

    @Bindable var card: Card

    @State var isFlipped: Bool = false

    @AppStorage("cardTextSize") var cardTextSize: Double = 14

    var body: some View {
        #if os(macOS)
        SAMVisualEffectViewSwiftUIRepresentable {
            cardContent
        }
        #else
        cardContent
        #endif
    }

    @ViewBuilder
    var cardContent: some View {
        TextEditor(text: isFlipped ? $card.back : $card.front)
            .font(.system(size: CGFloat(cardTextSize)))
            .padding()
            .navigationTitle("\(card.title) - \(isFlipped ? "Back" : "Front")")
            .toolbar {
                ToolbarItemGroup {
                        Button("Decrease Text Size", systemImage: "textformat.size.smaller") {
                            cardTextSize -= 1
                        }
                        Button("Increase Text Size", systemImage: "textformat.size.larger") {
                            cardTextSize += 1
                        }
                }
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
