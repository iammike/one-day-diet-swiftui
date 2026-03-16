//
//  WhatsNewAlert.swift
//  One Day Diet
//
//  Created by Michael Collins on 1/9/24.
//

import SwiftUI

struct WhatsNewAlert {
    private let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"

    private var bulletedList: String {
        """
        👈👉 Swipe left or right on the date area to change days.
        """
    }

    var versionTitle: String { "What's New in \(currentVersion)?" }
    var versionMessage: String { "\n\(bulletedList)" }

    func shouldShowAlert() -> Bool {
        let defaults = UserDefaults.standard
        let lastVersionPromptedForReview = defaults.string(forKey: UserDefaultsKeys.lastVersionPromptedForReview)

        if lastVersionPromptedForReview != currentVersion {
            defaults.set(currentVersion, forKey: UserDefaultsKeys.lastVersionPromptedForReview)
            return true
        }
        return false
    }
}
