//
//  CartInteractor.swift
//  EnterpriseApp
//
//  Created by AI Assistant
//

import Foundation

// MARK: - Cart Interactor Protocol
protocol CartInteractorProtocol {
    func getCartItems() -> [CartItem]
    func addToCart(product: Product, quantity: Int)
    func removeFromCart(productId: String)
    func updateCartItemQuantity(productId: String, quantity: Int)
    func clearCart()
    func isInCart(productId: String) -> Bool
    func getCartItemQuantity(productId: String) -> Int
    func getCartTotal() -> Double
    func getCartItemCount() -> Int
}

// MARK: - Cart Interactor Implementation
class CartInteractor: CartInteractorProtocol {
    private let cartDataManager: CartDataManagerProtocol
    
    init(cartDataManager: CartDataManagerProtocol = CartDataManager.shared) {
        self.cartDataManager = cartDataManager
    }
    
    func getCartItems() -> [CartItem] {
        return cartDataManager.getCartItems()
    }
    
    func addToCart(product: Product, quantity: Int = 1) {
        cartDataManager.addToCart(product: product, quantity: quantity)
    }
    
    func removeFromCart(productId: String) {
        cartDataManager.removeFromCart(productId: productId)
    }
    
    func updateCartItemQuantity(productId: String, quantity: Int) {
        cartDataManager.updateCartItemQuantity(productId: productId, quantity: quantity)
    }
    
    func clearCart() {
        cartDataManager.clearCart()
    }
    
    func isInCart(productId: String) -> Bool {
        return cartDataManager.isInCart(productId: productId)
    }
    
    func getCartItemQuantity(productId: String) -> Int {
        return cartDataManager.getCartItemQuantity(productId: productId)
    }
    
    func getCartTotal() -> Double {
        return cartDataManager.getCartTotal()
    }
    
    func getCartItemCount() -> Int {
        return cartDataManager.getCartItemCount()
    }
}