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
                            🧪 Macro tracking! Hidden by default, these are unscored and can be enabled via the menu
                            👆 Haptic feedback makes your taps more obvious
                            🙋 Added a Q&A to FAQ

                            There have been many requests for more 🍆 in the app. I don't know what that's all about, but I'm ignoring them for now.
                            """
        
        return Alert(
            title: Text("What's New in \(currentVersion)?"),
            message: Text("\n\(bulletedList)"),
            dismissButton: .default(Text("OK"))
        )
    }
}

