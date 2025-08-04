//
//  HomePresenter.swift
//  EnterpriseApp
//
//  Created by AI Assistant
//

import Foundation
import Combine

// MARK: - Home Presenter Protocol
protocol HomePresenterProtocol: ObservableObject {
    var products: [Product] { get }
    var filteredProducts: [Product] { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get }
    var searchText: String { get set }
    
    func fetchProducts()
    func searchProducts()
    func clearError()
}

// MARK: - Home Presenter Implementation
@MainActor
class HomePresenter: HomePresenterProtocol {
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var searchText = "" {
        didSet {
            searchProducts()
        }
    }
    
    var filteredProducts: [Product] {
        if searchText.isEmpty {
            return products
        } else {
            return products.filter { product in
                product.title.localizedCaseInsensitiveContains(searchText) ||
                product.description.localizedCaseInsensitiveContains(searchText) ||
                product.category.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private let interactor: HomeInteractorProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(interactor: HomeInteractorProtocol = HomeInteractor()) {
        self.interactor = interactor
    }
    
    func fetchProducts() {
        Task {
            isLoading = true
            errorMessage = nil
            
            do {
                let fetchedProducts = try await interactor.fetchProducts()
                self.products = fetchedProducts
            } catch {
                self.errorMessage = error.localizedDescription
            }
            
            isLoading = false
        }
    }
    
    func searchProducts() {
        guard !searchText.isEmpty else { return }
        
        Task {
            do {
                let searchResults = try await interactor.searchProducts(query: searchText)
                // For local filtering, we'll use the computed property
                // If you want server-side search, you would set products = searchResults here
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
}