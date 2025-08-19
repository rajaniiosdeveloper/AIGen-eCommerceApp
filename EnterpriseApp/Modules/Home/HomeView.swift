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
            
            // Content - List View with Infinite Scroll
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(presenter.filteredProducts) { product in
                        ProductListRowView(product: product) {
                            onProductTap(product)
                        }
                        .onAppear {
                            // Trigger load more when approaching the end
                            if product.id == presenter.filteredProducts.last?.id && presenter.hasMoreProducts {
                                presenter.loadMoreProducts()
                            }
                        }
                    }
                    
                    // Loading more indicator
                    if presenter.isLoadingMore {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Loading more products...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 12)
                    }
                    
                    // No more products indicator
                    if !presenter.hasMoreProducts && !presenter.products.isEmpty && !presenter.isLoading {
                        HStack {
                            Image(systemName: "checkmark.circle")
                                .foregroundColor(.green)
                            Text("All products loaded")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 12)
                    }
                }
                .padding(.horizontal, 20) // Side spacing from screen edges
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
            .refreshable {
                presenter.refreshProducts()
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
        .errorToast(
            error: presenter.error,
            onRetry: {
                presenter.refreshProducts()
            },
            onDismiss: {
                presenter.clearError()
            }
        )
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
                    ZStack {
                        Image(systemName: wishlistDataManager.isInWishlist(productId: product.id) ? "heart.fill" : "heart")
                            .font(.title2)
                            .foregroundColor(wishlistDataManager.isInWishlist(productId: product.id) ? .red : .gray)
                            .frame(width: 32, height: 32)
                        
                        if wishlistDataManager.isLoading {
                            ProgressView()
                                .scaleEffect(0.5)
                        }
                    }
                }
                .disabled(wishlistDataManager.isLoading)
                
                // Add to Cart Button
                Button(action: {
                    Task {
                        await cartDataManager.addToCart(product: product)
                    }
                }) {
                    ZStack {
                        Image(systemName: "cart.badge.plus")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(product.isInStock ? Color.blue : Color.gray)
                            .cornerRadius(8)
                        
                        if cartDataManager.isLoading {
                            ProgressView()
                                .scaleEffect(0.5)
                                .tint(.white)
                        }
                    }
                }
                .disabled(!product.isInStock || cartDataManager.isLoading)
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