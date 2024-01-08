//
//  ViewModel.swift
//  One Day Diet
//
//  Created by Michael Collins on 1/7/24.
//

import SwiftUI

struct UserDefaultsKeys {
    static let selectedServings = "selectedServings"
    static let servingsDataStore = "servingsDataStore"
}

class ViewModel: ObservableObject {
    @Published var selectedServings: [Int]
    private var servingsDataStore: [String: [Int]] = [:]

    init() {
        self.selectedServings = UserDefaults.standard.array(forKey: UserDefaultsKeys.selectedServings) as? [Int] ?? Array(repeating: 0, count: foodGroupsData.count)
        if let storedData = UserDefaults.standard.object(forKey: UserDefaultsKeys.servingsDataStore) as? [String: [Int]] {
            self.servingsDataStore = storedData
        }
        let todayKey = Date().formattedDate
        self.selectedServings = self.servingsDataStore[todayKey] ?? Array(repeating: 0, count: foodGroupsData.count)
    }


    func resetServings(for date: Date) {
        selectedServings = Array(repeating: 0, count: foodGroupsData.count)
        saveData(for: date)
    }

    func calculateTotalScore() -> Int {
        selectedServings.enumerated().reduce(0) { total, index in
            total + foodGroupsData[index.offset].scores[index.element]
        }
    }

    func updateData(for date: Date) {
        let dateKey = date.formattedDate
        if let savedData = servingsDataStore[dateKey] {
            selectedServings = savedData
        } else {
            resetServings(for: date)
        }
        saveData(for: date)
    }

    func saveData(for date: Date) {
        let dateKey = date.formattedDate
        servingsDataStore[dateKey] = selectedServings
        UserDefaults.standard.set(servingsDataStore, forKey: UserDefaultsKeys.servingsDataStore)
    }
    
    func sliderValueChanged(on date: Date) {
        saveData(for: date)
    }
    
    func clearAllData() {
        servingsDataStore = [:]
        selectedServings = Array(repeating: 0, count: foodGroupsData.count)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.servingsDataStore)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.selectedServings)
    }
}

extension Date {
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
}
