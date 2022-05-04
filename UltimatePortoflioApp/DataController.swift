//
//  DataController.swift
//  UltimatePortoflioApp
//
//  Created by Tomasz Ogrodowski on 30/03/2022.
//

import CoreData
import CoreSpotlight
import SwiftUI
import UserNotifications

/// An environment singleton responsible for managing out Core Data stack, including handling saving,
/// counting fetch requests, tracking awards and dealing with sample data.
class DataController: ObservableObject {
    /// The lone CloudKit container used to store all our data
    let container: NSPersistentCloudKitContainer

    /// Initializes a data controller, either in memory (for temporary use such as testing and previewing),
    /// or on permanent storage (for use in regular app runs.)
    ///
    /// Defaults to permanent storage.
    /// - Parameter inMemory: Whether to store this data in temporary memory or not.
        init(inMemory: Bool = false) {
            container = NSPersistentCloudKitContainer(name: "Main", managedObjectModel: Self.model)
            // "I've seen this model before. I will look for it in cache"

            // For testing and previewing purposes, we create a temporary,
            // in-memory database by writing to /dev/null so our data is
            // destroyed after the app finishes running.
            if inMemory {
                container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
            }
            container.loadPersistentStores { _, error in
                if let error = error {
                    fatalError("Fatal error loading store: \(error.localizedDescription)")
                }

                // Checking if we're in debugging and then chechking if the launch argument contains
                // a value thta triggers the testing mode. If yes - wipe everything out
                #if DEBUG
                if CommandLine.arguments.contains("enable-testing") {
                    self.deleteAll()
                    UIView.setAnimationsEnabled(false)
                }
                #endif
            }
        }

    static var preview: DataController = {
        let dataController = DataController(inMemory: true)

        do {
            try dataController.createSampleData()
        } catch {
            fatalError("Creating preview error: \(error.localizedDescription)")
        }
        return dataController
    }()

    /// Both tests and app itself creates an instance of DataController.
    /// So when the deleting method is called swift doesn't know which one you mention.
    /// It will load the model data ONCE (that's why it's static) and store it in cache
    /// for other people to use.
    static let model: NSManagedObjectModel = {
        guard let url = Bundle.main.url(forResource: "Main", withExtension: "momd") else {
            fatalError("Failed to locate model file.")
        }
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Failed to load model file.")
        }
        return managedObjectModel
    }() // do it once and cache it for using it
        // later on. We want NSClKtCont to use that.

    /// Creates example projects and items to make manual testing easier.
    ///  - Throws: An NSError sent from calling save() on the NSManagedObjectContext.
    func createSampleData() throws {
        let viewContext = container.viewContext

        for projectCounter in 1...5 {
            let project = Project(context: viewContext)
            project.title = "Project \(projectCounter)"
            project.items = []
            project.creationDay = Date()
            project.closed = Bool.random()

            for itemCounter in 1...10 {
                let item = Item(context: viewContext)
                item.title = "Item \(itemCounter)"
                item.creationDate = Date()
                item.completed = Bool.random()
                item.project = project
                item.priority = Int16.random(in: 1...3)
            }
        }
        try viewContext.save()
    }

    /// Saves out Core Data context only if there are changes. This silently ignores
    /// any errors caused by saving. Don't mention it because
    /// our attributes are optional.
    func save() {
        if container.viewContext.hasChanges {
            try? container.viewContext.save()
        }
    }

    /// Deletes an given object from our Core Data and from Spotlight set.
    /// - Parameter object: an object from our Core Data and Spotlight Set
    func delete(_ object: NSManagedObject) {

        let id = object.objectID.uriRepresentation().absoluteString

        if object is Item {
            CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [id])
        } else {
            CSSearchableIndex.default().deleteSearchableItems(withDomainIdentifiers: [id])
        }

        container.viewContext.delete(object)
    }

    func deleteAll() {
        let fetchRequest1: NSFetchRequest<NSFetchRequestResult> = Item.fetchRequest()
        let batchDeleteRequest1 = NSBatchDeleteRequest(fetchRequest: fetchRequest1)
        _ = try? container.viewContext.execute(batchDeleteRequest1)

        let fetchRequest2: NSFetchRequest<NSFetchRequestResult> = Project.fetchRequest()
        let batchDeleteRequest2 = NSBatchDeleteRequest(fetchRequest: fetchRequest2)
        _ = try? container.viewContext.execute(batchDeleteRequest2)
    }

    /// Counting how many units of data is in our Core Data
    /// - Parameter fetchRequest: request of fetching some kind of type from Core Data
    /// - Returns: number of items in given fetch request
    func count<T>(for fetchRequest: NSFetchRequest<T>) -> Int {
        (try? container.viewContext.count(for: fetchRequest)) ?? 0
    }

    func hasEarned(award: Award) -> Bool {
        switch award.criterion {
        case "items":
            // Returns true if user added a certain number of items
            let fetchRequest: NSFetchRequest<Item> = NSFetchRequest(entityName: "Item")
            let awardCount = count(for: fetchRequest)
            return awardCount >= award.value
        case "complete":
            // Returns true if user completed a certain number of items
            let fetchRequest: NSFetchRequest<Item> = NSFetchRequest(entityName: "Item")
            fetchRequest.predicate = NSPredicate(format: "completed = true")
            let awardCount = count(for: fetchRequest)
            return awardCount >= award.value
        default:
            // an unknown award criterion; this should never be allowed
       //     fatalError("Unknown award criterion: \(award.criterion)")
            return false
        }
    }

    /// Updating item in Spotlight
    ///
    ///  Method is given 1 item to work with. This method is going to write all of the item's information to Spotlight.
    ///  And then save, to update CoreData as well.
    func update(_ item: Item) {
        /// This method takes 4 steps:
        /// 1. Creating unique IDs which should be STABLE [ shouldn't change over time (UUID can change over time)]
        let itemID = item.objectID.uriRepresentation().absoluteString // absolute string id of item
        let projectID = item.project?.objectID.uriRepresentation().absoluteString // uir is for archiving purposes
        /// 2. Deciding what attributes we want to stick into CoreSpotlight
        let attributeSet = CSSearchableItemAttributeSet(contentType: .text)
        attributeSet.title = item.itemTitle
        attributeSet.contentDescription = item.itemDetail
        /// 3. Wrapping up the ID and Attributes in one Spotlight record.
        /// Passing also DomainID (responsible for grouping things together - f.ex. Project's ID)
        let searchableItem = CSSearchableItem(
            uniqueIdentifier: itemID,
            domainIdentifier: projectID,
            attributeSet: attributeSet
        )
        /// 4. Sending this to Spotlight for indexing
        CSSearchableIndex.default().indexSearchableItems([searchableItem])
        /// 5. Updating CoreData
        save()
    }

    func item(with uniqueIdentifier: String) -> Item? {
        guard let url = URL(string: uniqueIdentifier) else {
            print("Cannot read URL")
            return nil
        }

        guard let id = container.persistentStoreCoordinator.managedObjectID(forURIRepresentation: url) else {
            return nil
        }

        return try? container.viewContext.existingObject(with: id) as? Item
    }

    func addReminders(for project: Project, completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestNotifications { success in
                    if success { self.placeReminders(for: project, completion: completion)
                    } else {
                        DispatchQueue.main.async {
                            completion(false)
                        }
                    }
                }
            case .authorized:
                self.placeReminders(for: project, completion: completion)
            default:
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }

    /// Removing reminders that are waiting to be alerted in the future
    func removeReminders(for project: Project) {
        let center = UNUserNotificationCenter.current()
        let id = project.objectID.uriRepresentation().absoluteString

        center.removePendingNotificationRequests(withIdentifiers: [id])
    }

    /// Asking iOS if app can show notifications.
    ///
    /// Telling system that app want to show notifications and defines what types of notifications.
    /// Completion: What the app will do if the user authorize the notifications
    private func requestNotifications(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            completion(granted)
        }
    }

    private func placeReminders(for project: Project, completion: @escaping (Bool) -> Void) {
        /// 1. Content of the alert (what to show)
        let content = UNMutableNotificationContent()
        content.title = project.projectTitle
        content.sound = .default

        if let projectDetail = project.detail {
            content.subtitle = projectDetail
        }
        /// 2. Trigger of the notification (when to show it)
        let components = Calendar.current.dateComponents(
            [.hour, .minute],
            from: project.reminderTime ?? Date()
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        /// 3. Wrapping content and trigger into a single notification with specified ID.
        let id = project.objectID.uriRepresentation().absoluteString
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        /// 4. Sending request to system
        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                if error == nil {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
}
