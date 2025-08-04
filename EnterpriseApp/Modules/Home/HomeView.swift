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
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Navigation Bar
            TopNavigationBarView(
                onCartTap: onCartTap,
                onWishlistTap: onWishlistTap
            )
            
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
            
            // Content
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(presenter.filteredProducts) { product in
                        ProductCardView(product: product) {
                            onProductTap(product)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
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
        onWishlistTap: {}
    )
}