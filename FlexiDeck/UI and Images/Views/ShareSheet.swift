//
//  ShareSheet.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 12/26/24.
//  Copyright © 2024-2025 SheftApps. All rights reserved.
//

import SwiftUI

#if os(iOS)
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
#endif 
