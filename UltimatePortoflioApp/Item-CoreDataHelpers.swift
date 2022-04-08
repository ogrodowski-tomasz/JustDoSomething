//
//  Item-CoreDataHelpers.swift
//  UltimatePortoflioApp
//
//  Created by Tomasz Ogrodowski on 04/04/2022.
//

import Foundation

extension Item { // Rozszerzenie klasy Item tak by nie musieć bawic się w rozpakowywanie optionali
    
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
