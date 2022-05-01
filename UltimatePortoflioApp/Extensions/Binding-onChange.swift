//
//  Binding-onChange.swift
//  UltimatePortoflioApp
//
//  Created by Tomasz Ogrodowski on 06/04/2022.
//

import SwiftUI

/// Extension on Binding property wrapper created to let the Core Data be updated,
/// whenever some  item or project property is changed
extension Binding {

    /// After setting a new value perform certain method that accepts no parameters and returns nothing
    /// - Parameter handler: Given method that accepts no parameters and returns nothing
    /// - Returns: Binding some given value
    func onChange(_ handler: @escaping () -> Void) -> Binding<Value> {
        Binding {
            self.wrappedValue
        } set: { newValue in
            self.wrappedValue = newValue
            handler()
        }

    }
}
