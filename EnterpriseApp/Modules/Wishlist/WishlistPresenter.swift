//
//  WishlistPresenter.swift
//  EnterpriseApp
//
//  Created by AI Assistant
//

import Foundation
import Combine

// MARK: - Wishlist Presenter Protocol
protocol WishlistPresenterProtocol: ObservableObject {
    var wishlistItems: [WishlistItem] { get }
    var wishlistItemCount: Int { get }
    
    func loadWishlistItems()
    func addToWishlist(product: Product)
    func removeFromWishlist(productId: String)
    func isInWishlist(productId: String) -> Bool
    func clearWishlist()
}

// MARK: - Wishlist Presenter Implementation
@MainActor
class WishlistPresenter: WishlistPresenterProtocol {
    @Published var wishlistItems: [WishlistItem] = []
    
    var wishlistItemCount: Int {
        wishlistItems.count
    }
    
    private let interactor: WishlistInteractorProtocol
    private let wishlistDataManager = WishlistDataManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init(interactor: WishlistInteractorProtocol = WishlistInteractor()) {
        self.interactor = interactor
        
        // Subscribe to wishlist data manager changes
        wishlistDataManager.$wishlistItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.wishlistItems = items
            }
            .store(in: &cancellables)
        
        loadWishlistItems()
    }
    
    func loadWishlistItems() {
        wishlistItems = interactor.getWishlistItems()
    }
    
    func addToWishlist(product: Product) {
        interactor.addToWishlist(product: product)
    }
    
    func removeFromWishlist(productId: String) {
        interactor.removeFromWishlist(productId: productId)
    }
    
    func isInWishlist(productId: String) -> Bool {
        return interactor.isInWishlist(productId: productId)
    }
    
    func clearWishlist() {
        interactor.clearWishlist()
    }
}