//
//  AuthenticationManager.swift
//  EnterpriseApp
//
//  Created by AI Assistant
//

import Foundation
import Combine

// MARK: - Authentication Manager Protocol
protocol AuthenticationManagerProtocol: ObservableObject {
    var isAuthenticated: Bool { get }
    var currentUser: User? { get }
    var authToken: String? { get }
    
    func signIn(email: String, password: String) async throws
    func register(name: String, email: String, password: String) async throws
    func signOut()
    func refreshTokenIfNeeded() async throws
}

// MARK: - Authentication Manager Implementation
class AuthenticationManager: AuthenticationManagerProtocol, ObservableObject {
    static let shared = AuthenticationManager()
    
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User?
    @Published var authToken: String?
    
    private let networkService: NetworkServiceProtocol
    private let userDefaults = UserDefaults.standard
    
    // UserDefaults Keys
    private enum Keys {
        static let authToken = "auth_token"
        static let refreshToken = "refresh_token"
        static let currentUser = "current_user"
        static let tokenExpiry = "token_expiry"
    }
    
    private init(networkService: NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
        loadAuthenticationState()
    }
    
    // MARK: - Authentication Methods
    func signIn(email: String, password: String) async throws {
        let authResponse = try await networkService.signIn(email: email, password: password)
        await handleAuthenticationSuccess(authResponse)
    }
    
    func register(name: String, email: String, password: String) async throws {
        let authResponse = try await networkService.register(name: name, email: email, password: password)
        await handleAuthenticationSuccess(authResponse)
    }
    
    func signOut() {
        DispatchQueue.main.async {
            self.isAuthenticated = false
            self.currentUser = nil
            self.authToken = nil
        }
        
        // Clear stored data
        userDefaults.removeObject(forKey: Keys.authToken)
        userDefaults.removeObject(forKey: Keys.refreshToken)
        userDefaults.removeObject(forKey: Keys.currentUser)
        userDefaults.removeObject(forKey: Keys.tokenExpiry)
    }
    
    func refreshTokenIfNeeded() async throws {
        guard let refreshToken = userDefaults.string(forKey: Keys.refreshToken),
              let expiryDate = userDefaults.object(forKey: Keys.tokenExpiry) as? Date,
              Date() > expiryDate else {
            return
        }
        
        let authResponse = try await networkService.refreshToken(refreshToken)
        await handleAuthenticationSuccess(authResponse)
    }
    
    // MARK: - Private Methods
    @MainActor
    private func handleAuthenticationSuccess(_ authResponse: AuthResponse) {
        self.isAuthenticated = true
        self.currentUser = authResponse.user
        self.authToken = authResponse.token
        
        // Store in UserDefaults
        userDefaults.set(authResponse.token, forKey: Keys.authToken)
        if let refreshToken = authResponse.refreshToken {
            userDefaults.set(refreshToken, forKey: Keys.refreshToken)
        }
        
        // Calculate and store expiry date
        let expiryDate = Date().addingTimeInterval(TimeInterval(authResponse.expiresIn))
        userDefaults.set(expiryDate, forKey: Keys.tokenExpiry)
        
        // Store user data
        if let userData = try? JSONEncoder().encode(authResponse.user) {
            userDefaults.set(userData, forKey: Keys.currentUser)
        }
    }
    
    private func loadAuthenticationState() {
        guard let token = userDefaults.string(forKey: Keys.authToken),
              let userData = userDefaults.data(forKey: Keys.currentUser),
              let user = try? JSONDecoder().decode(User.self, from: userData),
              let expiryDate = userDefaults.object(forKey: Keys.tokenExpiry) as? Date,
              Date() < expiryDate else {
            return
        }
        
        DispatchQueue.main.async {
            self.isAuthenticated = true
            self.currentUser = user
            self.authToken = token
        }
    }
}