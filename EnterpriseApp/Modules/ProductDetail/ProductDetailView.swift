//
//  ProductDetailView.swift
//  EnterpriseApp
//
//  Created by AI Assistant
//

import SwiftUI
import Combine

// MARK: - Product Detail View (VIPER)
struct ProductDetailView: View {
    let product: Product
    @StateObject private var presenter = ProductDetailPresenter()
    @Environment(\.dismiss) private var dismiss
    
    let onBuyNow: (Product) -> Void
    
    @State private var quantity = 1
    @State private var showingAddedToCart = false
    @State private var showingAddedToWishlist = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Product Image
                AsyncImageView(
                    url: product.imageURL,
                    width: nil,
                    height: 300,
                    contentMode: .fill
                )
                .cornerRadius(16)
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 16) {
                    // Product Info
                    VStack(alignment: .leading, spacing: 8) {
                        Text(product.title)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        if !product.brand.isEmpty {
                            Text("by \(product.brand)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            if product.rating > 0 {
                                HStack(spacing: 4) {
                                    ForEach(0..<5, id: \.self) { index in
                                        Image(systemName: "star.fill")
                                            .foregroundColor(index < Int(product.rating) ? .yellow : .gray.opacity(0.3))
                                            .font(.caption)
                                    }
                                    Text(String(format: "%.1f", product.rating))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            Text(product.category)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(8)
                        }
                    }
                    
                    // Price
                    Text(product.formattedPrice)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    // Stock Info
                    HStack {
                        Image(systemName: product.isInStock ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(product.isInStock ? .green : .red)
                        
                        Text(product.isInStock ? "In Stock (\(product.stock) available)" : "Out of Stock")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(product.isInStock ? .green : .red)
                    }
                    
                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(product.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                    }
                    
                    // Quantity Selector
                    if product.isInStock {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Quantity")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            HStack {
                                Button(action: {
                                    if quantity > 1 {
                                        quantity -= 1
                                    }
                                }) {
                                    Image(systemName: "minus")
                                        .font(.title3)
                                        .foregroundColor(.primary)
                                        .frame(width: 44, height: 44)
                                        .background(Color(.systemGray5))
                                        .cornerRadius(8)
                                }
                                .disabled(quantity <= 1)
                                
                                Text("\(quantity)")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .frame(minWidth: 40)
                                
                                Button(action: {
                                    if quantity < product.stock {
                                        quantity += 1
                                    }
                                }) {
                                    Image(systemName: "plus")
                                        .font(.title3)
                                        .foregroundColor(.primary)
                                        .frame(width: 44, height: 44)
                                        .background(Color(.systemGray5))
                                        .cornerRadius(8)
                                }
                                .disabled(quantity >= product.stock)
                                
                                Spacer()
                                
                                Text("₹\(String(format: "%.2f", product.price * Double(quantity)))")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        // Add to Cart & Wishlist Row
                        HStack(spacing: 12) {
                            Button(action: {
                                presenter.addToCart(product: product, quantity: quantity)
                                showingAddedToCart = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    showingAddedToCart = false
                                }
                            }) {
                                HStack {
                                    Image(systemName: "cart.badge.plus")
                                    Text("Add to Cart")
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(product.isInStock ? Color.blue : Color.gray)
                                .cornerRadius(12)
                            }
                            .disabled(!product.isInStock)
                            
                            Button(action: {
                                if presenter.isInWishlist(productId: product.id) {
                                    presenter.removeFromWishlist(productId: product.id)
                                } else {
                                    presenter.addToWishlist(product: product)
                                    showingAddedToWishlist = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        showingAddedToWishlist = false
                                    }
                                }
                            }) {
                                Image(systemName: presenter.isInWishlist(productId: product.id) ? "heart.fill" : "heart")
                                    .font(.title3)
                                    .foregroundColor(presenter.isInWishlist(productId: product.id) ? .red : .gray)
                                    .frame(width: 50, height: 50)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                            }
                        }
                        
                        // Buy Now Button
                        Button(action: {
                            onBuyNow(product)
                        }) {
                            HStack {
                                Image(systemName: "creditcard")
                                Text("Buy Now")
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(product.isInStock ? Color.green : Color.gray)
                            .cornerRadius(12)
                        }
                        .disabled(!product.isInStock)
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary)
                }
            }
        }
        .overlay(
            Group {
                if showingAddedToCart {
                    VStack {
                        Spacer()
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Added to Cart!")
                                .fontWeight(.semibold)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 8)
                        .padding(.bottom, 100)
                    }
                    .transition(.move(edge: .bottom))
                    .animation(.spring(), value: showingAddedToCart)
                }
                
                if showingAddedToWishlist {
                    VStack {
                        Spacer()
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                            Text("Added to Wishlist!")
                                .fontWeight(.semibold)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 8)
                        .padding(.bottom, 100)
                    }
                    .transition(.move(edge: .bottom))
                    .animation(.spring(), value: showingAddedToWishlist)
                }
            }
        )
    }
}

// MARK: - Product Detail Presenter (VIPER)
class ProductDetailPresenter: ObservableObject {
    private let cartInteractor = CartInteractor()
    private let wishlistInteractor = WishlistInteractor()
    
    func addToCart(product: Product, quantity: Int) {
        cartInteractor.addToCart(product: product, quantity: quantity)
    }
    
    func addToWishlist(product: Product) {
        wishlistInteractor.addToWishlist(product: product)
    }
    
    func removeFromWishlist(productId: String) {
        wishlistInteractor.removeFromWishlist(productId: productId)
    }
    
    func isInWishlist(productId: String) -> Bool {
        return wishlistInteractor.isInWishlist(productId: productId)
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        ProductDetailView(
            product: MockData.sampleProducts[0],
            onBuyNow: { _ in }
        )
    }
}