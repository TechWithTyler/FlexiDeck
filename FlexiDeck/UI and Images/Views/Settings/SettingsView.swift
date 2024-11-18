//
//  SettingsView.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 8/6/24.
//  Copyright © 2024-2025 SheftApps. All rights reserved.
//

import SwiftUI
import SheftAppsStylishUI

struct SettingsView: View {

    // MARK: - Properties - Dialog Manager

    @EnvironmentObject var dialogManager: DialogManager

    // MARK: - Properties - Dismiss Action

#if !os(macOS)
    @Environment(\.dismiss) var dismiss
#endif

    // MARK: - Body

    var body: some View {
#if os(macOS)
        // macOS settings window
        SAMVisualEffectViewSwiftUIRepresentable {
            TabView(selection: $dialogManager.selectedSettingsPage) {
                SAMVisualEffectViewSwiftUIRepresentable {
                    DisplaySettingsPageView()
                }
                .frame(width: 400, height: 320)
                .formStyle(.grouped)
                .tabItem {
                    Label(SettingsPage.display.rawValue.capitalized, systemImage: SettingsPage.Icons.display.rawValue)
                }
                .tag(SettingsPage.display)
                SAMVisualEffectViewSwiftUIRepresentable {
                    SpeechSettingsPageView()
                }
                .frame(width: 400, height: 185)
                .formStyle(.grouped)
                .tabItem {
                    Label(SettingsPage.speech.rawValue.capitalized, systemImage: SettingsPage.Icons.speech.rawValue)
                }
                .tag(SettingsPage.speech)
                SAMVisualEffectViewSwiftUIRepresentable {
                    DecksCardsSettingsPageView()
                }
                .frame(width: 400, height: 245)
                .formStyle(.grouped)
                .tabItem {
                    Label(SettingsPage.decksCards.rawValue.capitalized, systemImage: SettingsPage.Icons.decksCards.rawValue)
                }
                .tag(SettingsPage.decksCards)
            }
        }
#else
        // iOS/visionOS settings page
        NavigationStack {
            Form {
                Section {
                    NavigationLink {
                        DisplaySettingsPageView()
                            .navigationTitle(SettingsPage.display.rawValue.capitalized)
                    } label: {
                        Label(SettingsPage.display.rawValue.capitalized, systemImage: SettingsPage.Icons.display.rawValue)
                    }
                    NavigationLink {
                        SpeechSettingsPageView()
                            .navigationTitle(SettingsPage.speech.rawValue.capitalized)
                    } label: {
                        Label(SettingsPage.speech.rawValue.capitalized, systemImage: SettingsPage.Icons.speech.rawValue)
                    }
                    NavigationLink {
                        DecksCardsSettingsPageView()
                            .navigationTitle(SettingsPage.decksCards.rawValue.capitalized)
                    } label: {
                        Label(SettingsPage.decksCards.rawValue.capitalized, systemImage: SettingsPage.Icons.decksCards.rawValue)
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
#endif
    }

}

// MARK: - Preview

#Preview {
    SettingsView()
        .environmentObject(DialogManager())
        .environmentObject(SpeechManager())
}
