//
//  PerformedApp.swift
//  Performed
//
//  Created by Lucas Morin on 08/01/2026.
//

import SwiftUI
import GoogleMobileAds

@main
struct PerformedApp: App {
    
    // Initialiser AdMob au démarrage
        init() {
            GADMobileAds.sharedInstance().start(completionHandler: nil)
        }

    var body: some Scene {
        WindowGroup {
            ContentView()

        }
    }
}
