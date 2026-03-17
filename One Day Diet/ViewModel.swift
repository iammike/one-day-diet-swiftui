//
//  ViewModel.swift
//  One Day Diet
//
//  Created by Michael Collins on 1/7/24.
//

import SwiftUI

enum AppColorScheme: String, CaseIterable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

struct UserDefaultsKeys {
    static let servingsDataStore = "servingsDataStore"
    static let lastAccessedDate = "lastAccessedDate"
    static let showMacros = "showMacros"
    static let colorSchemePreference = "colorSchemePreference"
    static let lastVersionPromptedForReview = "lastVersionPromptedForReview"

    static func trackableServingsKey(for dateKey: String) -> String {
        "trackable_\(dateKey)"
    }
}

struct DailyStats: Identifiable {
    let id = UUID()
    let date: Date
    let score: Int
}

enum StatsRange: String, CaseIterable {
    case sevenDays = "7D"
    case thirtyDays = "30D"
    case ninetyDays = "90D"
    case oneYear = "1Y"
    case all = "All"

    var days: Int? {
        switch self {
        case .sevenDays: return 7
        case .thirtyDays: return 30
        case .ninetyDays: return 90
        case .oneYear: return 365
        case .all: return nil
        }
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

    // Adaptive threshold: median of all daily totals / 2, with a floor of 5 until 7+ days recorded
    private func incompleteThreshold() -> Int {
        let todayKey = Date().formattedDate
        let totals = servingsDataStore.keys
            .filter { !$0.hasPrefix("trackable_") && $0 != todayKey }
            .compactMap { key -> Int? in
                let total = (servingsDataStore[key] ?? []).reduce(0, +)
                return total > 0 ? total : nil
            }
            .sorted()
        guard totals.count >= 7 else { return 5 }
        return totals[totals.count / 2] / 2
    }

    func dailyStats(for range: StatsRange) -> [DailyStats] {
        let threshold = incompleteThreshold()
        let todayKey = Date().formattedDate
        let cutoff: Date? = range.days.map {
            Calendar.current.date(byAdding: .day, value: -$0, to: Date()) ?? Date()
        }
        return servingsDataStore.keys
            .filter { !$0.hasPrefix("trackable_") }
            .compactMap { key -> DailyStats? in
                guard key != todayKey else { return nil }
                guard let date = Date.from(isoString: key) else { return nil }
                if let cutoff, date < cutoff { return nil }
                let servings = servingsDataStore[key] ?? []
                guard servings.reduce(0, +) >= threshold else { return nil }
                let score = servings.enumerated().reduce(0) { sum, pair in
                    guard pair.offset < foodGroupsData.count else { return sum }
                    let group = foodGroupsData[pair.offset]
                    let idx = min(pair.element, group.scores.count - 1)
                    return sum + group.scores[idx]
                }
                return DailyStats(date: date, score: score)
            }
            .sorted { $0.date < $1.date }
    }

    func averageServings(for range: StatsRange) -> [Double] {
        let threshold = incompleteThreshold()
        let todayKey = Date().formattedDate
        let cutoff: Date? = range.days.map {
            Calendar.current.date(byAdding: .day, value: -$0, to: Date()) ?? Date()
        }
        let validServings = servingsDataStore.keys
            .filter { !$0.hasPrefix("trackable_") }
            .compactMap { key -> [Int]? in
                guard key != todayKey else { return nil }
                guard let date = Date.from(isoString: key) else { return nil }
                if let cutoff, date < cutoff { return nil }
                let servings = servingsDataStore[key] ?? []
                return servings.reduce(0, +) >= threshold ? servings : nil
            }
        guard !validServings.isEmpty else { return Array(repeating: 0, count: foodGroupsData.count) }
        let count = Double(validServings.count)
        return (0..<foodGroupsData.count).map { i in
            let total = validServings.reduce(0) { sum, servings in sum + (servings.count > i ? servings[i] : 0) }
            return Double(total) / count
        }
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

    static func from(isoString: String) -> Date? {
        iso8601Formatter.date(from: isoString)
    }

    var formattedDate: String {
        Date.iso8601Formatter.string(from: self)
    }

    var displayLabel: String {
        if Calendar.current.isDateInToday(self) { return "Today" }
        if Calendar.current.isDateInYesterday(self) { return "Yesterday" }
        return Date.displayFormatter.string(from: self)
    }
}
