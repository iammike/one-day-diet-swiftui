//
//  One_Day_DietTests.swift
//  One Day DietTests
//
//  Created by Michael Collins on 1/6/24.
//

import XCTest
@testable import One_Day_Diet

final class One_Day_DietTests: XCTestCase {

    override func setUpWithError() throws {
        // Clear UserDefaults state before each test
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.servingsDataStore)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.lastAccessedDate)
    }

    // MARK: - Score Calculation

    func testZeroServingsScoresZero() {
        let vm = ViewModel()
        XCTAssertEqual(vm.calculateTotalScore(), 0)
    }

    func testSingleHealthyServingScoresPositive() {
        let vm = ViewModel()
        vm.selectedServings[0] = 1  // 1 serving of Fruits = +2
        XCTAssertEqual(vm.calculateTotalScore(), 2)
    }

    func testSingleUnhealthyServingScoresNegative() {
        let vm = ViewModel()
        let sweetsIndex = foodGroupsData.firstIndex(where: { $0.name == "Sweets" })!
        vm.selectedServings[sweetsIndex] = 1  // 1 serving of Sweets = -2
        XCTAssertEqual(vm.calculateTotalScore(), -2)
    }

    func testMixedServingsScoresCombined() {
        let vm = ViewModel()
        vm.selectedServings[0] = 2  // Fruits: +4
        let sweetsIndex = foodGroupsData.firstIndex(where: { $0.name == "Sweets" })!
        vm.selectedServings[sweetsIndex] = 1  // Sweets: -2
        XCTAssertEqual(vm.calculateTotalScore(), 2)
    }

    func testMaxServingsScore() {
        let vm = ViewModel()
        vm.selectedServings[0] = foodGroupsData[0].scores.count - 1  // Fruits max = 7
        XCTAssertEqual(vm.calculateTotalScore(), 7)
    }

    // MARK: - Reset Servings

    func testResetServingsClearsAllServings() {
        let vm = ViewModel()
        vm.selectedServings = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        vm.selectedTrackableServings = [1, 2, 3, 4]
        vm.resetServings(for: Date())
        XCTAssertTrue(vm.selectedServings.allSatisfy { $0 == 0 })
        XCTAssertTrue(vm.selectedTrackableServings.allSatisfy { $0 == 0 })
    }

    func testResetServingsScoresZeroAfterReset() {
        let vm = ViewModel()
        vm.selectedServings[0] = 3
        vm.resetServings(for: Date())
        XCTAssertEqual(vm.calculateTotalScore(), 0)
    }

    // MARK: - Save and Load

    func testSaveAndLoadServingsForDate() {
        let vm = ViewModel()
        let testDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        vm.selectedServings[0] = 3
        vm.selectedServings[1] = 2
        vm.saveData(for: testDate)

        vm.selectedServings = Array(repeating: 0, count: foodGroupsData.count)
        vm.updateData(for: testDate)

        XCTAssertEqual(vm.selectedServings[0], 3)
        XCTAssertEqual(vm.selectedServings[1], 2)
    }

    func testDifferentDatesHaveIndependentServings() {
        let vm = ViewModel()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: Date())!

        vm.selectedServings[0] = 3
        vm.saveData(for: yesterday)

        vm.selectedServings[0] = 5
        vm.saveData(for: twoDaysAgo)

        vm.updateData(for: yesterday)
        XCTAssertEqual(vm.selectedServings[0], 3)

        vm.updateData(for: twoDaysAgo)
        XCTAssertEqual(vm.selectedServings[0], 5)
    }

    // MARK: - Clear All Data

    func testClearAllDataResetsServings() {
        let vm = ViewModel()
        vm.selectedServings[0] = 4
        vm.clearAllData()
        XCTAssertTrue(vm.selectedServings.allSatisfy { $0 == 0 })
        XCTAssertEqual(vm.calculateTotalScore(), 0)
    }

    func testClearAllDataRemovesPersistedData() {
        let vm = ViewModel()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        vm.selectedServings[0] = 4
        vm.saveData(for: yesterday)
        vm.clearAllData()

        vm.updateData(for: yesterday)
        XCTAssertEqual(vm.selectedServings[0], 0)
    }

    // MARK: - Stats: dailyStats

    func testDailyStatsEmptyStoreReturnsEmpty() {
        let vm = ViewModel()
        XCTAssertTrue(vm.dailyStats(for: .thirtyDays).isEmpty)
    }

    func testDailyStatsFiltersIncompleteDays() {
        let vm = ViewModel()
        // 3 total servings is below the fallback threshold of 5
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        vm.selectedServings = Array(repeating: 0, count: foodGroupsData.count)
        vm.selectedServings[0] = 3
        vm.saveData(for: yesterday)
        XCTAssertTrue(vm.dailyStats(for: .thirtyDays).isEmpty)
    }

    func testDailyStatsIncludesCompleteDays() {
        let vm = ViewModel()
        // Fruits: 3 servings (score 6) + Vegetables: 2 servings (score 4) = total 5, score 10
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        vm.selectedServings = Array(repeating: 0, count: foodGroupsData.count)
        vm.selectedServings[0] = 3
        vm.selectedServings[1] = 2
        vm.saveData(for: yesterday)
        let stats = vm.dailyStats(for: .thirtyDays)
        XCTAssertEqual(stats.count, 1)
        XCTAssertEqual(stats[0].score, 10)
    }

    func testDailyStatsDateRangeFiltering() {
        let vm = ViewModel()
        let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
        let tenDaysAgo = Calendar.current.date(byAdding: .day, value: -10, to: Date())!

        vm.selectedServings = Array(repeating: 0, count: foodGroupsData.count)
        vm.selectedServings[0] = 5
        vm.saveData(for: threeDaysAgo)

        vm.selectedServings = Array(repeating: 0, count: foodGroupsData.count)
        vm.selectedServings[0] = 5
        vm.saveData(for: tenDaysAgo)

        XCTAssertEqual(vm.dailyStats(for: .sevenDays).count, 1)
        XCTAssertEqual(vm.dailyStats(for: .all).count, 2)
    }

    func testDailyStatsSortedByDate() {
        let vm = ViewModel()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: Date())!

        vm.selectedServings = Array(repeating: 0, count: foodGroupsData.count)
        vm.selectedServings[0] = 5
        vm.saveData(for: yesterday)

        vm.selectedServings = Array(repeating: 0, count: foodGroupsData.count)
        vm.selectedServings[0] = 5
        vm.saveData(for: twoDaysAgo)

        let stats = vm.dailyStats(for: .all)
        XCTAssertEqual(stats.count, 2)
        XCTAssertLessThan(stats[0].date, stats[1].date)
    }

    func testDailyStatsAdaptiveThresholdFiltersLowDays() {
        let vm = ViewModel()
        // Save 7 days with 10 total servings (median=10, threshold=5)
        for i in 1...7 {
            let date = Calendar.current.date(byAdding: .day, value: -i, to: Date())!
            vm.selectedServings = Array(repeating: 0, count: foodGroupsData.count)
            vm.selectedServings[0] = 5
            vm.selectedServings[1] = 5
            vm.saveData(for: date)
        }
        // Save a day with only 3 servings - below adaptive threshold of 5
        let eightDaysAgo = Calendar.current.date(byAdding: .day, value: -8, to: Date())!
        vm.selectedServings = Array(repeating: 0, count: foodGroupsData.count)
        vm.selectedServings[0] = 3
        vm.saveData(for: eightDaysAgo)

        XCTAssertEqual(vm.dailyStats(for: .all).count, 7)
    }

    // MARK: - Stats: averageServings

    func testAverageServingsEmptyReturnsZeros() {
        let vm = ViewModel()
        let avgs = vm.averageServings(for: .thirtyDays)
        XCTAssertEqual(avgs.count, foodGroupsData.count)
        XCTAssertTrue(avgs.allSatisfy { $0 == 0 })
    }

    func testAverageServingsCalculation() {
        let vm = ViewModel()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: Date())!

        // Day 1: Fruits=4, Veg=1 (total=5, meets threshold)
        vm.selectedServings = Array(repeating: 0, count: foodGroupsData.count)
        vm.selectedServings[0] = 4
        vm.selectedServings[1] = 1
        vm.saveData(for: yesterday)

        // Day 2: Fruits=2, Veg=3 (total=5, meets threshold)
        vm.selectedServings = Array(repeating: 0, count: foodGroupsData.count)
        vm.selectedServings[0] = 2
        vm.selectedServings[1] = 3
        vm.saveData(for: twoDaysAgo)

        let avgs = vm.averageServings(for: .thirtyDays)
        XCTAssertEqual(avgs[0], 3.0, accuracy: 0.01)  // (4 + 2) / 2
        XCTAssertEqual(avgs[1], 2.0, accuracy: 0.01)  // (1 + 3) / 2
    }

    // MARK: - Date Extensions

    func testFormattedDateFormat() {
        var components = DateComponents()
        components.year = 2024
        components.month = 3
        components.day = 15
        let date = Calendar.current.date(from: components)!
        XCTAssertEqual(date.formattedDate, "2024-03-15")
    }

    func testDisplayLabelToday() {
        XCTAssertEqual(Date().displayLabel, "Today")
    }

    func testDisplayLabelYesterday() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        XCTAssertEqual(yesterday.displayLabel, "Yesterday")
    }

    func testDisplayLabelOtherDate() {
        var components = DateComponents()
        components.year = 2024
        components.month = 3
        components.day = 15
        let date = Calendar.current.date(from: components)!
        XCTAssertEqual(date.displayLabel, "Fri, Mar 15")
    }
}
