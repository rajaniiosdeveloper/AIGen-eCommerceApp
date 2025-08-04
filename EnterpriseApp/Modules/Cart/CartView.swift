//
//  CartView.swift
//  EnterpriseApp
//
//  Created by AI Assistant
//

import SwiftUI
import Combine

// MARK: - Cart View (VIPER)
struct CartView: View {
    @StateObject private var presenter = CartPresenter()
    @Environment(\.dismiss) private var dismiss
    
    let onCheckout: () -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                if presenter.cartItems.isEmpty {
                    // Empty Cart State
                    VStack(spacing: 20) {
                        Image(systemName: "cart")
                            .font(.system(size: 80))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("Your cart is empty")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        Text("Add some products to get started")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Continue Shopping")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(Color.blue)
                                .cornerRadius(25)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Cart Items
                    VStack {
                        // Cart Header
                        HStack {
                            Text("My Cart")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Text("\(presenter.cartItemCount) items")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        
                        // Cart Items List
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(presenter.cartItems, id: \.id) { cartItem in
                                    CartItemRowView(cartItem: cartItem, presenter: presenter)
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        Spacer()
                        
                        // Cart Summary
                        VStack(spacing: 16) {
                            Divider()
                                .padding(.horizontal)
                            
                            // Total Section
                            VStack(spacing: 8) {
                                HStack {
                                    Text("Total Items:")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(presenter.cartItemCount)")
                                        .font(.body)
                                        .fontWeight(.semibold)
                                }
                                
                                HStack {
                                    Text("Total Amount:")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Text(presenter.formattedCartTotal)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                }
                            }
                            .padding(.horizontal)
                            
                            // Action Buttons
                            VStack(spacing: 12) {
                                Button(action: onCheckout) {
                                    HStack {
                                        Image(systemName: "creditcard")
                                        Text("Proceed to Checkout")
                                            .fontWeight(.bold)
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.green)
                                    .cornerRadius(12)
                                }
                                
                                Button(action: {
                                    presenter.clearCart()
                                }) {
                                    Text("Clear Cart")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.red)
                                        .padding(.vertical, 12)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom)
                        }
                        .background(Color(.systemBackground))
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Cart Item Row View
struct CartItemRowView: View {
    let cartItem: CartItem
    let presenter: CartPresenter
    
    var body: some View {
        HStack(spacing: 12) {
            // Product Image
            AsyncImageView(
                url: cartItem.product.imageURL,
                width: 80,
                height: 80,
                contentMode: .fill
            )
            .cornerRadius(12)
            
            // Product Info
            VStack(alignment: .leading, spacing: 4) {
                Text(cartItem.product.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                
                Text(cartItem.product.formattedPrice)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(cartItem.formattedTotalPrice)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            // Quantity Controls
            VStack(spacing: 8) {
                HStack(spacing: 12) {
                    Button(action: {
                        presenter.updateCartItemQuantity(
                            productId: cartItem.product.id,
                            quantity: cartItem.quantity - 1
                        )
                    }) {
                        Image(systemName: "minus")
                            .font(.caption)
                            .foregroundColor(.primary)
                            .frame(width: 32, height: 32)
                            .background(Color(.systemGray5))
                            .cornerRadius(6)
                    }
                    .disabled(cartItem.quantity <= 1)
                    
                    Text("\(cartItem.quantity)")
                        .font(.body)
                        .fontWeight(.semibold)
                        .frame(minWidth: 20)
                    
                    Button(action: {
                        presenter.updateCartItemQuantity(
                            productId: cartItem.product.id,
                            quantity: cartItem.quantity + 1
                        )
                    }) {
                        Image(systemName: "plus")
                            .font(.caption)
                            .foregroundColor(.primary)
                            .frame(width: 32, height: 32)
                            .background(Color(.systemGray5))
                            .cornerRadius(6)
                    }
                }
                
                Button(action: {
                    presenter.removeFromCart(productId: cartItem.product.id)
                }) {
                    Text("Remove")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Legacy components (will be removed)
// The new CartPresenter and CartInteractor are now in separate files

// MARK: - Preview
#Preview {
    CartView(onCheckout: {})
}