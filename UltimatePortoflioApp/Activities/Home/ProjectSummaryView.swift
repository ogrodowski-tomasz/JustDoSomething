//
//  ProjectSummaryView.swift
//  UltimatePortfolioApp
//
//  Created by Tomasz Ogrodowski on 10/04/2022.
//

import SwiftUI

/// View used on HomeView that shows a summary of certain project
struct ProjectSummaryView: View {

    @ObservedObject var project: Project

    var body: some View {
        VStack(alignment: .leading) {
            Text("\(project.projectItems.count) items")
                .font(.caption)
                .foregroundColor(.secondary)
            Text(project.projectTitle)
                .font(.title2)
            ProgressView(value: project.completionAmount)
                .accentColor(Color(project.projectColor))
        }
        .padding()
        .background(Color.secondarySystemGroupedBackground)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.2), radius: 5)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(project.label)
    }
}
