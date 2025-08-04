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
    @EnvironmentObject var store: AppStore
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
                
                TextField("Search products...", text: $store.searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if !store.searchText.isEmpty {
                    Button("Clear") {
                        store.searchText = ""
                    }
                    .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            
            // Content
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(store.filteredProducts) { product in
                        ProductCardView(product: product) {
                            onProductTap(product)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            .refreshable {
                store.fetchProducts()
            }
        }
        .background(Color(.systemGroupedBackground))
        .overlay(
            Group {
                if store.isLoading && store.products.isEmpty {
                    ProgressView("Loading products...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemBackground))
                }
            }
        )
        .alert("Error", isPresented: .constant(store.errorMessage != nil)) {
            Button("OK") {
                store.clearError()
            }
            Button("Retry") {
                store.fetchProducts()
            }
        } message: {
            Text(store.errorMessage ?? "")
        }
        .onAppear {
            if store.products.isEmpty {
                store.fetchProducts()
            }
        }
    }
}

// MARK: - Home Presenter (VIPER)
class HomePresenter: ObservableObject {
    private let interactor = HomeInteractor()
    
    func fetchProducts() {
        interactor.fetchProducts()
    }
}

// MARK: - Home Interactor (VIPER)
class HomeInteractor {
    private let networkService: NetworkServiceProtocol = NetworkService.shared
    
    func fetchProducts() {
        AppStore.shared.fetchProducts()
    }
}

// MARK: - Preview
#Preview {
    HomeView(
        onProductTap: { _ in },
        onCartTap: {},
        onWishlistTap: {}
    )
    .environmentObject(AppStore.shared)
}