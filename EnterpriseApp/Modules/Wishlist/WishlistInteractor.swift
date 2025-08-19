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
    func addToWishlist(product: Product) async
    func removeFromWishlist(itemId: String) async
    func isInWishlist(productId: String) -> Bool
    func getWishlistItemCount() -> Int
    func clearWishlist() async
}

// MARK: - Wishlist Interactor Implementation
class WishlistInteractor: WishlistInteractorProtocol {
    private let wishlistDataManager: WishlistDataManagerProtocol
    
    init(wishlistDataManager: WishlistDataManagerProtocol = WishlistDataManager.shared) {
        self.wishlistDataManager = wishlistDataManager
    }
    
    func getWishlistItems() -> [WishlistItem] {
        return wishlistDataManager.wishlistItems
    }
    
    func addToWishlist(product: Product) async {
        await wishlistDataManager.addToWishlist(product: product)
    }
    
    func removeFromWishlist(itemId: String) async {
        await wishlistDataManager.removeFromWishlist(itemId: itemId)
    }
    
    func isInWishlist(productId: String) -> Bool {
        return wishlistDataManager.isInWishlist(productId: productId)
    }
    
    func getWishlistItemCount() -> Int {
        return wishlistDataManager.getWishlistItemCount()
    }
    
    func clearWishlist() async {
        let items = wishlistDataManager.wishlistItems
        for item in items {
            await wishlistDataManager.removeFromWishlist(itemId: item.id)
        }
    }
}