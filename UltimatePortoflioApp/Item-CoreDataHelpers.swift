//
//  Item-CoreDataHelpers.swift
//  UltimatePortoflioApp
//
//  Created by Tomasz Ogrodowski on 04/04/2022.
//
// swiftlint:disable trailing_whitespace

import Foundation

/// Extension on Item entity that provides us nil coallesed values of its parameters
/// and lets us create example data
extension Item {
    
    enum SortOrder {
        case optimized, title, creationDate
    }
    
    var itemTitle: String { title ?? NSLocalizedString("New Item", comment: "Create a new item") }
    var itemDetail: String { detail ?? "" }
    var itemCreationDate: Date { creationDate ?? Date() }
    
    static var example: Item {
        let controller = DataController(inMemory: true)
        let viewContext = controller.container.viewContext
        
        let item = Item(context: viewContext)
        item.title = "Example item"
        item.detail = "This is an example item"
        item.priority = 3
        item.creationDate = Date()
        
        return item
    }
}
