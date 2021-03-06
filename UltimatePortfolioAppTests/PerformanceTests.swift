//
//  PerformanceTests.swift
//  UltimatePortfolioAppTests
//
//  Created by Tomasz Ogrodowski on 01/05/2022.
//

import XCTest
@testable import UltimatePortfolioApp

class PerformanceTests: BaseTestCase {

    func testAwardCalculationPerformance() throws {
        // Create a significant amount of test data
        for _ in 1...100 {
            try dataController.createSampleData()
        }

        // Simulate lots of awards to check
        let awards = Array(repeating: Award.allAwards, count: 25).joined()
        XCTAssertEqual(
            awards.count,
            500,
            "This checks the number of awards is contant. Change this if you add new awards.")

        measure {
            _ = awards.filter(dataController.hasEarned)
        }
    }

}
