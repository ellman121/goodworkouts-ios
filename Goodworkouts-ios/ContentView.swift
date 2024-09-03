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
        if (AuthState.shared.token == "") {
            LoginView()
        } else {
            TabView {
                ExerciseList()
                    .tabItem {
                        Label("Exercieses", systemImage: "dumbbell")
                    }
                
                Text("World")
                    .tabItem {
                        Label("Routines", systemImage: "list.clipboard")
                    }
                
                Text("GO")
                    .tabItem {
                        Label("GO", systemImage: "figure.run")
                    }
            }
        }
    }
}

#Preview {
    ContentView()
}
