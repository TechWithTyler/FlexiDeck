//
//  CardView.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 7/29/24.
//  Copyright © 2024 SheftApps. All rights reserved.
//

import SwiftUI
import SheftAppsStylishUI
import RichTextKit

struct CardView: View {

    // MARK: - Properties - Card

    @Bindable var card: Card

    // MARK: - Properties - Doubles

    @AppStorage(UserDefaults.KeyNames.cardTextSize) var cardTextSize: Double = SATextViewMinFontSize

    // MARK: - Properties - Booleans

    @State var isFlipped: Bool = false

    @State var front: NSAttributedString = NSMutableAttributedString(string: String())

    @State var back: NSAttributedString = NSMutableAttributedString(string: String())

    // MARK: - Properties - Dialog Manager

    @EnvironmentObject var dialogManager: DialogManager

    // MARK: - Body

    var body: some View {
        RichTextEditor(text: isFlipped ? $back : $front, context: RichTextContext())
            .font(.system(size: CGFloat(cardTextSize)))
            .navigationTitle((card.is2Sided)! ? "\(card.title ?? String()) - \(isFlipped ? "Back" : "Front")" : card.title ?? String())
            .padding()
            .onAppear {
                loadCard()
            }
            .onChange(of: card) { oldValue, newValue in
                loadCard()
            }
            .onDisappear {
                saveCard()
            }
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
                        if (card.is2Sided)! {
                            Button(isFlipped ? "Flip to Front" : "Flip to Back", systemImage: "arrow.trianglehead.left.and.right.righttriangle.left.righttriangle.right") {
                                isFlipped.toggle()
                            }
                        }
                        Button("Settings…", systemImage: "gear") {
                            dialogManager.cardToShowSettings = card
                        }
                        Divider()
                        Button(role: .destructive) {
                            dialogManager.cardToDelete = card
                            dialogManager.showingDeleteCard = true
                        } label: {
                            Label("Delete…", systemImage: "trash")
                        }
                    }
                }
            }
    }

    func loadCard() {
        front = StringDataConverter.convertDataToAttributedString(card.encodedFront) ?? NSAttributedString()
        back = StringDataConverter.convertDataToAttributedString(card.encodedBack) ?? NSAttributedString()
    }

    func saveCard() {
        let front = StringDataConverter.convertAttributedStringToArchivedData(front)
        let back = StringDataConverter.convertAttributedStringToArchivedData(back)
        card.encodedFront = front!
        card.encodedBack = back!
    }

}

// MARK: - Preview

#Preview {
    CardView(card: Card(title: "Preview Card", is2Sided: true))
        .environmentObject(DialogManager())
}
