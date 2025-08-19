//
//  OrderHistoryInteractor.swift
//  EnterpriseApp
//
//  Created by AI Assistant
//

import Foundation

// MARK: - Order History Interactor Protocol
protocol OrderHistoryInteractorProtocol {
    func fetchOrders() async throws -> [Order]
}

// MARK: - Order History Interactor Implementation
class OrderHistoryInteractor: OrderHistoryInteractorProtocol {
    private let networkService: NetworkServiceProtocol
    private let authManager: any AuthenticationManagerProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService.shared,
         authManager: any AuthenticationManagerProtocol = AuthenticationManager.shared) {
        self.networkService = networkService
        self.authManager = authManager
    }
    
    func fetchOrders() async throws -> [Order] {
        guard let userId = authManager.currentUser?.id else {
            throw APIError(message: "User not authenticated", code: 401)
        }
        
        return try await networkService.fetchOrders(token: authManager.authToken ?? "")
    }
}