//
//  CircleCheckboxToggleStyle.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 9/13/24.
//

import SwiftUI

struct CircleCheckboxToggleStyle: ToggleStyle {

    func makeBody(configuration: Configuration) -> some View {
        Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
            .onTapGesture {
                withAnimation {
                    configuration.isOn.toggle()
                }
            }
            .foregroundStyle(configuration.isOn ? Color.accentColor : Color.primary)
    }

}
