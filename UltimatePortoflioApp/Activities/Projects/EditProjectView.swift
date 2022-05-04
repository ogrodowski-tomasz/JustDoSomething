//
//  EditProjectView.swift
//  UltimatePortoflioApp
//
//  Created by Tomasz Ogrodowski on 06/04/2022.
//

import CoreHaptics
import SwiftUI

struct EditProjectView: View {
    @ObservedObject var project: Project

    @EnvironmentObject var dataController: DataController
    @Environment(\.presentationMode) var presetationMode

    @State private var title: String
    @State private var detail: String
    @State private var color: String
    @State private var showingDeleteConfirm = false

    // Setting up the haptic engine. It may fail so we use 'try?'
    @State private var engine = try? CHHapticEngine()

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
                Button(project.closed ? "Reopen this project" : "Close this project", action: toggleClosed)

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

    /// Manages haptic effect when the project is being closed
    func toggleClosed() {
        project.closed.toggle()
        if project.closed {
            // trigger haptic
            do {
                // starting haptic engine
                try engine?.start()
                // customizing parameters of the haptic event
                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0)
                let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
                // creatign a curve to immitate 'TaDa' effect
                // Start at time '0' with value '1'
                let start = CHHapticParameterCurve.ControlPoint(relativeTime: 0, value: 1)
                // End at time '1' with value '0' (it is relative time, not seconds)
                let end = CHHapticParameterCurve.ControlPoint(relativeTime: 1, value: 0)

                // This curve is applied to Intensity parameter with 2 control points at starting point 0
                let parameter = CHHapticParameterCurve(
                    parameterID: .hapticIntensityControl,
                    controlPoints: [start, end],
                    relativeTime: 0
                )
                // Creating a transient effect (first part of the pattern)
                let event1 = CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [sharpness, intensity],
                    relativeTime: 0 // start at 0 seconds
                )
                // Creating a continous effect (second part of the pattern)
                let event2 = CHHapticEvent(
                    eventType: .hapticContinuous,
                    parameters: [sharpness, intensity],
                    relativeTime: 0.125,
                    duration: 1
                )
                // Creating a pattern with events and curve between them
                let pattern = try CHHapticPattern(events: [event1, event2], parameterCurves: [parameter])
                let player = try? engine?.makePlayer(with: pattern)
                try player?.start(atTime: 0)
            } catch let error {
                print("Error playing haptics: \(error)")
            }
        }
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
