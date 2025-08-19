//
//  CartDataManager.swift
//  EnterpriseApp
//
//  Created by AI Assistant
//

import Foundation
import Combine

// MARK: - Cart Data Manager Protocol
protocol CartDataManagerProtocol {
    var cartItems: [CartItem] { get }
    var isLoading: Bool { get }
    var error: NetworkError? { get }
    
    func addToCart(product: Product, quantity: Int) async
    func removeFromCart(itemId: String) async
    func updateCartItemQuantity(itemId: String, quantity: Int) async
    func clearCart() async
    func fetchCartItems() async
    func isInCart(productId: String) -> Bool
    func getCartItemQuantity(productId: String) -> Int
    func getCartTotal() -> Double
    func getCartItemCount() -> Int
    func clearError()
}

// MARK: - Live Cart Data Manager with API Integration
class CartDataManager: CartDataManagerProtocol, ObservableObject {
    nonisolated static let shared = CartDataManager()
    
    @Published var cartItems: [CartItem] = []
    @Published var isLoading: Bool = false
    @Published var error: NetworkError? = nil
    
    private let networkService = LiveNetworkService.shared
    
    private init() {
        // Load cart items on initialization
        Task {
            await fetchCartItems()
        }
    }
    
    @MainActor
    func addToCart(product: Product, quantity: Int = 1) async {
        isLoading = true
        error = nil
        
        do {
            try await networkService.addToCart(productId: product.id, quantity: quantity)
            
            // Update local state optimistically
            if let existingItemIndex = cartItems.firstIndex(where: { $0.product.id == product.id }) {
                cartItems[existingItemIndex].quantity += quantity
            } else {
                let newCartItem = CartItem(product: product, quantity: quantity)
                cartItems.append(newCartItem)
            }
            
            // Refresh cart from server to ensure consistency
            await fetchCartItems()
        } catch let networkError as NetworkError {
            self.error = networkError
        } catch {
            self.error = NetworkError.networkFailure(error.localizedDescription)
        }
        
        isLoading = false
    }
    
    @MainActor
    func removeFromCart(itemId: String) async {
        isLoading = true
        error = nil
        
        do {
            try await networkService.removeFromCart(itemId: itemId)
            
            // Update local state
            cartItems.removeAll { $0.id == itemId }
        } catch let networkError as NetworkError {
            self.error = networkError
        } catch {
            self.error = NetworkError.networkFailure(error.localizedDescription)
        }
        
        isLoading = false
    }
    
    @MainActor
    func updateCartItemQuantity(itemId: String, quantity: Int) async {
        isLoading = true
        error = nil
        
        do {
            if quantity <= 0 {
                try await networkService.removeFromCart(itemId: itemId)
                cartItems.removeAll { $0.id == itemId }
            } else {
                try await networkService.updateCartItem(itemId: itemId, quantity: quantity)
                if let index = cartItems.firstIndex(where: { $0.id == itemId }) {
                    cartItems[index].quantity = quantity
                }
            }
        } catch let networkError as NetworkError {
            self.error = networkError
        } catch {
            self.error = NetworkError.networkFailure(error.localizedDescription)
        }
        
        isLoading = false
    }
    
    @MainActor
    func clearCart() async {
        isLoading = true
        error = nil
        
        do {
            try await networkService.clearCart()
            cartItems.removeAll()
        } catch let networkError as NetworkError {
            self.error = networkError
        } catch {
            self.error = NetworkError.networkFailure(error.localizedDescription)
        }
        
        isLoading = false
    }
    
    @MainActor
    func fetchCartItems() async {
        isLoading = true
        error = nil
        
        do {
            let fetchedCartItems = try await networkService.getCart()
            cartItems = fetchedCartItems.sorted { $0.dateAdded > $1.dateAdded }
        } catch let networkError as NetworkError {
            self.error = networkError
        } catch {
            self.error = NetworkError.networkFailure(error.localizedDescription)
        }
        
        isLoading = false
    }
    
    func isInCart(productId: String) -> Bool {
        return cartItems.contains { $0.product.id == productId }
    }
    
    func getCartItemQuantity(productId: String) -> Int {
        return cartItems.first { $0.product.id == productId }?.quantity ?? 0
    }
    
    func getCartTotal() -> Double {
        return cartItems.reduce(0) { $0 + $1.totalPrice }
    }
    
    func getCartItemCount() -> Int {
        return cartItems.reduce(0) { $0 + $1.quantity }
    }
    
    func clearError() {
        error = nil
    }
}