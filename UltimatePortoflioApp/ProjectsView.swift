//
//  ProjectsView.swift
//  UltimatePortoflioApp
//
//  Created by Tomasz Ogrodowski on 04/04/2022.
//

import SwiftUI

struct ProjectsView: View {
    // Ten widok ma pokazywać 'Projects' parametrycznie w zależności od tego czy są otwarte czy zamknięte
    let showClosedProjects: Bool
    // Nie możemy wykonać typowego żądania fetchu dopóki nie wiemy konkretnie czrgo szukamy (open czy closed project?)
    let projects: FetchRequest<Project>
    
    init(showClosedProjects: Bool) {
        self.showClosedProjects = showClosedProjects
        
        projects = FetchRequest<Project>(
            entity: Project.entity(),
            sortDescriptors: [
                NSSortDescriptor(keyPath: \Project.creationDay, ascending: false) // sorting method by the creationDate
        ], predicate: NSPredicate(format: "closed = %d", showClosedProjects)) // %d oznacza placeholder. Gdy ruszymy program to będzie to oznaczało closed = true lub closed = false w zaleznosci od wartości showClosedPRojects
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(projects.wrappedValue) { project in
                    Section(header: Text(project.projectTitle)) {
                        ForEach(project.projectItems) { item in
                            Text(item.itemTitle)
                        }
                    }
                }
            }
            .listStyle(InsetListStyle())
            .navigationTitle(showClosedProjects ? "Closed projects" : "Open projects")
        }
    }
}

struct ProjectsView_Previews: PreviewProvider {
    
    static var dataController = DataController.preview
    
    static var previews: some View {
        ProjectsView(showClosedProjects: false)
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environmentObject(dataController)
    }
}
