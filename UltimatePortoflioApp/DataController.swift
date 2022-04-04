//
//  DataController.swift
//  UltimatePortoflioApp
//
//  Created by Tomasz Ogrodowski on 30/03/2022.
//

import CoreData
import SwiftUI

// MARK: Class responsible for handling CoreData:
// 1. Setting up our model
// 2. Handling interactions between them

class DataController: ObservableObject {
    let container: NSPersistentCloudKitContainer // Containder that contains CoreData but also shares it within CloudKit
    
        init(inMemory: Bool = false) { // inMemory = true means that we want to work on RAM memory
            container = NSPersistentCloudKitContainer(name: "Main") // load that "Main" model as our data
            
            if inMemory { // if we're in RAM, dont write changes to disk
                container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null") // Write our changes to a null disk
                // When we end working with our data it will be destroyed, not saved to disk
            }
            
            // If we're not in RAM, search for our CoreData file and load it
            container.loadPersistentStores { storeDescription, error in
                if let error = error {
                    fatalError("Fatal error loading store: \(error.localizedDescription)")
                }
            }
        }
    
    static var preview: DataController = {
        // Tworzymy preview by kontrolować czy app działa.
        let dataController = DataController(inMemory: true)
        
        do {
            try dataController.createSampleData()
        } catch {
            fatalError("Creating preview error: \(error.localizedDescription)")
        }
        return dataController
    }() // To oznacza, że ten closure jest lazy, czyli będzie tworzony tylko wtedy gdy go specjalnie wywołamy. To pomaga oszczędzć zasoby
    
    func createSampleData() throws {
        let viewContext = container.viewContext // Pool of data that's been loaded from disk (that's active right now). This thing holds all kind of active objects that lives right now, as we work with them (modify etc). It only sends it back to storage, when we tell him to .save()
        
        for i in 1...5 {
            let project = Project(context: viewContext)
            project.title = "Project \(i)"
            project.items = []
            project.creationDay = Date()
            project.closed = Bool.random()
            
            for j in 1...10 {
                let item = Item(context: viewContext)
                item.title = "Item \(j)"
                item.creationDate = Date()
                item.completed = Bool.random()
                item.project = project
                item.priority = Int16.random(in: 1...3)
            }
        }
        
        try viewContext.save()
    }
    
    func save() { // Zapisuj tylko gdy nastąpiły jakieś zmiany
        if container.viewContext.hasChanges {
            try? container.viewContext.save()
        }
    }
    
    func delete(_ object: NSManagedObject) { // Wszystkie obiekty w CoreData dziedziczą po NSManagedObject
        container.viewContext.delete(object)
    }
    
    func deleteAll() { // Przyda nam się to usuwanie do testowania czy nasza baza działa
        let fetchRequest1: NSFetchRequest<NSFetchRequestResult> = Item.fetchRequest() // "Znajdź mi wszystkie 'Items' sposród naszych danych
        let batchDeleteRequest1 = NSBatchDeleteRequest(fetchRequest: fetchRequest1) // Zażądanie by to usunąc
        _ = try? container.viewContext.execute(batchDeleteRequest1) // Wykonaj to żądanie
        
        let fetchRequest2: NSFetchRequest<NSFetchRequestResult> = Project.fetchRequest() // "Znajdź mi wszystkie 'Projects' sposród naszych danych
        let batchDeleteRequest2 = NSBatchDeleteRequest(fetchRequest: fetchRequest2) // Zażądanie by to usunąc
        _ = try? container.viewContext.execute(batchDeleteRequest2) // Wykonaj to żądanie
    }
}
