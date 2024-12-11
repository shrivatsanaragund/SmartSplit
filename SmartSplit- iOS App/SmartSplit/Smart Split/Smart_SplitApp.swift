//
//  Smart_SplitApp.swift
//  Smart Split
//
//  Created by Shrivatsa Naragund on 11/19/24.
//

import SwiftUI

@main
struct Smart_SplitApp: App {
    // The persistence controller to manage Core Data
    let persistenceController = PersistenceController.shared
    
    // Create an instance of UserData to manage the current logged-in user
    @StateObject private var userData = UserData() // User data observable object

    var body: some Scene {
        WindowGroup {
            AppView() // Use AppView instead of ContentView
            
                // Inject the environment objects into the view
                .environmentObject(userData) // Inject UserData object to the environment
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
