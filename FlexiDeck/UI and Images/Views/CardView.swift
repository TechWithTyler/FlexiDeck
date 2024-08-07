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

    @EnvironmentObject var dialogManager: DialogManager

    @AppStorage("cardTextSize") var cardTextSize: Double = SATextViewMinFontSize

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
                    ToolbarItem {
                        OptionsMenu(title: .menu) {
                            if card.is2Sided {
                            Button("Flip", systemImage: "arrow.trianglehead.left.and.right.righttriangle.left.righttriangle.right") {
                                isFlipped.toggle()
                            }
                            }
                            Button("Settings…", systemImage: "gear") {
                                dialogManager.cardToRename = card
                            }
                    }
                }
            }
    }

}

#Preview {
    CardView(card: Card(title: "Preview Card", is2Sided: true))
}
