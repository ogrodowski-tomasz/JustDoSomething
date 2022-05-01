//
//  UltimatePortfolioAppTests.swift
//  UltimatePortfolioAppTests
//
//  Created by Tomasz Ogrodowski on 12/04/2022.
//

import CoreData
import XCTest
@testable import UltimatePortfolioApp

/// Class which is a base for all future tests.
class BaseTestCase: XCTestCase {
    var dataController: DataController!
    var managedObjectContext: NSManagedObjectContext!

    override func setUpWithError() throws {
        dataController = DataController(inMemory: true)
        managedObjectContext = dataController.container.viewContext
    }
}
