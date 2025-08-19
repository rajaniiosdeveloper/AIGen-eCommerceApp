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
    var isLoadingMore: Bool { get }
    var error: NetworkError? { get }
    var searchText: String { get set }
    var hasMoreProducts: Bool { get }
    
    func fetchProducts()
    func loadMoreProducts()
    func fetchCategories()
    func searchProducts()
    func selectCategory(_ category: Category?)
    func refreshProducts()
    func clearError()
}

// MARK: - Home Presenter Implementation
@MainActor
class HomePresenter: HomePresenterProtocol {
    @Published var products: [Product] = []
    @Published var categories: [Category] = []
    @Published var selectedCategory: Category? = nil {
        didSet {
            resetPagination()
            fetchProductsByCategory()
        }
    }
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var error: NetworkError? = nil
    @Published var searchText = "" {
        didSet {
            if oldValue != searchText {
                resetPagination()
                searchProducts()
            }
        }
    }
    @Published var hasMoreProducts = true
    
    // Pagination properties
    private var currentPage = 1
    private let pageSize = 20
    private var totalPages = 1
    
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
            error = nil
            
            do {
                let result = try await interactor.fetchProducts(page: currentPage, limit: pageSize, category: selectedCategory?.id)
                
                if currentPage == 1 {
                    self.products = result.products
                } else {
                    self.products.append(contentsOf: result.products)
                }
                
                self.hasMoreProducts = result.hasMore
                self.totalPages = result.totalPages
                
            } catch let networkError as NetworkError {
                self.error = networkError
            } catch {
                self.error = NetworkError.networkFailure(error.localizedDescription)
            }
            
            isLoading = false
        }
    }
    
    func loadMoreProducts() {
        guard hasMoreProducts && !isLoading && !isLoadingMore else { return }
        
        Task {
            isLoadingMore = true
            error = nil
            currentPage += 1
            
            do {
                let result = try await interactor.fetchProducts(page: currentPage, limit: pageSize, category: selectedCategory?.id)
                
                self.products.append(contentsOf: result.products)
                self.hasMoreProducts = result.hasMore
                self.totalPages = result.totalPages
                
            } catch let networkError as NetworkError {
                self.error = networkError
                currentPage -= 1 // Revert page increment on error
            } catch {
                self.error = NetworkError.networkFailure(error.localizedDescription)
                currentPage -= 1
            }
            
            isLoadingMore = false
        }
    }
    
    func refreshProducts() {
        resetPagination()
        fetchProducts()
    }
    
    private func resetPagination() {
        currentPage = 1
        hasMoreProducts = true
        products.removeAll()
    }
    
    func searchProducts() {
        guard !searchText.isEmpty else { 
            if selectedCategory == nil {
                refreshProducts()
            }
            return 
        }
        
        Task {
            isLoading = true
            error = nil
            
            do {
                let searchResults = try await interactor.searchProducts(query: searchText)
                self.products = searchResults
                // Reset pagination state for search results
                self.hasMoreProducts = false
            } catch let networkError as NetworkError {
                self.error = networkError
            } catch {
                self.error = NetworkError.networkFailure(error.localizedDescription)
            }
            
            isLoading = false
        }
    }
    
    func fetchCategories() {
        Task {
            do {
                let fetchedCategories = try await interactor.fetchCategories()
                self.categories = fetchedCategories
            } catch let networkError as NetworkError {
                self.error = networkError
            } catch {
                self.error = NetworkError.networkFailure(error.localizedDescription)
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
            error = nil
            
            do {
                let fetchedProducts = try await interactor.fetchProductsByCategory(categoryId: selectedCategory.id)
                self.products = fetchedProducts
                // Reset pagination state for category filtering
                self.hasMoreProducts = false
            } catch let networkError as NetworkError {
                self.error = networkError
            } catch {
                self.error = NetworkError.networkFailure(error.localizedDescription)
            }
            
            isLoading = false
        }
    }
    
    func clearError() {
        error = nil
    }
}