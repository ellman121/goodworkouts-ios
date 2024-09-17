//
//  AuthState.swift
//  Goodworkouts-ios
//
//  Created by Elliott Rarden on 02.09.24.
//

import Foundation

enum APIError: Error {
    case auth
    case noToken
    case badResponse
    case decodeError
    case unknownMethod
}

enum HTTPMethods: String {
    case GET = "GET"
    case POST = "POST"
}

struct LoginEndpointResponse: Decodable {
    let token: String
    let refreshToken: String
}

let BASE_URL = "http://localhost:2000"

@Observable class APIManager {
    var isLoading: Bool = false
    var authToken: String = ""
    private var refreshToken: String = ""
    
    static let shared = APIManager()
    
    private static let AuthTokenStorageKey = "auth_token"
    private static let RefreshTokenStorageKey = "refresh_token"
    
    static func attemptToLogin(withUsername u: String, andWithPassword p: String) {
        self.shared.isLoading = true
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
                self.shared.isLoading = false
                throw APIError.auth
            }
            
            if (resp.statusCode != 200) {
                self.shared.isLoading = false
                throw APIError.auth
            }
            
            let authData = try! JSONDecoder().decode(LoginEndpointResponse.self, from: data)
            self.shared.authToken = authData.token
            self.shared.refreshToken = authData.refreshToken
            
            UserDefaults.standard.setValue(authData.token, forKey: AuthTokenStorageKey)
            UserDefaults.standard.setValue(authData.refreshToken, forKey: RefreshTokenStorageKey)
            
            print("Successfully logged in as " + u)
            self.shared.isLoading = false
        }
    }
    
    static func attemptToRestoreAuthState() async {
        let token = UserDefaults.standard.value(forKey: AuthTokenStorageKey)
        guard let token = token as! String? else {
            self.shared.isLoading = false
            return
        }
        
        let refreshToken = UserDefaults.standard.value(forKey: RefreshTokenStorageKey)
        guard let refreshToken = refreshToken as! String? else {
            self.shared.isLoading = false
            return
        }
        
        self.shared.authToken = token
        self.shared.refreshToken = refreshToken
        await APIManager.attemptToReauthenticate()
    }
    
    static func doAuthorizedRequest(forURL url: URL, withMethod method: HTTPMethods = HTTPMethods.GET, usingData data: Data? = nil) async throws -> (Data, HTTPURLResponse) {
        let token = APIManager.shared.authToken
        if token == "" {
            throw APIError.noToken
        }
        
        var req = URLRequest(url: url)
        req.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.httpMethod = method.rawValue
        req.httpBody = data

        var (data, resp) = try await doRequest(req: req)
        if resp.statusCode == 401 {
            await APIManager.attemptToReauthenticate()
            (data, resp) = try await doRequest(req: req)
        }
        return (data, resp)
    }
    
    private static func doRequest(req: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let resp = resp as? HTTPURLResponse else { throw APIError.badResponse }
        return (data, resp)
    }
    
    private static func attemptToReauthenticate() async {
        self.shared.authToken = ""
        self.shared.isLoading = true
        
        do {
            var req = URLRequest(url: URL(string: "http://localhost:2000/reauthenticate")!)
            req.httpMethod = HTTPMethods.POST.rawValue
            req.httpBody = try! JSONSerialization.data(withJSONObject: [
                "refreshToken": APIManager.shared.refreshToken
            ])

            let (data, _) = try await doRequest(req: req)
            let authData = try! JSONDecoder().decode(LoginEndpointResponse.self, from: data)
            self.shared.authToken = authData.token
            self.shared.refreshToken = authData.refreshToken
            
            UserDefaults.standard.setValue(authData.token, forKey: AuthTokenStorageKey)
            print("Reauthenticated")
            self.shared.isLoading = false
        } catch {
            self.shared.isLoading = false
        }
    }
}
