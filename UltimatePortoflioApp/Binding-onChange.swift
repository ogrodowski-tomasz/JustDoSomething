//
//  Binding-onChange.swift
//  UltimatePortoflioApp
//
//  Created by Tomasz Ogrodowski on 06/04/2022.
//

import SwiftUI

extension Binding {
    func onChange(_ handler: @escaping () -> Void) -> Binding<Value> {
        Binding {
            self.wrappedValue
        } set: { newValue in
            self.wrappedValue = newValue
            handler()
        }

    }
}
