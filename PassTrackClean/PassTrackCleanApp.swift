//
//  PassTrackCleanApp.swift
//  PassTrackClean
//
//  Created by Tyler Roukey on 1/8/26.
//

import SwiftUI
import SwiftData

@main
struct PassTrackCleanApp: App {
    // SwiftData container
    let modelContainer: ModelContainer
    
    init() {
        do {
            // Configure SwiftData schema
            let schema = Schema([
                Team.self,
                Player.self,
                Session.self,
                Rally.self
            ])
            
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )
            
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(modelContainer)
        }
    }
}
