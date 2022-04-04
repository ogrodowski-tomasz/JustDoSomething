//
//  UltimatePortoflioAppApp.swift
//  UltimatePortoflioApp
//
//  Created by Tomasz Ogrodowski on 30/03/2022.
//

import SwiftUI

@main
struct UltimatePortoflioAppApp: App {
    // Gdy nasza app się włączy, chcemy stworzyć nasz DataController i od razu ją wykorzystać, bo cała nasza aplikacja wykorzystuje stworzone CoreData
    @StateObject var dataController: DataController // StateObject ponieważ nasza app stworzy i będzie trzymać nasz dataController i zapewni, że będzie on alive przez cały czas
    
    // Potrzebujemy inicjatora by stworzyć ten dataController i umieścić go w StateObject
    init() {
        let dataController = DataController() // Tworzymy instancję DataControllera
        _dataController = StateObject(wrappedValue: dataController) // Wstawiamy 
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext) // To jest używa przez SwiftUI by sczytać wartości z CoreData
                .environmentObject(dataController) // To jest dla nas do używania wartości CoreData
        }
    }
}
