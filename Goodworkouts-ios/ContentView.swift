//
//  ContentView.swift
//  Goodworkouts-ios
//
//  Created by Elliott Rarden on 02.09.24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        if (APIManager.shared.authToken == "") {
            LoginView()
        } else {
            TabView {
                Text("World")
                    .tabItem {
                        Label("Routines", systemImage: "list.clipboard")
                    }

                ExerciseList()
                    .tabItem {
                        Label("Exercieses", systemImage: "dumbbell")
                    }
                
                Text("Settings")
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
            }
        }
    }
}

#Preview {
    ContentView()
}
