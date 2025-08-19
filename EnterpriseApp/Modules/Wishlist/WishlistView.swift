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
    @StateObject private var presenter = WishlistPresenter()
    @Environment(\.dismiss) private var dismiss
    
    let onProductTap: (Product) -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                if presenter.wishlistItems.isEmpty {
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
                            
                            Text("\(presenter.wishlistItemCount) items")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        
                        // Wishlist Items List
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(presenter.wishlistItems, id: \.id) { wishlistItem in
                                    WishlistItemRowView(
                                        wishlistItem: wishlistItem,
                                        onProductTap: onProductTap,
                                        presenter: presenter
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
                
                if !presenter.wishlistItems.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Clear All") {
                            Task {
                                await presenter.clearWishlist()
                            }
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
    let wishlistItem: WishlistItem
    let onProductTap: (Product) -> Void
    let presenter: WishlistPresenter
    
    var body: some View {
        HStack(spacing: 12) {
            // Product Image
            AsyncImageView(
                url: wishlistItem.product.imageURL,
                width: 80,
                height: 80,
                contentMode: .fill
            )
            .cornerRadius(12)
            .onTapGesture {
                onProductTap(wishlistItem.product)
            }
            
            // Product Info
            VStack(alignment: .leading, spacing: 6) {
                Text(wishlistItem.product.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                
                Text(wishlistItem.product.formattedPrice)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Added \(wishlistItem.dateAdded, style: .relative)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Action Buttons
                HStack(spacing: 12) {
                    Button(action: {
                        // Get cart data manager to add item
                        Task {
                            await CartDataManager.shared.addToCart(product: wishlistItem.product)
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
                        Task {
                            await presenter.removeFromWishlist(itemId: wishlistItem.id)
                        }
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

// MARK: - Legacy components (will be removed)
// The new WishlistPresenter and WishlistInteractor are now in separate files

// MARK: - Preview
#Preview {
    WishlistView(onProductTap: { _ in })
}