//
//  CartPresenter.swift
//  EnterpriseApp
//
//  Created by AI Assistant
//

import Foundation
import Combine

// MARK: - Cart Presenter Protocol
protocol CartPresenterProtocol: ObservableObject {
    var cartItems: [CartItem] { get }
    var cartItemCount: Int { get }
    var cartTotal: Double { get }
    var formattedCartTotal: String { get }
    
    func loadCartItems()
    func removeFromCart(productId: String)
    func updateCartItemQuantity(productId: String, quantity: Int)
    func clearCart()
}

// MARK: - Cart Presenter Implementation
@MainActor
class CartPresenter: CartPresenterProtocol {
    @Published var cartItems: [CartItem] = []
    
    var cartItemCount: Int {
        cartItems.reduce(0) { $0 + $1.quantity }
    }
    
    var cartTotal: Double {
        cartItems.reduce(0) { $0 + $1.totalPrice }
    }
    
    var formattedCartTotal: String {
        "₹\(String(format: "%.2f", cartTotal))"
    }
    
    private let interactor: CartInteractorProtocol
    private let cartDataManager = CartDataManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init(interactor: CartInteractorProtocol = CartInteractor()) {
        self.interactor = interactor
        
        // Subscribe to cart data manager changes
        cartDataManager.$cartItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.cartItems = items
            }
            .store(in: &cancellables)
        
        loadCartItems()
    }
    
    func loadCartItems() {
        cartItems = interactor.getCartItems()
    }
    
    func removeFromCart(productId: String) {
        interactor.removeFromCart(productId: productId)
    }
    
    func updateCartItemQuantity(productId: String, quantity: Int) {
        interactor.updateCartItemQuantity(productId: productId, quantity: quantity)
    }
    
    func clearCart() {
        interactor.clearCart()
    }
}