//
//  DevelopmentTests.swift
//  UltimatePortfolioAppTests
//
//  Created by Tomasz Ogrodowski on 13/04/2022.
//

import CoreData
import XCTest
@testable import UltimatePortfolioApp

class DevelopmentTests: BaseTestCase {
    
    /// Simple test that makes us 100% sure that
    /// creating sample data works. It is a good foundation for future tests.
    func testSampleDataCreationWorks() throws {
        // it the next code throw, the whole test will throw
        // and we will consider it as a failure.
        try dataController.createSampleData()
        
        XCTAssertEqual(dataController.count(for: Project.fetchRequest()), 5, "There should be 5 sample projects.")
        XCTAssertEqual(dataController.count(for: Item.fetchRequest()), 50, "There should be 50 sample items.")
    }
    

    func testDeletingAllData() throws {
        try dataController.createSampleData()
        print(dataController.count(for: Project.fetchRequest()))
        print(dataController.count(for: Item.fetchRequest()))
        
        dataController.deleteAll()
        XCTAssertEqual(dataController.count(for: Project.fetchRequest()), 0, "deleteAll() should leave no projects.")
        XCTAssertEqual(dataController.count(for: Item.fetchRequest()), 0, "deleteAll() should leave no items.")
    }
    
    func testExampleProjectIsClosed() {
        let project = Project.example
        XCTAssertTrue(project.closed, "The example project should be closed.")
    }
    
    func testExampleItemIsHighPriority() {
        let item = Item.example
        XCTAssertEqual(item.priority, 3, "The example item should be high priority.")
    }
}
