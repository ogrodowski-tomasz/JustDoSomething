//
//  ItemListView.swift
//  UltimatePortfolioApp
//
//  Created by Tomasz Ogrodowski on 10/04/2022.
//

import SwiftUI

/// View shown on HomeView with links to editing an item.
///
/// View is used on HomeView to show items with high priority.
/// Contains an Circle stroke with project color and
/// basic information about item
struct ItemListView: View {

    let title: LocalizedStringKey
    let items: ArraySlice<Item>

    var itemList: some View {
        ForEach(items) { item in
            NavigationLink(destination: EditItemView(item: item)) {
                HStack(spacing: 20) {
                    Circle()
                        .stroke(Color(item.project?.projectColor ?? "Light Blue"), lineWidth: 3)
                        .frame(width: 44, height: 44)

                    VStack(alignment: .leading) {
                        Text(item.itemTitle)
                            .font(.title2)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        if item.itemDetail.isEmpty == false {
                            Text(item.itemDetail)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color.secondarySystemGroupedBackground)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.2), radius: 5)
            }
        }
    }

    var body: some View {
        if items.isEmpty {
            EmptyView()
        } else {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.top)

            itemList
        }
    }
}
