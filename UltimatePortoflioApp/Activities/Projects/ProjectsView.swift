//
//  ProjectsView.swift
//  UltimatePortoflioApp
//
//  Created by Tomasz Ogrodowski on 04/04/2022.
//
// swiftlint:disable trailing_whitespace

import SwiftUI

/// View that shows projects that are opened or closed.
struct ProjectsView: View {
    @StateObject var viewModel: ViewModel

    static let openTag: String? = "Open"
    static let closedTag: String? = "Closed"

    @State private var  showingSortOrder = false

    init(dataController: DataController, showClosedProjects: Bool) {
        let viewModel = ViewModel(dataController: dataController, showClosedProjects: showClosedProjects)
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    /// View that shows all projects (based on 'open' parameter)
    /// with their items
    ///
    /// View also lets us add new item to certain open project
    var projectsList: some View {
        List {
            ForEach(viewModel.projects) { project in
                Section(header: ProjectHeaderView(project: project)) {
                    ForEach(project.projectItems(using: viewModel.sortOrder)) { item in
                        ItemRowView(project: project, item: item)
                    }
                    .onDelete { offsets in
                        viewModel.delete(offsets, from: project)
                    }
                    
                    if viewModel.showClosedProjects == false {
                        Button {
                            viewModel.addItem(to: project)
                        } label: {
                            Label("Add New Item", systemImage: "plus")
                        }
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
    
    /// Toolbar button letting user add new project
    var addProjectToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            if viewModel.showClosedProjects == false {
                Button {
                    withAnimation {
                        viewModel.addProject()
                    }
                } label: {
                    Label("Add Project", systemImage: "plus")
                }

            }
        }
    }
    
    /// Toolbar button letting user choose custom sorting order
    var sortOrderToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                showingSortOrder.toggle()
            } label: {
                Label("Sort", systemImage: "arrow.up.arrow.down")
            }
        }
    }
    
    /// View that shows all projects basing on its 'Open' property
    ///
    /// If there are no projects to shown, app will show message
    var body: some View {
        NavigationView {
            Group {
                if viewModel.projects.isEmpty {
                    Text("There are no projects yet to be shown!")
                        .foregroundColor(.secondary)
                } else {
                    projectsList
                }
            }
            .navigationTitle(viewModel.showClosedProjects ? "Closed Projects" : "Open Projects")
            .toolbar {
                addProjectToolbarItem
                sortOrderToolbarItem
            }
            .actionSheet(isPresented: $showingSortOrder) {
                ActionSheet(title: Text("Sort items"), message: nil, buttons: [
                    .default(Text("Optimized")) { viewModel.sortOrder = .optimized },
                    .default(Text("Creation Date")) { viewModel.sortOrder = .creationDate },
                    .default(Text("Title")) { viewModel.sortOrder = .title }
                ])
            }
            
            SelectSomethingView()
        }
    }

}

struct ProjectsView_Previews: PreviewProvider {
    
    static var dataController = DataController.preview
    
    static var previews: some View {
        ProjectsView(dataController: DataController.preview, showClosedProjects: false)
    }
}
