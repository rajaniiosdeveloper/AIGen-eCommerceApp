//
//  AppRouter.swift
//  EnterpriseApp
//
//  Created by AI Assistant
//

import SwiftUI
import Combine

// MARK: - App Router (VIPER Router)
class AppRouter: ObservableObject {
    @Published var selectedProduct: Product?
    @Published var selectedOrder: Order?
    @Published var showingProductDetail = false
    @Published var showingCart = false
    @Published var showingWishlist = false
    @Published var showingPayment = false
    @Published var showingMenu = false
    @Published var showingOrderHistory = false
    @Published var showingOrderDetail = false
    @Published var paymentProduct: Product?
    @Published var isPaymentFromCart = false
    
    func navigateToProductDetail(_ product: Product) {
        selectedProduct = product
        showingProductDetail = true
    }
    
    func navigateToCart() {
        showingCart = true
    }
    
    func navigateToWishlist() {
        showingWishlist = true
    }
    
    func navigateToPayment(product: Product) {
        paymentProduct = product
        isPaymentFromCart = false
        showingPayment = true
    }
    
    func navigateToCheckout() {
        paymentProduct = nil
        isPaymentFromCart = true
        showingPayment = true
    }
    
    func navigateToMenu() {
        showingMenu = true
    }
    
    func navigateToOrderHistory() {
        showingOrderHistory = true
    }
    
    func navigateToOrderDetail(_ order: Order) {
        selectedOrder = order
        showingOrderDetail = true
    }
    
    func dismissAll() {
        showingProductDetail = false
        showingCart = false
        showingWishlist = false
        showingPayment = false
        showingMenu = false
        showingOrderHistory = false
        showingOrderDetail = false
        selectedProduct = nil
        selectedOrder = nil
        paymentProduct = nil
        isPaymentFromCart = false
    }
}