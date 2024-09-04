//
//  Goodworkouts_iosApp.swift
//  Goodworkouts-ios
//
//  Created by Elliott Rarden on 02.09.24.
//

import SwiftUI
import SwiftData

@main
struct Goodworkouts_iosApp: App {
    init() {
        Task { @MainActor in
            await APIManager.attemptToRestoreAuthState()
        }
    }
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Exercise.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
