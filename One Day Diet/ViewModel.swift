//
//  ViewModel.swift
//  One Day Diet
//
//  Created by Michael Collins on 1/7/24.
//

import SwiftUI

struct UserDefaultsKeys {
    static let selectedServings = "selectedServings"
}

class ViewModel: ObservableObject {
    @Published var selectedServings: [Int]

    init() {
        self.selectedServings = UserDefaults.standard.array(forKey: UserDefaultsKeys.selectedServings) as? [Int] ?? Array(repeating: 0, count: foodGroupsData.count)
    }

    func resetServings() {
        selectedServings = Array(repeating: 0, count: foodGroupsData.count)
        UserDefaults.standard.set(selectedServings, forKey: UserDefaultsKeys.selectedServings)
    }

    func calculateTotalScore() -> Int {
        selectedServings.enumerated().reduce(0) { total, index in
            total + foodGroupsData[index.offset].scores[index.element]
        }
    }
}
