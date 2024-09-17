//
//  ExerciseEditor.swift
//  Goodworkouts-ios
//
//  Created by Elliott Rarden on 17.09.24.
//

import SwiftUI

struct ExerciseEditor: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let exercise: Exercise?
    @State private var name = ""
    @State private var isSaving = false
    
    private var editorTitle: String {
        exercise == nil ? "Add exercise" : "Edit exercise"
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Exercise Name", text: $name)
                        .disabled(isSaving)
                    
                } header: {
                    Text(editorTitle)
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(editorTitle)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await save()
                            dismiss()
                        }
                    }.disabled(name == "")
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
            }
            .scrollDisabled(true)
            .onAppear {
                if let exercise {
                    name = exercise.name
                }
            }
        }
    }
    
    private func save() async {
        isSaving = true
        if let exercise {
            exercise.name = name
            isSaving = false
            dismiss()
        } else {
            let newExercise = await Exercise.createExercise(withName: name)
            if newExercise != nil {
                modelContext.insert(newExercise!)
            }
            isSaving = false
            dismiss()
        }
    }
}
