//
//  UltimatePortfolioAppUITests.swift
//  UltimatePortfolioAppUITests
//
//  Created by Tomasz Ogrodowski on 01/05/2022.
//

import XCTest

class UltimatePortfolioAppUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["enable-testing"]
        app.launch()
    }

    func testHas4Tabs() throws {
        XCTAssertEqual(app.tabBars.buttons.count, 4, "There should be 4 tabs in the app.")
    }

    func testOpenTabAddsItem() {
        app.buttons["Otwarte"].tap()
        XCTAssertEqual(app.tables.cells.count, 0, "There should be no list rows initially.")

        for tapCount in 1...5 {
            app.buttons["Dodaj projekt"].tap()
            XCTAssertEqual(app.tables.cells.count, tapCount, "There should be \(tapCount) list row(s).")

        }
    }

    func testAddingItemInsertsRows() {
        app.buttons["Otwarte"].tap()
        XCTAssertEqual(app.tables.cells.count, 0, "There should be no list rows initially.")

        app.buttons["Dodaj projekt"].tap()
        XCTAssertEqual(app.tables.cells.count, 1, "There should be 1 list row.")

        app.buttons["Dodaj nowy element"].tap()
        XCTAssertEqual(app.tables.cells.count, 2, "There should be 2 list rows after adding an item.")
    }

    func testEditingProjectUpdatesCorrectly() {
        app.buttons["Otwarte"].tap()
        XCTAssertEqual(app.tables.cells.count, 0, "There should be no list rows initially.")

        app.buttons["Dodaj projekt"].tap()
        XCTAssertEqual(app.tables.cells.count, 1, "There should be 1 list row.")

        app.buttons["Edytuj projekt"].tap()
        app.textFields["Nazwa projektu"].tap()

        app.keys["spacja"].tap()
        app.keys["more"].tap()
        app.keys["2"].tap()
        app.buttons["Return"].tap()

        app.buttons["Otwarte Projekty"].tap()
        XCTAssertTrue(app.staticTexts["Nowy projekt 2"].exists, "The new project name should be visible in the list.")
    }

    func testEditingItemUpdatesCorrectly() {
        // Go to Open projects and add one project and one item before the test.
        testAddingItemInsertsRows()

        app.buttons["Nowy element"].tap()
        app.textFields["Nazwa elementu"].tap()

        app.keys["spacja"].tap()
        app.keys["more"].tap()
        app.keys["2"].tap()
        app.buttons["Return"].tap()

        app.buttons["Otwarte Projekty"].tap()
        XCTAssertTrue(app.buttons["Nowy element 2"].exists, "The new item name should be visible in the list.")
    }

    func testAllAwardsShowLockedAlert() {
        app.buttons["Odznaki"].tap()

        for award in app.scrollViews.buttons.allElementsBoundByIndex {
            award.tap()
            XCTAssertTrue(app.alerts["Zablokowany"].exists, "There should be a locked alert showing for awards.")
            app.buttons["Okej"].tap()
        }
    }

}
