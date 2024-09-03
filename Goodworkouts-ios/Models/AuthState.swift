//
//  AuthState.swift
//  Goodworkouts-ios
//
//  Created by Elliott Rarden on 02.09.24.
//

import Foundation

enum APIError: Error {
    case auth
    case badResponse
    case decodeError
}

struct LoginEndpointResponse: Decodable {
    let token: String
}

let PersistentStorageKey = "auth_token"

@Observable class AuthState {
    var isLoading: Bool = false
    var token: String = ""
    
    static let shared = AuthState()
    
    func attemptToLogin(withUsername u: String, andWithPassword p: String) {
        self.isLoading = true
        Task { @MainActor in
            var req = URLRequest(url: URL(string: "http://localhost:2000/login")!)
            req.httpMethod = "POST"
            
            let loginData = [
                "username": u,
                "password": p
            ]
            let reqBody = try? JSONSerialization.data(withJSONObject: loginData)
            
            let (data, resp) = try await URLSession.shared.upload(for: req, from: reqBody!)
            guard let resp = resp as? HTTPURLResponse else {
                self.isLoading = false
                throw APIError.auth
            }
            
            if (resp.statusCode != 200) {
                self.isLoading = false
                throw APIError.auth
            }
            
            let authData = try! JSONDecoder().decode(LoginEndpointResponse.self, from: data)
            self.token = String(authData.token)
            
            UserDefaults.standard.setValue(authData.token, forKey: PersistentStorageKey)
            
            print("Successfully logged in as " + u)
            self.isLoading = false
        }
    }
    
    func attemptToRestoreAuthState() {
        self.isLoading = true
        
        let t = UserDefaults.standard.value(forKey: PersistentStorageKey)
        guard let t = t as! String? else {
            self.isLoading = false
            return
        }
        
        print("Resored token " + t)
        self.token = t
        self.isLoading = false
    }
}
