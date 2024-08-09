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

    // MARK: - Properties - Card

    @Bindable var card: Card

    // MARK: - Properties - Doubles

    @AppStorage(UserDefaults.KeyNames.cardTextSize) var cardTextSize: Double = SATextViewMinFontSize

    // MARK: - Properties - Booleans

    @State var isFlipped: Bool = false

    // MARK: - Properties - Dialog Manager

    @EnvironmentObject var dialogManager: DialogManager

    // MARK: - Body

    var body: some View {
        TextEditor(text: isFlipped ? $card.back : $card.front)
            .font(.system(size: CGFloat(cardTextSize)))
            .navigationTitle(card.is2Sided ? "\(card.title) - \(isFlipped ? "Back" : "Front")" : card.title)
            .padding()
            .toolbar {
                ToolbarItemGroup {
                    Button {
                        cardTextSize -= 1
                    } label: {
                        Label("Decrease Text Size", systemImage: "textformat.size.smaller")
                            .frame(width: 30)
                    }
                    Button {
                        cardTextSize += 1
                    } label: {
                        Label("Increase Text Size", systemImage: "textformat.size.larger")
                            .frame(width: 30)
                    }
                } label: {
                    Text("Text Size")
                }
                ToolbarItem {
                    Spacer()
                }
                ToolbarItem {
                    OptionsMenu(title: .menu) {
                        if card.is2Sided {
                            Button(isFlipped ? "Flip to Front" : "Flip to Back", systemImage: "arrow.trianglehead.left.and.right.righttriangle.left.righttriangle.right") {
                                isFlipped.toggle()
                            }
                        }
                        Button("Settings…", systemImage: "gear") {
                            dialogManager.cardToShowSettings = card
                        }
                    }
                }
            }
    }

}

// MARK: - Preview

#Preview {
    CardView(card: Card(title: "Preview Card", is2Sided: true))
}
