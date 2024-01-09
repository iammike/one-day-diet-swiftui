//
//  WhatsNewAlert.swift
//  One Day Diet
//
//  Created by Michael Collins on 1/9/24.
//

import SwiftUI

struct WhatsNewAlert {
    private let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"

    func shouldShowAlert() -> Bool {
        let defaults = UserDefaults.standard
        let lastVersionPromptedForReview = defaults.string(forKey: "lastVersionPromptedForReview")

        if lastVersionPromptedForReview != currentVersion {
            defaults.set(currentVersion, forKey: "lastVersionPromptedForReview")
            return true
        }
        return false
    }


    func getVersionAlert() -> Alert {
        let bulletedList = 
                            """
                            🎆 Bolded app title
                            🪄 Added this new version alert
                            🙋 Added a FAQ to the menu
                            🌶️ Menu: New icon, design, and inline icons
                            🗓️ Adjusted logic to determine when to switch to a new day
                            🎨 Adjusted some food group icons
                            """
        
        return Alert(
            title: Text("What's New in \(currentVersion)!"),
            message: Text("\n\(bulletedList)"),
            dismissButton: .default(Text("OK"))
        )
    }
}

