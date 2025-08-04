//
//  WishlistDataManager.swift
//  EnterpriseApp
//
//  Created by AI Assistant
//

import Foundation
import Combine

// MARK: - Wishlist Data Manager Protocol
protocol WishlistDataManagerProtocol {
    func addToWishlist(product: Product)
    func removeFromWishlist(productId: String)
    func getWishlistItems() -> [WishlistItem]
    func isInWishlist(productId: String) -> Bool
    func getWishlistItemCount() -> Int
}

// MARK: - In-Memory Wishlist Data Manager
class WishlistDataManager: WishlistDataManagerProtocol, ObservableObject {
    static let shared = WishlistDataManager()
    
    @Published var wishlistItems: [WishlistItem] = []
    
    private init() {}
    
    func addToWishlist(product: Product) {
        if !isInWishlist(productId: product.id) {
            let newWishlistItem = WishlistItem(product: product)
            wishlistItems.append(newWishlistItem)
        }
    }
    
    func removeFromWishlist(productId: String) {
        wishlistItems.removeAll { $0.product.id == productId }
    }
    
    func getWishlistItems() -> [WishlistItem] {
        return wishlistItems.sorted { $0.dateAdded > $1.dateAdded }
    }
    
    func isInWishlist(productId: String) -> Bool {
        return wishlistItems.contains { $0.product.id == productId }
    }
    
    func getWishlistItemCount() -> Int {
        return wishlistItems.count
    }
}