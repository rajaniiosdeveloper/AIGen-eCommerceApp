//
//  SignInInteractor.swift
//  EnterpriseApp
//
//  Created by AI Assistant
//

import Foundation

// MARK: - Sign In Interactor Protocol
protocol SignInInteractorProtocol {
    func signIn(email: String, password: String) async throws
    func register(name: String, email: String, password: String) async throws
}

// MARK: - Sign In Interactor Implementation
class SignInInteractor: SignInInteractorProtocol {
    private let authManager: AuthenticationManagerProtocol
    
    init(authManager: AuthenticationManagerProtocol = AuthenticationManager.shared) {
        self.authManager = authManager
    }
    
    func signIn(email: String, password: String) async throws {
        try await authManager.signIn(email: email, password: password)
    }
    
    func register(name: String, email: String, password: String) async throws {
        try await authManager.register(name: name, email: email, password: password)
    }
}