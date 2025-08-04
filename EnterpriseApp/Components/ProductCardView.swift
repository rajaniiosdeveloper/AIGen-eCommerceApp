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
    @EnvironmentObject var store: AppStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Product Image
            AsyncImageView(
                url: product.imageURL,
                width: nil,
                height: 180,
                contentMode: .fill
            )
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
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
                HStack(spacing: 8) {
                    // Add to Cart Button
                    Button(action: {
                        store.addToCart(product: product)
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "cart.badge.plus")
                                .font(.caption)
                            Text("Add")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .cornerRadius(6)
                    }
                    .disabled(!product.isInStock)
                    
                    // Wishlist Button
                    Button(action: {
                        if store.isInWishlist(productId: product.id) {
                            store.removeFromWishlist(productId: product.id)
                        } else {
                            store.addToWishlist(product: product)
                        }
                    }) {
                        Image(systemName: store.isInWishlist(productId: product.id) ? "heart.fill" : "heart")
                            .font(.caption)
                            .foregroundColor(store.isInWishlist(productId: product.id) ? .red : .gray)
                            .frame(width: 24, height: 24)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .onTapGesture {
            onTap()
        }
    }
}