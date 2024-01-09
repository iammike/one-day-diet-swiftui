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
    static let lastAccessedDate = "lastAccessedDate"
}

class ViewModel: ObservableObject {
    @Published var selectedServings: [Int]
    @Published var currentDate: Date = Date()
    private var servingsDataStore: [String: [Int]] = [:]

    init() {
        let defaults = UserDefaults.standard
        self.selectedServings = defaults.array(forKey: UserDefaultsKeys.selectedServings) as? [Int] ?? Array(repeating: 0, count: foodGroupsData.count)

        if let storedData = defaults.object(forKey: UserDefaultsKeys.servingsDataStore) as? [String: [Int]] {
            self.servingsDataStore = storedData
        }

        let todayKey = Date().formattedDate
        let lastAccessedDate = defaults.string(forKey: UserDefaultsKeys.lastAccessedDate) ?? todayKey

        if lastAccessedDate != todayKey {
            self.selectedServings = Array(repeating: 0, count: foodGroupsData.count)
            saveData(for: Date())
        } else {
            self.selectedServings = self.servingsDataStore[todayKey] ?? Array(repeating: 0, count: foodGroupsData.count)
        }

        updateLastAccessedDate()
    }
    
    func checkAndUpdateDate() {
        print("inside check and update")
        let defaults = UserDefaults.standard
        let todayKey = Date().formattedDate
        let lastAccessedDate = defaults.string(forKey: UserDefaultsKeys.lastAccessedDate) ?? todayKey

        saveData(for: currentDate)

        if lastAccessedDate != todayKey {
            self.currentDate = Date()

            if let todayData = servingsDataStore[todayKey] {
                self.selectedServings = todayData
            } else {
                self.selectedServings = Array(repeating: 0, count: foodGroupsData.count)
                saveData(for: Date())
            }
        }
        
        updateLastAccessedDate()
    }


    private func updateLastAccessedDate() {
        let defaults = UserDefaults.standard
        let todayKey = Date().formattedDate
        defaults.set(todayKey, forKey: UserDefaultsKeys.lastAccessedDate)
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
    
//    func calculateTotalServings() -> Int {
//        selectedServings.reduce(0, +)
//    }

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
        print("saving for slider change for " + date.formattedDate)
        saveData(for: date)
    }
    
    func clearAllData() {
        servingsDataStore = [:]

        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: UserDefaultsKeys.servingsDataStore)
        
        currentDate = Date()

        selectedServings = Array(repeating: 0, count: foodGroupsData.count)

        saveData(for: currentDate)
    }
}

extension Date {
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
}

