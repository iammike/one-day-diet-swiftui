//
//  ViewModel.swift
//  One Day Diet
//
//  Created by Michael Collins on 1/7/24.
//

import SwiftUI

struct UserDefaultsKeys {
    static let servingsDataStore = "servingsDataStore"
    static let lastAccessedDate = "lastAccessedDate"
}

class ViewModel: ObservableObject {
    @Published var selectedServings: [Int]
    @Published var selectedTrackableServings: [Int]
    @Published var currentDate: Date = Date()
    private var servingsDataStore: [String: [Int]] = [:]

    init() {
        self.selectedServings = Array(repeating: 0, count: foodGroupsData.count)
        self.selectedTrackableServings = Array(repeating: 0, count: trackablesData.count)

        let defaults = UserDefaults.standard

        self.servingsDataStore = defaults.object(forKey: UserDefaultsKeys.servingsDataStore) as? [String: [Int]] ?? [:]

        let todayKey = Date().formattedDate
        let lastAccessedDate = defaults.string(forKey: UserDefaultsKeys.lastAccessedDate) ?? todayKey

        if lastAccessedDate != todayKey {
            resetServings(for: Date())
        } else {
            loadServings(for: todayKey)
        }
        updateLastAccessedDate()
    }
    
    func checkAndUpdateDate() {
        let todayKey = Date().formattedDate
        let lastAccessedDate = UserDefaults.standard.string(forKey: UserDefaultsKeys.lastAccessedDate) ?? todayKey

        if lastAccessedDate != todayKey {
            currentDate = Date()
            resetServings(for: currentDate)
        }
        updateLastAccessedDate()
    }

    private func updateLastAccessedDate() {
        let todayKey = Date().formattedDate
        UserDefaults.standard.set(todayKey, forKey: UserDefaultsKeys.lastAccessedDate)
    }

    func resetServings(for date: Date) {
        selectedServings = Array(repeating: 0, count: foodGroupsData.count)
        selectedTrackableServings = Array(repeating: 0, count: trackablesData.count)
        saveData(for: date)
    }

    func calculateTotalScore() -> Int {
        selectedServings.enumerated().reduce(0) { total, index in
            total + foodGroupsData[index.offset].scores[index.element]
        }
    }

    func updateData(for date: Date) {
        let dateKey = date.formattedDate
        loadServings(for: dateKey)
        saveData(for: date)
    }

    func saveData(for date: Date) {
        let dateKey = date.formattedDate
        servingsDataStore[dateKey] = selectedServings
        servingsDataStore["trackable_\(dateKey)"] = selectedTrackableServings
        UserDefaults.standard.set(servingsDataStore, forKey: UserDefaultsKeys.servingsDataStore)
    }

    func servingControlValueChanged(on date: Date) {
        saveData(for: date)
    }

    func clearAllData() {
        servingsDataStore = [:]
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.servingsDataStore)
        resetServings(for: Date())
    }

    private func loadServings(for dateKey: String) {
        selectedServings = servingsDataStore[dateKey] ?? Array(repeating: 0, count: foodGroupsData.count)
        selectedTrackableServings = servingsDataStore["trackable_\(dateKey)"] ?? Array(repeating: 0, count: trackablesData.count)
    }
}

extension Date {
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
}
