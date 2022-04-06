//
//  Project-CoreDataHelpers.swift
//  UltimatePortoflioApp
//
//  Created by Tomasz Ogrodowski on 04/04/2022.
//

import Foundation

extension Project {
    
    static let colors = ["Pink", "Purple", "Red", "Orange", "Gold", "Green", "Teal", "Light Blue", "Dark Blue", "Midnight", "Dark Gray", "Gray"]
    
    var projectTitle: String { title ?? "New project" }
    var projectDetail: String { detail ?? "" }
    var projectColor: String { color ?? "Light Blue" }
    
    var projectItems: [Item] {
        let itemsArray = items?.allObjects as? [Item] ?? [] // When u add "to many" relationship in CoreData, we get our items back as a SET rather than ARRAY. '.allObjects' is making them as an array. Swift thinks this set (created by allObjects) is a set of any type. We must tell swift that its a Array of Items
        return itemsArray.sorted { first, second in
            if first.completed == false {
                if second.completed == true {
                    return true
                }
            } else if first.completed == true {
                if second.completed == false {
                    return false
                }
            }
            
            if first.priority > second.priority {
                return true
            } else if first.priority < second.priority {
                return false
            }
            
            return first.itemCreationDate < second.itemCreationDate
        }
    }
    
    var completionAmount: Double {
        let originalItems = items?.allObjects as? [Item] ?? [] // Stwórz tablicę typów Item
        guard originalItems.isEmpty == false else { return 0 } // Jeśli tablica jest pusta, zwróc 0
        
        let completedItems = originalItems.filter(\.completed) // Filtrowanie tablicy typów Item, na te, których parametr completed == true
        
        return Double(completedItems.count) / Double(originalItems.count) // Ich stosunek do siebie
    }
    
    static var example: Project {
        let controller = DataController(inMemory: true)
        let viewContext = controller.container.viewContext
        
        let project = Project(context: viewContext)
        project.title = "Example project"
        project.detail = "This is an example project"
        project.closed = true
        project.creationDay = Date()
        
        return project
    }
    

}
