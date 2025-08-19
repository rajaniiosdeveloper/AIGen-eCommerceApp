//
//  NetworkService.swift
//  EnterpriseApp
//
//  Created by AI Assistant
//

import Foundation

// MARK: - Network Service Protocol
protocol NetworkServiceProtocol {
    // Product APIs
    func fetchProducts(page: Int, limit: Int, category: String?) async throws -> (products: [Product], hasMore: Bool, totalPages: Int)
    func fetchProduct(id: String) async throws -> Product
    func searchProducts(query: String) async throws -> [Product]
    func fetchProductsByCategory(categoryId: String) async throws -> [Product]
    
    // Authentication APIs
    func signIn(email: String, password: String) async throws -> AuthResponse
    func register(name: String, email: String, password: String) async throws -> AuthResponse
    func getUserProfile(token: String) async throws -> User
    
    // Category APIs
    func fetchCategories() async throws -> [Category]
    
    // Order APIs
    func fetchOrders(token: String) async throws -> [Order]
    func fetchOrder(orderId: String, token: String) async throws -> Order
    func createOrder(token: String, shippingAddress: String) async throws -> Order
    
    // Cart APIs
    func addToCart(productId: String, quantity: Int) async throws -> Void
    func getCart() async throws -> [CartItem]
    func updateCartItem(itemId: String, quantity: Int) async throws -> Void
    func removeFromCart(itemId: String) async throws -> Void
    func clearCart() async throws -> Void
    
    // Wishlist APIs
    func addToWishlist(productId: String) async throws -> Void
    func getWishlist() async throws -> [WishlistItem]
    func removeFromWishlist(itemId: String) async throws -> Void
    
    // Payment APIs
    func initiatePayment(orderId: String, paymentMethod: String) async throws -> PaymentInfo
    func verifyPayment(paymentId: String, signature: String) async throws -> PaymentResult
}

// MARK: - Network Service Implementation
class NetworkService: NetworkServiceProtocol {
    static let shared: NetworkServiceProtocol = LiveNetworkService.shared
    
    private init() {}
    
    // MARK: - Product API Methods
    func fetchProducts(page: Int = 1, limit: Int = 20, category: String? = nil) async throws -> (products: [Product], hasMore: Bool, totalPages: Int) {
        return try await LiveNetworkService.shared.fetchProducts(page: page, limit: limit, category: category)
    }
    
    func fetchProduct(id: String) async throws -> Product {
        return try await LiveNetworkService.shared.fetchProduct(id: id)
    }
    
    func searchProducts(query: String) async throws -> [Product] {
        return try await LiveNetworkService.shared.searchProducts(query: query)
    }
    
    func fetchProductsByCategory(categoryId: String) async throws -> [Product] {
        return try await LiveNetworkService.shared.fetchProductsByCategory(categoryId: categoryId)
    }
    
    // MARK: - Authentication API Methods
    func signIn(email: String, password: String) async throws -> AuthResponse {
        return try await LiveNetworkService.shared.signIn(email: email, password: password)
    }
    
    func register(name: String, email: String, password: String) async throws -> AuthResponse {
        return try await LiveNetworkService.shared.register(name: name, email: email, password: password)
    }
    
    func getUserProfile(token: String) async throws -> User {
        return try await LiveNetworkService.shared.getUserProfile(token: token)
    }
    
    // MARK: - Category Methods
    func fetchCategories() async throws -> [Category] {
        return try await LiveNetworkService.shared.fetchCategories()
    }
    
    // MARK: - Order Methods
    func fetchOrders(token: String) async throws -> [Order] {
        return try await LiveNetworkService.shared.fetchOrders(token: token)
    }
    
    func fetchOrder(orderId: String, token: String) async throws -> Order {
        return try await LiveNetworkService.shared.fetchOrder(orderId: orderId, token: token)
    }
    
    func createOrder(token: String, shippingAddress: String) async throws -> Order {
        return try await LiveNetworkService.shared.createOrder(token: token, shippingAddress: shippingAddress)
    }
    
    // MARK: - Cart APIs
    func addToCart(productId: String, quantity: Int) async throws {
        return try await LiveNetworkService.shared.addToCart(productId: productId, quantity: quantity)
    }
    
    func getCart() async throws -> [CartItem] {
        return try await LiveNetworkService.shared.getCart()
    }
    
    func updateCartItem(itemId: String, quantity: Int) async throws {
        return try await LiveNetworkService.shared.updateCartItem(itemId: itemId, quantity: quantity)
    }
    
    func removeFromCart(itemId: String) async throws {
        return try await LiveNetworkService.shared.removeFromCart(itemId: itemId)
    }
    
    func clearCart() async throws {
        return try await LiveNetworkService.shared.clearCart()
    }
    
    // MARK: - Wishlist APIs
    func addToWishlist(productId: String) async throws {
        return try await LiveNetworkService.shared.addToWishlist(productId: productId)
    }
    
    func getWishlist() async throws -> [WishlistItem] {
        return try await LiveNetworkService.shared.getWishlist()
    }
    
    func removeFromWishlist(itemId: String) async throws {
        return try await LiveNetworkService.shared.removeFromWishlist(itemId: itemId)
    }
    
    // MARK: - Payment APIs
    func initiatePayment(orderId: String, paymentMethod: String) async throws -> PaymentInfo {
        return try await LiveNetworkService.shared.initiatePayment(orderId: orderId, paymentMethod: paymentMethod)
    }
    
    func verifyPayment(paymentId: String, signature: String) async throws -> PaymentResult {
        return try await LiveNetworkService.shared.verifyPayment(paymentId: paymentId, signature: signature)
    }
}