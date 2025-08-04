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
    var categories: [Category] { get }
    var selectedCategory: Category? { get set }
    var isLoading: Bool { get }
    var errorMessage: String? { get }
    var searchText: String { get set }
    
    func fetchProducts()
    func fetchCategories()
    func searchProducts()
    func selectCategory(_ category: Category?)
    func clearError()
}

// MARK: - Home Presenter Implementation
@MainActor
class HomePresenter: HomePresenterProtocol {
    @Published var products: [Product] = []
    @Published var categories: [Category] = []
    @Published var selectedCategory: Category? = nil {
        didSet {
            fetchProductsByCategory()
        }
    }
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var searchText = "" {
        didSet {
            searchProducts()
        }
    }
    
    var filteredProducts: [Product] {
        var filtered = products
        
        // Filter by category if selected
        if let selectedCategory = selectedCategory {
            filtered = filtered.filter { $0.category == selectedCategory.name }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { product in
                product.title.localizedCaseInsensitiveContains(searchText) ||
                product.description.localizedCaseInsensitiveContains(searchText) ||
                product.category.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered
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
    
    func fetchCategories() {
        Task {
            do {
                let fetchedCategories = try await interactor.fetchCategories()
                self.categories = fetchedCategories
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func selectCategory(_ category: Category?) {
        selectedCategory = category
    }
    
    private func fetchProductsByCategory() {
        guard let selectedCategory = selectedCategory else {
            fetchProducts()
            return
        }
        
        Task {
            isLoading = true
            errorMessage = nil
            
            do {
                let fetchedProducts = try await interactor.fetchProductsByCategory(categoryId: selectedCategory.id)
                self.products = fetchedProducts
            } catch {
                self.errorMessage = error.localizedDescription
            }
            
            isLoading = false
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
}