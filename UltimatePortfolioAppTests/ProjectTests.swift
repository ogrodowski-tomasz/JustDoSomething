//
//  ProjectTests.swift
//  UltimatePortfolioAppTests
//
//  Created by Tomasz Ogrodowski on 13/04/2022.
//

import CoreData
import XCTest
@testable import UltimatePortfolioApp

class ProjectTests: BaseTestCase {
    
    /// Creating 10 projects. every one of them has 10 items.
    /// After that we want to assert that swift created
    /// data correctly.
    func testCreatingProjectsAndItems() {
        let targetCount = 10
        
        for _ in 0..<targetCount {
            let project = Project(context: managedObjectContext)
            
            for _ in 0..<targetCount {
                let item = Item(context: managedObjectContext)
                item.project = project
            }
        }
        
        XCTAssertEqual(dataController.count(for: Project.fetchRequest()), targetCount)
        XCTAssertEqual(dataController.count(for: Item.fetchRequest()), targetCount * targetCount)
    }
    
    /// Testing if our cascade deleting system works.
    ///
    /// When we delete project, we are deleting all items that belong to the project.
    /// It is important because if this would not work correctly, items that user thought
    /// he deleted, could appear on home screen.
    /// We have to create some sample data, then fetch all the projects that were loaded
    /// and delete the first one. Then assert that we removed not only the project, but also
    /// items that belong to it.
    func testDeletingProjectCascadeDeletesItems() throws {
        // We have to mark it as throwing because
        // we want to use throwing func.
        // However we will not catch them and let them make
        // our whole test failed.
        try dataController.createSampleData()
        
        // Fetching Project from Core Data with data that we created
        let request = NSFetchRequest<Project>(entityName: "Project")
        let projects = try managedObjectContext.fetch(request)
        
        // Deleting first object
        dataController.delete(projects[0])
        
        // Asserting having 4 projects and 40 items in dataController
        XCTAssertEqual(dataController.count(for: Project.fetchRequest()), 4)
        XCTAssertEqual(dataController.count(for: Item.fetchRequest()), 40)
    }
}
