//
//  ItemRowView.swift
//  UltimatePortoflioApp
//
//  Created by Tomasz Ogrodowski on 06/04/2022.
//

import SwiftUI

struct ItemRowView: View {
    
    @ObservedObject var project: Project
    @ObservedObject var item: Item
    // ObservedObject and stateObject both watch at class that conforms to ObservableObject protocol.
    // StateObject created it and keeps it alive
    // ObservedObject means someone else owns this. I'm being passed this and i want to watch it. We are not creating it (StateObject does), we just watch it
    
    var icon: some View {
        if item.completed {
            return Image(systemName: "checkmark.circle")
                .foregroundColor(Color(project.projectColor))
        } else if item.priority == 3 {
            return Image(systemName: "exclamationmark.triangle")
                .foregroundColor(Color(project.projectColor))
        } else {
            return Image(systemName: "checkmark.circle")
                .foregroundColor(.clear)
        }
        // Two questions:
        // 1. Why using .clear Image if priority is not == 3?
        // We could have returned nothing there. "If it doesnt match anything, send nothing and we are done", but we want to place this systemImage in a label. If there were no icon, text label would be on the leading edge, it wouldnt be inline with item with priority of 3 etc.
        // 2. Why is this a computed property instead of method?
        // We could have used method, it would be fine. Using computed property matches the way we created the body property. It is the same thing, it looks the same. Both of them use some structure inside there, no fancy complex logic, just some view structure.
    }
    
    var body: some View {
        NavigationLink(destination: EditItemView(item: item)) {
            Label {
                Text(item.itemTitle)
            } icon: {
                icon
            }
        }
    }
}

struct ItemRowView_Previews: PreviewProvider {
    static var previews: some View {
        ItemRowView(project: Project.example, item: Item.example)
    }
}
