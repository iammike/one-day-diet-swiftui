//
//  One_Day_DietUITests.swift
//  One Day DietUITests
//
//  Created by Michael Collins on 1/6/24.
//

import XCTest

final class One_Day_DietUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSwipeLeftGoesForwardADay() throws {
        let app = XCUIApplication()
        app.launch()

        // Go back one day first so we have room to swipe forward
        let backButton = app.buttons["arrow.left"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 3))
        backButton.tap()

        let datePicker = app.datePickers.firstMatch
        XCTAssertTrue(datePicker.waitForExistence(timeout: 3))
        let labelBefore = datePicker.value as? String ?? ""

        // Swipe on the score label (plain SwiftUI text, won't intercept gesture)
        let scoreLabel = app.staticTexts.matching(identifier: "totalScore").firstMatch
        XCTAssertTrue(scoreLabel.waitForExistence(timeout: 3))
        scoreLabel.swipeLeft()

        let labelAfter = datePicker.value as? String ?? ""
        XCTAssertNotEqual(labelBefore, labelAfter, "Date should have changed after swiping left")
    }

    func testSwipeRightGoesBackADay() throws {
        let app = XCUIApplication()
        app.launch()

        let datePicker = app.datePickers.firstMatch
        XCTAssertTrue(datePicker.waitForExistence(timeout: 3))
        let labelBefore = datePicker.value as? String ?? ""

        // Swipe on the score label (plain SwiftUI text, won't intercept gesture)
        let scoreLabel = app.staticTexts.matching(identifier: "totalScore").firstMatch
        XCTAssertTrue(scoreLabel.waitForExistence(timeout: 3))
        scoreLabel.swipeRight()

        let labelAfter = datePicker.value as? String ?? ""
        XCTAssertNotEqual(labelBefore, labelAfter, "Date should have changed after swiping right")
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
