//
//  EditProjectView.swift
//  UltimatePortoflioApp
//
//  Created by Tomasz Ogrodowski on 06/04/2022.
//
// swiftlint:disable trailing_whitespace

import SwiftUI

struct EditProjectView: View {
    let project: Project
    
    @EnvironmentObject var dataController: DataController
    @Environment(\.presentationMode) var presetationMode
    
    @State private var title: String
    @State private var detail: String
    @State private var color: String
    
    @State private var showingDeleteConfirm = false
    
    let colorColumns = [
        GridItem(.adaptive(minimum: 44))
    ]
    
    /// Initializing project that user selected and preparing it to edit
    /// - Parameter project: selected project
    init(project: Project) {
        self.project = project
        
        _title = State(wrappedValue: project.projectTitle)
        _detail = State(wrappedValue: project.projectDetail)
        _color = State(wrappedValue: project.projectColor)
    }
    
    var body: some View {
        Form {
            Section(header: Text("Basic settings")) {
                TextField("Project name", text: $title.onChange(update))
                TextField("Description of this project", text: $detail.onChange(update))
            }
            
            Section(header: Text("Custom project color")) {
                LazyVGrid(columns: colorColumns) {
                    ForEach(Project.colors, id: \.self, content: colorButton)
                }
                .padding(.vertical)
            }
            // swiftlint:disable:next line_length
            Section(footer: Text("Closing a project moves it from the Open to Closed tab; deleting it removes the project entirely.")) {
                Button(project.closed ? "Reopen this project" : "Close this project") {
                    project.closed.toggle()
                    update()
                }
                Button("Delete this project") {
                    showingDeleteConfirm.toggle()
                }
                .accentColor(Color(red: 1.0, green: 0.0, blue: 0.0))
            }
            
        }
        .navigationTitle("Edit Project")
        .onDisappear(perform: dataController.save)
        .alert(isPresented: $showingDeleteConfirm) {
            Alert(
                title: Text("Delete project?"),
                // swiftlint:disable:next line_length
                message: Text("Are you sure you want to delete this project? You will also delete all the items it contains"),
                primaryButton: .default(Text("Delete"), action: delete),
                secondaryButton: .cancel())
        }
    }
    
    /// Updates Core Data with edited properties
    func update() {
        project.title = title
        project.detail = detail
        project.color = color
    }
    
    /// Deletes entire project and its items. After that the view is dismissed
    func delete() {
        dataController.delete(project)
        presetationMode.wrappedValue.dismiss()
    }
    
    ///  View that show a square filled with given color
    /// - Parameter item: Name of color
    /// - Returns: Square filled with given color and optionally with checkmark on a selected one 
    func colorButton(for item: String) -> some View {
        ZStack {
            Color(item)
                .aspectRatio(1, contentMode: .fit)
                .cornerRadius(6)
            
            if item == color {
                Image(systemName: "checkmark.circle")
                    .foregroundColor(Color(red: 1.0, green: 1.0, blue: 1.0))
                    .font(.largeTitle)
            }
        }
        .onTapGesture {
            color = item
            update()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(
            item == color
            ? [.isButton, .isSelected]
            : .isButton
        )
        .accessibilityLabel(LocalizedStringKey(item))
    }
}

struct EditProjectView_Previews: PreviewProvider {
    static var previews: some View {
        EditProjectView(project: Project.example)
    }
}