//
//  WhatsNewAlert.swift
//  One Day Diet
//
//  Created by Michael Collins on 1/9/24.
//

import SwiftUI

struct WhatsNewAlert {
    private let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"

    static let items: [(emoji: String, text: String)] = [
        ("👈👉", "Swipe left or right on the date area to change days."),
        ("📳", "Shake your phone to undo the last serving change."),
        ("📊", "Tap the menu to view your score history and food group trends."),
        ("🌙", "Choose your appearance in the menu: System, Light, or Dark.")
    ]

    var versionTitle: String { "What's New in \(currentVersion)?" }

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

struct WhatsNewView: View {
    let title: String
    var dismissAction: () -> Void

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(WhatsNewAlert.items, id: \.text) { item in
                    HStack(alignment: .top, spacing: 14) {
                        Text(item.emoji)
                            .font(.title2)
                            .frame(width: 40, alignment: .center)
                        Text(item.text)
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismissAction() }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
