//
//  UltimatePortoflioAppApp.swift
//  UltimatePortoflioApp
//
//  Created by Tomasz Ogrodowski on 30/03/2022.
//
// swiftlint:disable trailing_whitespace

import SwiftUI

@main
struct UltimatePortoflioAppApp: App {
    @StateObject var dataController: DataController
    
    init() {
        let dataController = DataController()
        _dataController = StateObject(wrappedValue: dataController) // Wstawiamy 
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(dataController)
                .onReceive(
                    NotificationCenter.default.publisher(for:
                    UIApplication.willResignActiveNotification),
                    perform: save
                )
        }
    }
    
    func save(_ note: Notification) {
        dataController.save()
    }
}
