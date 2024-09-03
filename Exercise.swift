//
//  Exercise.swift
//  Goodworkouts-ios
//
//  Created by Elliott Rarden on 03.09.24.
//

import Foundation
import SwiftData

struct ExerciseDTO: Codable {
    var id: String
    var name: String
    var userId: String
}

@Model
class Exercise {
    @Attribute(.unique) var id: String
    var name: String
    var userId: String
    
    init(id: String, name: String, userId: String) {
        self.id = id
        self.name = name
        self.userId = userId
    }
    
    convenience init(fromDTO e: ExerciseDTO) {
        self.init(id: e.id, name: e.name, userId: e.userId)
    }
    
    @MainActor
    static func fetchList(modelContext: ModelContext) async {
        do {
            try modelContext.delete(model: Exercise.self)
            let req = URLRequest(url: URL(string: "http://localhost:2000/exercises")!)
                
            let (data, _) = try await URLSession.shared.data(for: req)
            
            guard let decodedResp = try? JSONDecoder().decode([ExerciseDTO].self, from: data) else {
                throw APIError.decodeError
            }
            
            for itemToStore in decodedResp {
                modelContext.insert(Exercise(fromDTO: itemToStore))
            }
        } catch {
            print(error)
        }
    }
}
