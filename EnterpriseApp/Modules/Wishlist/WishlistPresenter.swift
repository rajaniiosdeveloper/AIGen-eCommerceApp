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
    func addToWishlist(product: Product) async
    func removeFromWishlist(itemId: String) async
    func isInWishlist(productId: String) -> Bool
    func clearWishlist() async
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
    
    func addToWishlist(product: Product) async {
        await interactor.addToWishlist(product: product)
    }
    
    func removeFromWishlist(itemId: String) async {
        await interactor.removeFromWishlist(itemId: itemId)
    }
    
    func isInWishlist(productId: String) -> Bool {
        return interactor.isInWishlist(productId: productId)
    }
    
    func clearWishlist() async {
        await interactor.clearWishlist()
    }
}