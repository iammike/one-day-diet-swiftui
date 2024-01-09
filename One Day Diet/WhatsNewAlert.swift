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
//        return false
        return true
    }


    func getVersionAlert() -> Alert {
        let bulletedList = 
                            """
                            • Bolded app title 🎆
                            • Added this new version alert 🪄
                            • Added a FAQ to the menu 🙋
                            """
        
        return Alert(
            title: Text("What's New in \(currentVersion)!"),
            message: Text("\(bulletedList)"),
            dismissButton: .default(Text("OK"))
        )
    }
}

