//
//  WishlistView.swift
//  EnterpriseApp
//
//  Created by AI Assistant
//

import SwiftUI
import Combine

// MARK: - Wishlist View (VIPER)
struct WishlistView: View {
    @EnvironmentObject var store: AppStore
    @StateObject private var presenter = WishlistPresenter()
    @Environment(\.dismiss) private var dismiss
    
    let onProductTap: (Product) -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                if store.wishlistItems.isEmpty {
                    // Empty Wishlist State
                    VStack(spacing: 20) {
                        Image(systemName: "heart")
                            .font(.system(size: 80))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("Your wishlist is empty")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        Text("Save items you love for later")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Start Shopping")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(Color.red)
                                .cornerRadius(25)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Wishlist Items
                    VStack {
                        // Wishlist Header
                        HStack {
                            Text("My Wishlist")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Text("\(store.wishlistItemCount) items")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        
                        // Wishlist Items List
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(store.wishlistItems, id: \.id) { wishlistItem in
                                    WishlistItemRowView(
                                        wishlistItem: wishlistItem,
                                        onProductTap: onProductTap
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                if !store.wishlistItems.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Clear All") {
                            presenter.clearWishlist()
                        }
                        .foregroundColor(.red)
                    }
                }
            }
        }
    }
}

// MARK: - Wishlist Item Row View
struct WishlistItemRowView: View {
    let wishlistItem: WishlistItemEntity
    @EnvironmentObject var store: AppStore
    let onProductTap: (Product) -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Product Image
            AsyncImageView(
                url: wishlistItem.productImageURL ?? "",
                width: 80,
                height: 80,
                contentMode: .fill
            )
            .cornerRadius(12)
            .onTapGesture {
                if let productId = wishlistItem.productId {
                    // Find the full product from the store
                    if let product = store.products.first(where: { $0.id == productId }) {
                        onProductTap(product)
                    }
                }
            }
            
            // Product Info
            VStack(alignment: .leading, spacing: 6) {
                Text(wishlistItem.productTitle ?? "")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                
                Text(wishlistItem.formattedPrice)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                if let dateAdded = wishlistItem.dateAdded {
                    Text("Added \(dateAdded, style: .relative)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Action Buttons
                HStack(spacing: 12) {
                    Button(action: {
                        if let productId = wishlistItem.productId,
                           let product = store.products.first(where: { $0.id == productId }) {
                            store.addToCart(product: product)
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "cart.badge.plus")
                                .font(.caption)
                            Text("Add to Cart")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .cornerRadius(6)
                    }
                    
                    Button(action: {
                        store.removeFromWishlist(productId: wishlistItem.productId ?? "")
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "heart.slash")
                                .font(.caption)
                            Text("Remove")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.red)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(6)
                    }
                }
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Wishlist Presenter (VIPER)
class WishlistPresenter: ObservableObject {
    private let interactor = WishlistInteractor()
    
    func removeFromWishlist(productId: String) {
        interactor.removeFromWishlist(productId: productId)
    }
    
    func clearWishlist() {
        interactor.clearWishlist()
    }
}

// MARK: - Wishlist Interactor (VIPER)
class WishlistInteractor {
    func removeFromWishlist(productId: String) {
        AppStore.shared.removeFromWishlist(productId: productId)
    }
    
    func clearWishlist() {
        // Remove all wishlist items
        for item in AppStore.shared.wishlistItems {
            AppStore.shared.removeFromWishlist(productId: item.productId ?? "")
        }
    }
}

// MARK: - Preview
#Preview {
    WishlistView(onProductTap: { _ in })
        .environmentObject(AppStore.shared)
}