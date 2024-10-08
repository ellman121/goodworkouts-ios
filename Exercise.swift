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

    static func createExercise(withName name: String) async -> Exercise? {
        do {
            let url = URL(string: "\(BASE_URL)/exercises")!
            let reqBody = try? JSONSerialization.data(withJSONObject: [
                "name": name
            ])
            
            let (d, _) = try await APIManager.doAuthorizedRequest(forURL: url, withMethod: .POST, usingData: reqBody)
            guard let decodedResp = try? JSONDecoder().decode(ExerciseDTO.self, from: d) else {
                throw APIError.decodeError
            }
            
            return Exercise(fromDTO: decodedResp)
        } catch {
            print(error)
        }
        return nil
    }
    
    @MainActor
    static func fetchList(modelContext: ModelContext) async {
        do {
            let url = URL(string: "\(BASE_URL)/exercises")!
            let (data, _) = try await APIManager.doAuthorizedRequest(forURL: url)
            guard let decodedResp = try? JSONDecoder().decode([ExerciseDTO].self, from: data) else {
                throw APIError.decodeError
            }
            
            try modelContext.delete(model: Exercise.self)
            for itemToStore in decodedResp {
                modelContext.insert(Exercise(fromDTO: itemToStore))
            }
        } catch {
            print(error)
        }
    }
}
