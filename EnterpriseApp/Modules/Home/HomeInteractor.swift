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
    func fetchProducts(page: Int, limit: Int, category: String?) async throws -> (products: [Product], hasMore: Bool, totalPages: Int)
    func searchProducts(query: String) async throws -> [Product]
    func fetchCategories() async throws -> [Category]
    func fetchProductsByCategory(categoryId: String) async throws -> [Product]
}

// MARK: - Home Interactor Implementation
class HomeInteractor: HomeInteractorProtocol {
    private let networkService = LiveNetworkService.shared
    
    init() {}
    
    func fetchProducts(page: Int = 1, limit: Int = 20, category: String? = nil) async throws -> (products: [Product], hasMore: Bool, totalPages: Int) {
        return try await networkService.fetchProducts(page: page, limit: limit, category: category)
    }
    
    func searchProducts(query: String) async throws -> [Product] {
        return try await networkService.searchProducts(query: query)
    }
    
    func fetchCategories() async throws -> [Category] {
        return try await networkService.fetchCategories()
    }
    
    func fetchProductsByCategory(categoryId: String) async throws -> [Product] {
        return try await networkService.fetchProductsByCategory(categoryId: categoryId)
    }
}