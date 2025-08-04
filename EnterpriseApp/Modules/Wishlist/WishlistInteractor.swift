//
//  WishlistInteractor.swift
//  EnterpriseApp
//
//  Created by AI Assistant
//

import Foundation

// MARK: - Wishlist Interactor Protocol
protocol WishlistInteractorProtocol {
    func getWishlistItems() -> [WishlistItem]
    func addToWishlist(product: Product)
    func removeFromWishlist(productId: String)
    func isInWishlist(productId: String) -> Bool
    func getWishlistItemCount() -> Int
    func clearWishlist()
}

// MARK: - Wishlist Interactor Implementation
class WishlistInteractor: WishlistInteractorProtocol {
    private let wishlistDataManager: WishlistDataManagerProtocol
    
    init(wishlistDataManager: WishlistDataManagerProtocol = WishlistDataManager.shared) {
        self.wishlistDataManager = wishlistDataManager
    }
    
    func getWishlistItems() -> [WishlistItem] {
        return wishlistDataManager.getWishlistItems()
    }
    
    func addToWishlist(product: Product) {
        wishlistDataManager.addToWishlist(product: product)
    }
    
    func removeFromWishlist(productId: String) {
        wishlistDataManager.removeFromWishlist(productId: productId)
    }
    
    func isInWishlist(productId: String) -> Bool {
        return wishlistDataManager.isInWishlist(productId: productId)
    }
    
    func getWishlistItemCount() -> Int {
        return wishlistDataManager.getWishlistItemCount()
    }
    
    func clearWishlist() {
        let items = wishlistDataManager.getWishlistItems()
        for item in items {
            wishlistDataManager.removeFromWishlist(productId: item.product.id)
        }
    }
}