//
//  ExerciseList.swift
//  Goodworkouts-ios
//
//  Created by Elliott Rarden on 03.09.24.
//

import SwiftUI
import SwiftData

struct ExerciseList: View {
    @Environment(\.modelContext) private var modelContext
    @Query var exercises: [Exercise]
    
    @State var isLoading: Bool = false
    @State var isRefreshing: Bool = false
    @State var showEditor: Bool = false
    
    @MainActor
    private func doFetch() async {
        self.isLoading = true
        await Exercise.fetchList(modelContext: self.modelContext)
        self.isLoading = false
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(exercises) { e in
                    Text(e.name)
                        .swipeActions {
                            Button("Delete", systemImage: "trash", role: .destructive) {
                                modelContext.delete(e)
                            }
                        }
                }
            }
                .shadow(radius: 4)
                .navigationTitle("Exercises")
                .sheet(isPresented: $showEditor) {
                    ExerciseEditor(exercise: nil)
                        .presentationDetents([.medium])
                }
                .overlay {
                    if isRefreshing {
                    } else if isLoading {
                        ProgressView()
                    } else if exercises.isEmpty {
                        Text("Nothing here :D")
                    }
                }
                .task {
                    await doFetch()
                }
                .refreshable {
                    self.isRefreshing = true
                    await doFetch()
                    self.isRefreshing = false
                }
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Add Exercise") {
                            showEditor = true
                        }
                    }
                }
        }
    }
}

#Preview {
    ExerciseList()
}
