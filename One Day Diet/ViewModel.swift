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
    static let showMacros = "showMacros"
    static let lastVersionPromptedForReview = "lastVersionPromptedForReview"

    static func trackableServingsKey(for dateKey: String) -> String {
        "trackable_\(dateKey)"
    }
}

class ViewModel: ObservableObject {
    @Published var selectedServings: [Int]
    @Published var selectedTrackableServings: [Int]
    @Published var currentDate: Date = Date()
    private var servingsDataStore: [String: [Int]] = [:]
    private var undoServings: [Int]?
    private var undoTrackableServings: [Int]?
    private var shouldCaptureUndo = true

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
        if shouldCaptureUndo {
            shouldCaptureUndo = false
            undoServings = servingsDataStore[dateKey] ?? Array(repeating: 0, count: foodGroupsData.count)
            undoTrackableServings = servingsDataStore[UserDefaultsKeys.trackableServingsKey(for: dateKey)] ?? Array(repeating: 0, count: trackablesData.count)
            DispatchQueue.main.async { [weak self] in self?.shouldCaptureUndo = true }
        }
        servingsDataStore[dateKey] = selectedServings
        servingsDataStore[UserDefaultsKeys.trackableServingsKey(for: dateKey)] = selectedTrackableServings
        UserDefaults.standard.set(servingsDataStore, forKey: UserDefaultsKeys.servingsDataStore)
    }

    func undoLastChange(for date: Date) {
        guard let servings = undoServings, let trackable = undoTrackableServings else { return }
        undoServings = nil
        undoTrackableServings = nil
        selectedServings = servings
        selectedTrackableServings = trackable
        let dateKey = date.formattedDate
        servingsDataStore[dateKey] = servings
        servingsDataStore[UserDefaultsKeys.trackableServingsKey(for: dateKey)] = trackable
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
        selectedTrackableServings = servingsDataStore[UserDefaultsKeys.trackableServingsKey(for: dateKey)] ?? Array(repeating: 0, count: trackablesData.count)
    }
}

extension Date {
    private static let iso8601Formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    private static let displayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEE, MMM d"
        return f
    }()

    var formattedDate: String {
        Date.iso8601Formatter.string(from: self)
    }

    var displayLabel: String {
        if Calendar.current.isDateInToday(self) { return "Today" }
        if Calendar.current.isDateInYesterday(self) { return "Yesterday" }
        return Date.displayFormatter.string(from: self)
    }
}
