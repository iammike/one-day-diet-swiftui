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
                            👈👉 Swipe left or right on the date area to change days.
                            """
        
        return Alert(
            title: Text("What's New in \(currentVersion)?"),
            message: Text("\n\(bulletedList)"),
            dismissButton: .default(Text("OK"))
        )
    }
}

