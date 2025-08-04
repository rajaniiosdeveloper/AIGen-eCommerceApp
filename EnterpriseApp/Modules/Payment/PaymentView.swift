//
//  PaymentView.swift
//  EnterpriseApp
//
//  Created by AI Assistant
//

import SwiftUI
import Combine

// MARK: - Payment View (VIPER)
struct PaymentView: View {
    let product: Product?
    let isFromCart: Bool
    @StateObject private var cartDataManager = CartDataManager.shared
    @StateObject private var presenter = PaymentPresenter()
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedPaymentMethod = PaymentMethod.card
    @State private var showingPaymentSuccess = false
    @State private var isProcessing = false
    
    init(product: Product? = nil, isFromCart: Bool = false) {
        self.product = product
        self.isFromCart = isFromCart
    }
    
    var totalAmount: Double {
        if let product = product {
            return product.price
        } else if isFromCart {
            return cartDataManager.getCartTotal()
        }
        return 0.0
    }
    
    var formattedTotal: String {
        return "₹\(String(format: "%.2f", totalAmount))"
    }
    
    private var orderSummarySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Order Summary")
                .font(.title2)
                .fontWeight(.bold)
            
            if let product = product {
                singleProductView(product)
            } else if isFromCart {
                cartItemsView
            }
        }
    }
    
    private func singleProductView(_ product: Product) -> some View {
        HStack(spacing: 12) {
            AsyncImageView(
                url: product.imageURL,
                width: 60,
                height: 60,
                contentMode: .fill
            )
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(product.formattedPrice)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var cartItemsView: some View {
        VStack(spacing: 12) {
            ForEach(Array(cartDataManager.getCartItems().prefix(3)), id: \.id) { cartItem in
                HStack(spacing: 12) {
                    AsyncImageView(
                        url: cartItem.product.imageURL,
                        width: 50,
                        height: 50,
                        contentMode: .fill
                    )
                    .cornerRadius(8)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(cartItem.product.title)
                            .font(.subheadline)
                            .lineLimit(1)
                        
                        HStack {
                            Text("Qty: \(cartItem.quantity)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text(cartItem.formattedTotalPrice)
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                    }
                    
                    Spacer()
                }
            }
            
            if cartDataManager.getCartItems().count > 3 {
                Text("... and \(cartDataManager.getCartItems().count - 3) more items")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Order Summary
                    orderSummarySection
                    
                    // Payment Method Selection
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Payment Method")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        VStack(spacing: 12) {
                            ForEach(PaymentMethod.allCases, id: \.self) { method in
                                PaymentMethodRowView(
                                    method: method,
                                    isSelected: selectedPaymentMethod == method
                                ) {
                                    selectedPaymentMethod = method
                                }
                            }
                        }
                    }
                    
                    // Total Amount
                    VStack(spacing: 16) {
                        Divider()
                        
                        HStack {
                            Text("Total Amount:")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Text(formattedTotal)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }
                        
                        // Pay Now Button
                        Button(action: {
                            processPayment()
                        }) {
                            HStack {
                                if isProcessing {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .foregroundColor(.white)
                                } else {
                                    Image(systemName: "creditcard")
                                }
                                
                                Text(isProcessing ? "Processing..." : "Pay Now")
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(isProcessing ? Color.gray : Color.green)
                            .cornerRadius(12)
                        }
                        .disabled(isProcessing)
                    }
                }
                .padding()
            }
            .navigationTitle("Payment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingPaymentSuccess) {
            PaymentSuccessView(
                amount: formattedTotal,
                paymentMethod: selectedPaymentMethod.displayName
            ) {
                if isFromCart {
                                            cartDataManager.clearCart()
                }
                dismiss()
            }
        }
    }
    
    private func processPayment() {
        isProcessing = true
        
        // Simulate payment processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isProcessing = false
            showingPaymentSuccess = true
        }
    }
}

// MARK: - Payment Method Enum
enum PaymentMethod: CaseIterable {
    case card
    case upi
    case netBanking
    case wallet
    
    var displayName: String {
        switch self {
        case .card:
            return "Credit/Debit Card"
        case .upi:
            return "UPI"
        case .netBanking:
            return "Net Banking"
        case .wallet:
            return "Digital Wallet"
        }
    }
    
    var icon: String {
        switch self {
        case .card:
            return "creditcard"
        case .upi:
            return "qrcode"
        case .netBanking:
            return "building.columns"
        case .wallet:
            return "wallet.pass"
        }
    }
}

// MARK: - Payment Method Row View
struct PaymentMethodRowView: View {
    let method: PaymentMethod
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: method.icon)
                .font(.title3)
                .foregroundColor(.primary)
                .frame(width: 24)
            
            Text(method.displayName)
                .font(.body)
                .fontWeight(.medium)
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title3)
            } else {
                Image(systemName: "circle")
                    .foregroundColor(.gray)
                    .font(.title3)
            }
        }
        .padding()
        .background(isSelected ? Color.green.opacity(0.1) : Color(.systemGray6))
        .cornerRadius(12)
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Payment Success View
struct PaymentSuccessView: View {
    let amount: String
    let paymentMethod: String
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Success Icon
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            // Success Message
            VStack(spacing: 8) {
                Text("Payment Successful!")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Your order has been placed successfully")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Payment Details
            VStack(spacing: 12) {
                HStack {
                    Text("Amount Paid:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(amount)
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("Payment Method:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(paymentMethod)
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("Transaction ID:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("TXN\(Int.random(in: 100000...999999))")
                        .fontWeight(.semibold)
                        .font(.caption)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            Spacer()
            
            // Continue Shopping Button
            Button(action: onDismiss) {
                Text("Continue Shopping")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
        }
        .padding()
        .interactiveDismissDisabled()
    }
}

// MARK: - Payment Presenter (VIPER)
class PaymentPresenter: ObservableObject {
    private let interactor = PaymentInteractor()
    
    func processPayment() {
        interactor.processPayment()
    }
}

// MARK: - Payment Interactor (VIPER)
class PaymentInteractor {
    func processPayment() {
        // In a real app, this would integrate with a payment gateway
        print("Processing payment...")
    }
}

// MARK: - Preview
#Preview {
    PaymentView(product: MockData.sampleProducts[0])
}