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
    func addToCart(product: Product, quantity: Int) async
    func removeFromCart(itemId: String) async
    func updateCartItemQuantity(itemId: String, quantity: Int) async
    func clearCart() async
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
        return cartDataManager.cartItems
    }
    
    func addToCart(product: Product, quantity: Int = 1) async {
        await cartDataManager.addToCart(product: product, quantity: quantity)
    }
    
    func removeFromCart(itemId: String) async {
        await cartDataManager.removeFromCart(itemId: itemId)
    }
    
    func updateCartItemQuantity(itemId: String, quantity: Int) async {
        await cartDataManager.updateCartItemQuantity(itemId: itemId, quantity: quantity)
    }
    
    func clearCart() async {
        await cartDataManager.clearCart()
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