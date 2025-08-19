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
    var wishlistItems: [WishlistItem] { get }
    var isLoading: Bool { get }
    var error: NetworkError? { get }
    
    func addToWishlist(product: Product) async
    func removeFromWishlist(itemId: String) async
    func fetchWishlistItems() async
    func isInWishlist(productId: String) -> Bool
    func getWishlistItemCount() -> Int
    func clearError()
}

// MARK: - Live Wishlist Data Manager with API Integration
class WishlistDataManager: WishlistDataManagerProtocol, ObservableObject {
    nonisolated static let shared = WishlistDataManager()
    
    @Published var wishlistItems: [WishlistItem] = []
    @Published var isLoading: Bool = false
    @Published var error: NetworkError? = nil
    
    private let networkService = LiveNetworkService.shared
    
    private init() {
        // Load wishlist items on initialization
        Task {
            await fetchWishlistItems()
        }
    }
    
    @MainActor
    func addToWishlist(product: Product) async {
        isLoading = true
        error = nil
        
        do {
            try await networkService.addToWishlist(productId: product.id)
            
            // Update local state optimistically
            if !isInWishlist(productId: product.id) {
                let newWishlistItem = WishlistItem(product: product)
                wishlistItems.append(newWishlistItem)
            }
            
            // Refresh wishlist from server to ensure consistency
            await fetchWishlistItems()
        } catch let networkError as NetworkError {
            self.error = networkError
        } catch {
            self.error = NetworkError.networkFailure(error.localizedDescription)
        }
        
        isLoading = false
    }
    
    @MainActor
    func removeFromWishlist(itemId: String) async {
        isLoading = true
        error = nil
        
        do {
            try await networkService.removeFromWishlist(itemId: itemId)
            
            // Update local state
            wishlistItems.removeAll { $0.id == itemId }
        } catch let networkError as NetworkError {
            self.error = networkError
        } catch {
            self.error = NetworkError.networkFailure(error.localizedDescription)
        }
        
        isLoading = false
    }
    
    @MainActor
    func fetchWishlistItems() async {
        isLoading = true
        error = nil
        
        do {
            let fetchedWishlistItems = try await networkService.getWishlist()
            wishlistItems = fetchedWishlistItems.sorted { $0.dateAdded > $1.dateAdded }
        } catch let networkError as NetworkError {
            self.error = networkError
        } catch {
            self.error = NetworkError.networkFailure(error.localizedDescription)
        }
        
        isLoading = false
    }
    
    func isInWishlist(productId: String) -> Bool {
        return wishlistItems.contains { $0.product.id == productId }
    }
    
    func getWishlistItemCount() -> Int {
        return wishlistItems.count
    }
    
    func clearError() {
        error = nil
    }
}