//
//  HomeInteractor.swift
//  EnterpriseApp
//
//  Created by AI Assistant
//

import Foundation
import Combine

// MARK: - Home Interactor Protocol
protocol HomeInteractorProtocol {
    func fetchProducts() async throws -> [Product]
    func searchProducts(query: String) async throws -> [Product]
}

// MARK: - Home Interactor Implementation
class HomeInteractor: HomeInteractorProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
    }
    
    func fetchProducts() async throws -> [Product] {
        return try await networkService.fetchProducts()
    }
    
    func searchProducts(query: String) async throws -> [Product] {
        return try await networkService.searchProducts(query: query)
    }
}