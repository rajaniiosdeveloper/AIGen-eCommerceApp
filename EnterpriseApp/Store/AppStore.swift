//
//  AppStore.swift
//  EnterpriseApp
//
//  Created by AI Assistant
//

import Foundation
import Combine
import CoreData

// MARK: - App Store for Global State Management
class AppStore: ObservableObject {
    static let shared = AppStore()
    
    // MARK: - Published Properties
    @Published var products: [Product] = []
    @Published var cartItems: [CartItemEntity] = []
    @Published var wishlistItems: [WishlistItemEntity] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var selectedProduct: Product?
    
    // MARK: - Services
    private let networkService: NetworkServiceProtocol
    private let coreDataManager: CoreDataManager
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    var cartItemCount: Int {
        cartItems.reduce(0) { $0 + Int($1.quantity) }
    }
    
    var wishlistItemCount: Int {
        wishlistItems.count
    }
    
    var cartTotal: Double {
        cartItems.reduce(0) { $0 + $1.totalPrice }
    }
    
    var formattedCartTotal: String {
        "₹\(String(format: "%.2f", cartTotal))"
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
    
    private init() {
        self.networkService = NetworkService.shared
        self.coreDataManager = CoreDataManager.shared
        
        loadCartItems()
        loadWishlistItems()
        fetchProducts()
    }
    
    // MARK: - Product Management
    func fetchProducts() {
        isLoading = true
        errorMessage = nil
        
        networkService.fetchProducts()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] products in
                    self?.products = products
                }
            )
            .store(in: &cancellables)
    }
    
    func searchProducts(query: String) {
        searchText = query
    }
    
    func selectProduct(_ product: Product) {
        selectedProduct = product
    }
    
    // MARK: - Cart Management
    func addToCart(product: Product, quantity: Int = 1) {
        coreDataManager.addToCart(product: product, quantity: quantity)
        loadCartItems()
    }
    
    func removeFromCart(productId: String) {
        coreDataManager.removeFromCart(productId: productId)
        loadCartItems()
    }
    
    func updateCartItemQuantity(productId: String, quantity: Int) {
        coreDataManager.updateCartItemQuantity(productId: productId, quantity: quantity)
        loadCartItems()
    }
    
    func clearCart() {
        coreDataManager.clearCart()
        loadCartItems()
    }
    
    private func loadCartItems() {
        cartItems = coreDataManager.fetchCartItems()
    }
    
    func isInCart(productId: String) -> Bool {
        return cartItems.contains { $0.productId == productId }
    }
    
    func getCartItemQuantity(productId: String) -> Int {
        return cartItems.first { $0.productId == productId }?.quantity.int32Value ?? 0
    }
    
    // MARK: - Wishlist Management
    func addToWishlist(product: Product) {
        coreDataManager.addToWishlist(product: product)
        loadWishlistItems()
    }
    
    func removeFromWishlist(productId: String) {
        coreDataManager.removeFromWishlist(productId: productId)
        loadWishlistItems()
    }
    
    private func loadWishlistItems() {
        wishlistItems = coreDataManager.fetchWishlistItems()
    }
    
    func isInWishlist(productId: String) -> Bool {
        return wishlistItems.contains { $0.productId == productId }
    }
    
    // MARK: - Error Handling
    func clearError() {
        errorMessage = nil
    }
}

// MARK: - Extensions
extension Int32 {
    var int32Value: Int {
        return Int(self)
    }
}