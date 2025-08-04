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
    func addToCart(product: Product, quantity: Int)
    func removeFromCart(productId: String)
    func updateCartItemQuantity(productId: String, quantity: Int)
    func clearCart()
    func getCartItems() -> [CartItem]
    func isInCart(productId: String) -> Bool
    func getCartItemQuantity(productId: String) -> Int
    func getCartTotal() -> Double
    func getCartItemCount() -> Int
}

// MARK: - In-Memory Cart Data Manager
class CartDataManager: CartDataManagerProtocol, ObservableObject {
    static let shared = CartDataManager()
    
    @Published var cartItems: [CartItem] = []
    
    private init() {}
    
    func addToCart(product: Product, quantity: Int = 1) {
        if let existingItemIndex = cartItems.firstIndex(where: { $0.product.id == product.id }) {
            cartItems[existingItemIndex].quantity += quantity
        } else {
            let newCartItem = CartItem(product: product, quantity: quantity)
            cartItems.append(newCartItem)
        }
    }
    
    func removeFromCart(productId: String) {
        cartItems.removeAll { $0.product.id == productId }
    }
    
    func updateCartItemQuantity(productId: String, quantity: Int) {
        if quantity <= 0 {
            removeFromCart(productId: productId)
        } else {
            if let index = cartItems.firstIndex(where: { $0.product.id == productId }) {
                cartItems[index].quantity = quantity
            }
        }
    }
    
    func clearCart() {
        cartItems.removeAll()
    }
    
    func getCartItems() -> [CartItem] {
        return cartItems.sorted { $0.dateAdded > $1.dateAdded }
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
}