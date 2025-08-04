//
//  TopNavigationBarView.swift
//  EnterpriseApp
//
//  Created by AI Assistant
//

import SwiftUI

struct TopNavigationBarView: View {
    @EnvironmentObject var store: AppStore
    let onCartTap: () -> Void
    let onWishlistTap: () -> Void
    
    var body: some View {
        HStack {
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
                        
                        if store.wishlistItemCount > 0 {
                            Text("\(store.wishlistItemCount)")
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
                        
                        if store.cartItemCount > 0 {
                            Text("\(store.cartItemCount)")
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
        onCartTap: {},
        onWishlistTap: {}
    )
    .environmentObject(AppStore.shared)
}