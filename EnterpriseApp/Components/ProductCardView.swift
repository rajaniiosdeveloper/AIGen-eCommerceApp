//
//  ProductCardView.swift
//  EnterpriseApp
//
//  Created by AI Assistant
//

import SwiftUI

struct ProductCardView: View {
    let product: Product
    let onTap: () -> Void
    @StateObject private var cartDataManager = CartDataManager.shared
    @StateObject private var wishlistDataManager = WishlistDataManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Product Image
            AsyncImageView(
                url: product.imageURL,
                width: nil,
                height: 160,
                contentMode: .fill
            )
            .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 3) {
                // Product Title
                Text(product.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                // Product Description
                Text(product.shortDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                // Rating and Stock
                HStack {
                    if product.rating > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.caption)
                            Text(String(format: "%.1f", product.rating))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    if product.stock < 5 {
                        Text("Only \(product.stock) left")
                            .font(.caption2)
                            .foregroundColor(.red)
                            .fontWeight(.medium)
                    }
                }
                
                // Price
                Text(product.formattedPrice)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                // Action Buttons
                HStack(spacing: 6) {
                    // Add to Cart Button
                    Button(action: {
                        Task {
                            await cartDataManager.addToCart(product: product)
                        }
                    }) {
                        HStack(spacing: 3) {
                            Image(systemName: "cart.badge.plus")
                                .font(.caption)
                            Text("Add")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.blue)
                        .cornerRadius(5)
                    }
                    .disabled(!product.isInStock)
                    
                    // Wishlist Button
                    Button(action: {
                        Task {
                            if wishlistDataManager.isInWishlist(productId: product.id) {
                                if let item = wishlistDataManager.wishlistItems.first(where: { $0.product.id == product.id }) {
                                    await wishlistDataManager.removeFromWishlist(itemId: item.id)
                                }
                            } else {
                                await wishlistDataManager.addToWishlist(product: product)
                            }
                        }
                    }) {
                        Image(systemName: wishlistDataManager.isInWishlist(productId: product.id) ? "heart.fill" : "heart")
                            .font(.caption)
                            .foregroundColor(wishlistDataManager.isInWishlist(productId: product.id) ? .red : .gray)
                            .frame(width: 24, height: 24)
                    }
                }
            }
            .padding(.horizontal, 6)
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
        .onTapGesture {
            onTap()
        }
    }
}