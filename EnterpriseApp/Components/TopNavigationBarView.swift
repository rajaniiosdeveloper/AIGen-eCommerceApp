//
//  TopNavigationBarView.swift
//  EnterpriseApp
//
//  Created by AI Assistant
//

import SwiftUI

struct TopNavigationBarView: View {
    @StateObject private var cartDataManager = CartDataManager.shared
    @StateObject private var wishlistDataManager = WishlistDataManager.shared
    let onMenuTap: () -> Void
    let onCartTap: () -> Void
    let onWishlistTap: () -> Void
    
    var body: some View {
        HStack {
            // Menu Button
            Button(action: onMenuTap) {
                Image(systemName: "line.3.horizontal")
                    .font(.title3)
                    .foregroundColor(.primary)
            }
            
            // App Title
            Text("ShopEasy")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Spacer()
            
            // Navigation Icons
            HStack(spacing: 20) {
                // Wishlist Icon with Badge
                Button(action: onWishlistTap) {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "heart")
                            .font(.title3)
                            .foregroundColor(.primary)
                        
                        if wishlistDataManager.getWishlistItemCount() > 0 {
                            Text("\(wishlistDataManager.getWishlistItemCount())")
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(minWidth: 16, minHeight: 16)
                                .background(Color.red)
                                .cornerRadius(8)
                                .offset(x: 8, y: -8)
                        }
                    }
                }
                
                // Cart Icon with Badge
                Button(action: onCartTap) {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "cart")
                            .font(.title3)
                            .foregroundColor(.primary)
                        
                        if cartDataManager.getCartItemCount() > 0 {
                            Text("\(cartDataManager.getCartItemCount())")
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(minWidth: 16, minHeight: 16)
                                .background(Color.red)
                                .cornerRadius(8)
                                .offset(x: 8, y: -8)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
    }
}

// MARK: - Preview
#Preview {
    TopNavigationBarView(
        onMenuTap: {},
        onCartTap: {},
        onWishlistTap: {}
    )
}