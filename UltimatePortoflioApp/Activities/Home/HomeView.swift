//
//  HomeView.swift
//  UltimatePortoflioApp
//
//  Created by Tomasz Ogrodowski on 04/04/2022.
//
// swiftlint:disable trailing_whitespace

import CoreData
import SwiftUI

struct HomeView: View {
    static let tag: String? = "Home"

    @StateObject var viewModel: ViewModel

    init(dataController: DataController) {
        let viewModel = ViewModel(dataController: dataController)
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var projectRows: [GridItem] {
        [GridItem(.fixed(100))]
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(rows: projectRows) {
                            ForEach(viewModel.projects, content: ProjectSummaryView.init)
                        }
                        .padding([.horizontal, .top])
                        .fixedSize(horizontal: false, vertical: true)
                    }
                    VStack(alignment: .leading) {
                        ItemListView(title: "Up next", items: viewModel.upNext)
                        ItemListView(title: "More to explore", items: viewModel.moreToExplore)
                    }
                    .padding(.horizontal)
                }
            }
            .background(Color.systemGroupedBackground.ignoresSafeArea())
            .navigationTitle("Home")
            .toolbar {
                Button("Add Data", action: viewModel.addSampleData)
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(dataController: .preview)
    }
}
