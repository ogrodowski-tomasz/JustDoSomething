//
//  SelectSomethingView.swift
//  UltimatePortfolioApp
//
//  Created by Tomasz Ogrodowski on 07/04/2022.
//
// swiftlint:disable trailing_whitespace

import SwiftUI

struct SelectSomethingView: View {
    var body: some View {
        Text("Please select something form the menu to begin.")
            .italic()
            .foregroundColor(.secondary)
    }
}

struct SelectSomethingView_Previews: PreviewProvider {
    static var previews: some View {
        SelectSomethingView()
    }
}
