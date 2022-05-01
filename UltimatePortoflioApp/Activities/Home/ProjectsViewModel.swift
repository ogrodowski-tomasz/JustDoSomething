//
//  ProjectsViewModel.swift
//  UltimatePortfolioApp
//
//  Created by Tomasz Ogrodowski on 01/05/2022.
//

import CoreData
import Foundation
import SwiftUI

// Designing patterns:
// MVVM - Model-View-ViewModel
// MVC - Model-View-Controller

// Placing ViewModel as an extension in order to
// use it without any complex name, just simply ViewModel
// It's a nested Type inside the View Struct
extension ProjectsView {
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
        let dataController: DataController

        var sortOrder = Item.SortOrder.optimized
        let showClosedProjects: Bool

        private let projectsController: NSFetchedResultsController<Project>
        @Published var projects = [Project]()

        /// Initializer that lets us choose if we want
        /// to show open or closed projects
        /// - Parameter showClosedProjects: Whether to show open or close project
        init(dataController: DataController, showClosedProjects: Bool) {
            self.dataController = dataController
            self.showClosedProjects = showClosedProjects

            let request: NSFetchRequest<Project> = Project.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Project.creationDay, ascending: false)]
            request.predicate = NSPredicate(format: "closed = %d", showClosedProjects)

            projectsController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: dataController.container.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )

            // tell US when data changes somehow. We are the delegates.
            // It requires some protocols to be completed.
            super.init() // we cannot use self before initing NSObject and letting it doing its own work.
            projectsController.delegate = self

            do {
                try projectsController.performFetch()
                projects = projectsController.fetchedObjects ?? []
            } catch let error {
                print("Failed to fetch projects: \(error)")
            }
        }

        func addProject() {
            let project = Project(context: dataController.container.viewContext)
            project.closed = false
            project.creationDay = Date()
            dataController.save()
        }

        func addItem(to project: Project) {
            let item = Item(context: dataController.container.viewContext)
            item.project = project
            item.creationDate = Date()
            dataController.save()
        }

        func delete(_ offsets: IndexSet, from project: Project) {
            // dzięki temu w pętli nie będzie wykonywało się ciągle tworzenie nowej, posortowanej tablicy Itemów
            let allItems = project.projectItems(using: sortOrder)

            for offset in offsets {
                let item = allItems[offset]
                dataController.delete(item)
            }
            dataController.save()
        }

        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            if let newProjects = controller.fetchedObjects as? [Project] {
                projects = newProjects
            }
        }
    }
}
