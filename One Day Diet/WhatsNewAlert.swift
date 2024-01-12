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
                            🧪 Macro tracking! Hidden by default, these are unscored and can be enabled via the menu.

                            👆 Haptic feedback makes your taps more obvious.

                            🙋 Added yet another Q&A to FAQ. These are all from my wife.

                            Still getting those requests to make 🍆 the vegetable. Still ignoring them.
                            """
        
        return Alert(
            title: Text("What's New in \(currentVersion)?"),
            message: Text("\n\(bulletedList)"),
            dismissButton: .default(Text("OK"))
        )
    }
}

