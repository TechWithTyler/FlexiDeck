//
//  SettingsView.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 8/6/24.
//  Copyright © 2024-2026 SheftApps. All rights reserved.
//

// MARK: - Imports

import SwiftUI
import SheftAppsStylishUI

struct SettingsView: View {

    // MARK: - Properties - Objects

    @ObservedObject var dialogManager = DialogManager()

    @ObservedObject var speechManager = SpeechManager()

    // MARK: - Properties - Dismiss Action

#if !os(macOS)
    @Environment(\.dismiss) var dismiss
#endif

    // MARK: - Body

    var body: some View {
#if os(macOS)
        // macOS settings window
            TabView(selection: $dialogManager.selectedSettingsPage) {
                SAMVisualEffectViewSwiftUIRepresentable(activeState: .active) {
                    DisplaySettingsPageView()
                }
                .frame(width: 400, height: 360)
                .formStyle(.grouped)
                .tabItem {
                    Label(SettingsPage.display.title, systemImage: SettingsPage.Icons.display.rawValue)
                }
                .tag(SettingsPage.display)
                SAMVisualEffectViewSwiftUIRepresentable(activeState: .active) {
                    SpeechSettingsPageView()
                }
                .frame(width: 400, height: 220)
                .formStyle(.grouped)
                .tabItem {
                    Label(SettingsPage.speech.title, systemImage: SettingsPage.Icons.speech.rawValue)
                }
                .tag(SettingsPage.speech)
                SAMVisualEffectViewSwiftUIRepresentable(activeState: .active) {
                    DecksCardsSettingsPageView()
                }
                .frame(width: 400, height: 375)
                .formStyle(.grouped)
                .tabItem {
                    Label(SettingsPage.decksCards.title, systemImage: SettingsPage.Icons.decksCards.rawValue)
                }
                .tag(SettingsPage.decksCards)
            }
        .toggleStyle(.stateLabelCheckbox(stateLabelPair: .yesNo))
        .environmentObject(speechManager)
#else
        // iOS/visionOS settings page
        NavigationStack {
            Form {
                Section {
                    NavigationLink {
                        DisplaySettingsPageView()
                            .navigationTitle(SettingsPage.display.title)
                    } label: {
                        Label(SettingsPage.display.title, systemImage: SettingsPage.Icons.display.rawValue)
                    }
                    NavigationLink {
                        SpeechSettingsPageView()
                            .navigationTitle(SettingsPage.speech.title)
                    } label: {
                        Label(SettingsPage.speech.title, systemImage: SettingsPage.Icons.speech.rawValue)
                    }
                    NavigationLink {
                        DecksCardsSettingsPageView()
                            .navigationTitle(SettingsPage.decksCards.title)
                    } label: {
                        Label(SettingsPage.decksCards.title, systemImage: SettingsPage.Icons.decksCards.rawValue)
                    }
                }
#if !os(macOS)
                Section {
                    Button("Help…", systemImage: "questionmark.circle") {
                        showHelp()
                    }
                }
#endif
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.automatic)
            .formStyle(.grouped)
            .toolbar {
                ToolbarItem {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .pickerStyle(.navigationLink)
        .toggleStyle(.stateLabelCheckbox(stateLabelPair: .yesNo))
        .environmentObject(speechManager)
#endif
    }

}

// MARK: - Preview

#Preview {
    SettingsView()
        .environmentObject(DialogManager())
        .environmentObject(SpeechManager())
}
