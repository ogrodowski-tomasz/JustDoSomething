//
//  ItemRowView.swift
//  UltimatePortoflioApp
//
//  Created by Tomasz Ogrodowski on 06/04/2022.
//

import SwiftUI

struct ItemRowView: View {
    
    @ObservedObject var item: Item
    // ObservedObject and stateObject both watch at class that conforms to ObservableObject protocol.
    // StateObject created it and keeps it alive
    // ObservedObject means someone else owns this. I'm being passed this and i want to watch it. We are not creating it (StateObject does), we just watch it
    
    var body: some View {
        NavigationLink(destination: EditItemView(item: item)) {
            Text(item.itemTitle)
        }
    }
}

struct ItemRowView_Previews: PreviewProvider {
    static var previews: some View {
        ItemRowView(item: Item.example)
    }
}
