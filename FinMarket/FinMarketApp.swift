//
//  HelloIphoneApp.swift
//  HelloIphone
//
//  Created by patrick zagiel on 09/04/2022.
//

import SwiftUI

@main
struct FinMarketApp: App {
    @Environment(\.colorScheme) var colorScheme

        init() {
            // Forcer le mode sombre
            UITraitCollection.current = UITraitCollection(traitsFrom: [UITraitCollection(userInterfaceStyle: .dark)])
        }
    
    var body: some Scene {
        WindowGroup {
            ContentView().preferredColorScheme(.dark)
        }
    }
}
