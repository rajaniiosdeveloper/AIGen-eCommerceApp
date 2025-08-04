//
//  CoreDataManager.swift
//  EnterpriseApp
//
//  Created by AI Assistant
//

import Foundation
import CoreData
import Combine

// MARK: - Core Data Manager
class CoreDataManager: ObservableObject {
    static let shared = CoreDataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "EnterpriseApp")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data error: \(error.localizedDescription)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    private init() {}
    
    func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error)")
            }
        }
    }
    
    // MARK: - Cart Management
    func addToCart(product: Product, quantity: Int = 1) {
        // Check if product already exists in cart
        let fetchRequest: NSFetchRequest<CartItemEntity> = CartItemEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "productId == %@", product.id)
        
        do {
            let existingItems = try context.fetch(fetchRequest)
            if let existingItem = existingItems.first {
                existingItem.quantity += Int32(quantity)
            } else {
                let cartItem = CartItemEntity(context: context)
                cartItem.id = UUID().uuidString
                cartItem.productId = product.id
                cartItem.productTitle = product.title
                cartItem.productPrice = product.price
                cartItem.productImageURL = product.imageURL
                cartItem.quantity = Int32(quantity)
                cartItem.dateAdded = Date()
            }
            save()
        } catch {
            print("Failed to add to cart: \(error)")
        }
    }
    
    func removeFromCart(productId: String) {
        let fetchRequest: NSFetchRequest<CartItemEntity> = CartItemEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "productId == %@", productId)
        
        do {
            let items = try context.fetch(fetchRequest)
            for item in items {
                context.delete(item)
            }
            save()
        } catch {
            print("Failed to remove from cart: \(error)")
        }
    }
    
    func updateCartItemQuantity(productId: String, quantity: Int) {
        let fetchRequest: NSFetchRequest<CartItemEntity> = CartItemEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "productId == %@", productId)
        
        do {
            let items = try context.fetch(fetchRequest)
            if let item = items.first {
                if quantity <= 0 {
                    context.delete(item)
                } else {
                    item.quantity = Int32(quantity)
                }
                save()
            }
        } catch {
            print("Failed to update cart item: \(error)")
        }
    }
    
    func fetchCartItems() -> [CartItemEntity] {
        let fetchRequest: NSFetchRequest<CartItemEntity> = CartItemEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: false)]
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch cart items: \(error)")
            return []
        }
    }
    
    func clearCart() {
        let fetchRequest: NSFetchRequest<CartItemEntity> = CartItemEntity.fetchRequest()
        
        do {
            let items = try context.fetch(fetchRequest)
            for item in items {
                context.delete(item)
            }
            save()
        } catch {
            print("Failed to clear cart: \(error)")
        }
    }
    
    // MARK: - Wishlist Management
    func addToWishlist(product: Product) {
        // Check if product already exists in wishlist
        let fetchRequest: NSFetchRequest<WishlistItemEntity> = WishlistItemEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "productId == %@", product.id)
        
        do {
            let existingItems = try context.fetch(fetchRequest)
            if existingItems.isEmpty {
                let wishlistItem = WishlistItemEntity(context: context)
                wishlistItem.id = UUID().uuidString
                wishlistItem.productId = product.id
                wishlistItem.productTitle = product.title
                wishlistItem.productPrice = product.price
                wishlistItem.productImageURL = product.imageURL
                wishlistItem.dateAdded = Date()
                save()
            }
        } catch {
            print("Failed to add to wishlist: \(error)")
        }
    }
    
    func removeFromWishlist(productId: String) {
        let fetchRequest: NSFetchRequest<WishlistItemEntity> = WishlistItemEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "productId == %@", productId)
        
        do {
            let items = try context.fetch(fetchRequest)
            for item in items {
                context.delete(item)
            }
            save()
        } catch {
            print("Failed to remove from wishlist: \(error)")
        }
    }
    
    func fetchWishlistItems() -> [WishlistItemEntity] {
        let fetchRequest: NSFetchRequest<WishlistItemEntity> = WishlistItemEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: false)]
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch wishlist items: \(error)")
            return []
        }
    }
    
    func isInWishlist(productId: String) -> Bool {
        let fetchRequest: NSFetchRequest<WishlistItemEntity> = WishlistItemEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "productId == %@", productId)
        
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            return false
        }
    }
}