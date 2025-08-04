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
        VStack(alignment: .leading, spacing: 4) {
            // Product Image
            AsyncImageView(
                url: product.imageURL,
                width: nil,
                height: 140,
                contentMode: .fill
            )
            .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 2) {
                // Product Title
                Text(product.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(height: 36) // Fixed height for 2 lines
                
                // Product Description
                Text(product.shortDescription)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
                    .frame(height: 14) // Fixed height for 1 line
                
                // Rating and Stock
                HStack {
                    if product.rating > 0 {
                        HStack(spacing: 1) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.caption2)
                            Text(String(format: "%.1f", product.rating))
                                .font(.caption2)
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
                .frame(height: 16) // Fixed height for rating/stock section
                
                // Price
                Text(product.formattedPrice)
                    .font(.callout)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .frame(height: 18) // Fixed height for price
                
                // Action Buttons
                HStack(spacing: 4) {
                    // Add to Cart Button
                    Button(action: {
                        cartDataManager.addToCart(product: product)
                    }) {
                        HStack(spacing: 2) {
                            Image(systemName: "cart.badge.plus")
                                .font(.caption2)
                            Text("Add")
                                .font(.caption2)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue)
                        .cornerRadius(4)
                    }
                    .disabled(!product.isInStock)
                    
                    Spacer()
                    
                    // Wishlist Button
                    Button(action: {
                        if wishlistDataManager.isInWishlist(productId: product.id) {
                            wishlistDataManager.removeFromWishlist(productId: product.id)
                        } else {
                            wishlistDataManager.addToWishlist(product: product)
                        }
                    }) {
                        Image(systemName: wishlistDataManager.isInWishlist(productId: product.id) ? "heart.fill" : "heart")
                            .font(.caption2)
                            .foregroundColor(wishlistDataManager.isInWishlist(productId: product.id) ? .red : .gray)
                            .frame(width: 20, height: 20)
                    }
                }
                .frame(height: 28) // Fixed height for buttons
            }
            .padding(.horizontal, 2)
        }
        .padding(8)
        .frame(height: 250) // Fixed height to prevent overlapping
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.08), radius: 2, x: 0, y: 1)
        .onTapGesture {
            onTap()
        }
    }
}