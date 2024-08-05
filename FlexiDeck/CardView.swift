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
        TextEditor(text: isFlipped ? $card.back : $card.front)
            .font(.system(size: CGFloat(cardTextSize)))
            .navigationTitle(card.is2Sided ? "\(card.title) - \(isFlipped ? "Back" : "Front")" : card.title)
            .toolbar {
                ToolbarItemGroup {
                        Button("Decrease Text Size", systemImage: "textformat.size.smaller") {
                            cardTextSize -= 1
                        }
                        Button("Increase Text Size", systemImage: "textformat.size.larger") {
                            cardTextSize += 1
                        }
                }
                if card.is2Sided {
                    ToolbarItem {
                        Button("Flip", systemImage: "arrow.trianglehead.left.and.right.righttriangle.left.righttriangle.right") {
                            isFlipped.toggle()
                        }
                    }
                }
            }
    }

}

#Preview {
    CardView(card: Card(title: "Preview Card", is2Sided: true))
}
