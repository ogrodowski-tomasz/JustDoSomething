//
//  AwardTests.swift
//  UltimatePortfolioAppTests
//
//  Created by Tomasz Ogrodowski on 13/04/2022.
//

import CoreData
import XCTest
@testable import UltimatePortfolioApp

class AwardTests: BaseTestCase {
    // We will use awards a lot, so
    // we create property with allAwards
    let awards = Award.allAwards

    /// Cheching if awards id is the same as their name.
    ///
    /// Every award should be identifiable with their name
    func testAwardIDMatchesName() {
        for award in awards {
            XCTAssertEqual(award.name, award.id, "Award's name and ID don't match.")
        }
    }

    /// Checking if new user has no awards given.
    ///
    /// Every test is a new user coming in because inMemory property
    /// is set to 'true'.
    func testNewUserHasNoAwards() {
        for award in awards {
            XCTAssertFalse(dataController.hasEarned(award: award), "New user should have no earned awards.")
        }
    }

    /// Testing if adding a certain amount of items will unlock
    /// correct number of awards
    func testAddingItems() {
        let values = [1, 10, 20, 50, 100, 250, 500, 1000]

        for (count, value) in values.enumerated() {
            for _ in 0..<value {
                _ = Item(context: managedObjectContext)
            }

            let matches = awards.filter { award in
                award.criterion == "items" && dataController.hasEarned(award: award)
            }

            XCTAssertEqual(matches.count, count + 1, "Adding \(value) items should unlock \(count + 1) awards")

            // Making sure to delete this array so it doesn't affect the next test
                dataController.deleteAll()
        }
    }
    func testCompletingItems() {
        let values = [1, 10, 20, 50, 100, 250, 500, 1000]

        for (count, value) in values.enumerated() {

            for _ in 0..<value {
                let item = Item(context: managedObjectContext)
                item.completed = true
            }

            let matches = awards.filter { award in
                award.criterion == "complete" && dataController.hasEarned(award: award)
            }

            XCTAssertEqual(matches.count, count + 1, "Completing \(value) items should unlock \(count + 1) awards")

                dataController.deleteAll()
        }
    }
}
