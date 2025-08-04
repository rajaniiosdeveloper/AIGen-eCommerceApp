//
//  HomeView.swift
//  EnterpriseApp
//
//  Created by AI Assistant
//

import SwiftUI
import Combine

// MARK: - Home View (VIPER)
struct HomeView: View {
    @StateObject private var presenter = HomePresenter()
    
    let onProductTap: (Product) -> Void
    let onCartTap: () -> Void
    let onWishlistTap: () -> Void
    let onMenuTap: () -> Void
    
    // Removed grid columns - using list view now
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Navigation Bar
            TopNavigationBarView(
                onMenuTap: onMenuTap,
                onCartTap: onCartTap,
                onWishlistTap: onWishlistTap
            )
            
            // Category Selector
            if !presenter.categories.isEmpty {
                CategorySelectorView(
                    categories: presenter.categories,
                    selectedCategory: $presenter.selectedCategory,
                    onCategorySelected: { category in
                        presenter.selectCategory(category)
                    }
                )
                .padding(.vertical, 8)
            }
            
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search products...", text: $presenter.searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if !presenter.searchText.isEmpty {
                    Button("Clear") {
                        presenter.searchText = ""
                    }
                    .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            
            // Content - List View
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(presenter.filteredProducts) { product in
                        ProductListRowView(product: product) {
                            onProductTap(product)
                        }
                    }
                }
                .padding(.horizontal, 20) // Side spacing from screen edges
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
            .refreshable {
                presenter.fetchProducts()
            }
        }
        .background(Color(.systemGroupedBackground))
        .overlay(
            Group {
                if presenter.isLoading && presenter.products.isEmpty {
                    ProgressView("Loading products...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemBackground))
                }
            }
        )
        .alert("Error", isPresented: .constant(presenter.errorMessage != nil)) {
            Button("OK") {
                presenter.clearError()
            }
            Button("Retry") {
                presenter.fetchProducts()
            }
        } message: {
            Text(presenter.errorMessage ?? "")
        }
        .onAppear {
            if presenter.products.isEmpty {
                presenter.fetchProducts()
            }
            if presenter.categories.isEmpty {
                presenter.fetchCategories()
            }
        }
    }
}

// MARK: - Product List Row View for List Layout
struct ProductListRowView: View {
    let product: Product
    let onTap: () -> Void
    @StateObject private var cartDataManager = CartDataManager.shared
    @StateObject private var wishlistDataManager = WishlistDataManager.shared
    
    var body: some View {
        HStack(spacing: 12) {
            // Product Image
            AsyncImageView(
                url: product.imageURL,
                width: 80,
                height: 80,
                contentMode: .fill
            )
            .cornerRadius(8)
            
            // Product Info
            VStack(alignment: .leading, spacing: 4) {
                Text(product.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Text(product.shortDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
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
                    
                    Text(product.formattedPrice)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
            }
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: 8) {
                // Wishlist Button
                Button(action: {
                    if wishlistDataManager.isInWishlist(productId: product.id) {
                        wishlistDataManager.removeFromWishlist(productId: product.id)
                    } else {
                        wishlistDataManager.addToWishlist(product: product)
                    }
                }) {
                    Image(systemName: wishlistDataManager.isInWishlist(productId: product.id) ? "heart.fill" : "heart")
                        .font(.title2)
                        .foregroundColor(wishlistDataManager.isInWishlist(productId: product.id) ? .red : .gray)
                        .frame(width: 32, height: 32)
                }
                
                // Add to Cart Button
                Button(action: {
                    cartDataManager.addToCart(product: product)
                }) {
                    Image(systemName: "cart.badge.plus")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(product.isInStock ? Color.blue : Color.gray)
                        .cornerRadius(8)
                }
                .disabled(!product.isInStock)
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Legacy components (will be removed)
// The new HomePresenter and HomeInteractor are now in separate files

// MARK: - Preview
#Preview {
    HomeView(
        onProductTap: { _ in },
        onCartTap: {},
        onWishlistTap: {},
        onMenuTap: {}
    )
}