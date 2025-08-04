//
//  OrderHistoryView.swift
//  EnterpriseApp
//
//  Created by AI Assistant
//

import SwiftUI
import Combine

// MARK: - Order History View
struct OrderHistoryView: View {
    @StateObject private var presenter = OrderHistoryPresenter()
    @StateObject private var authManager = AuthenticationManager.shared
    
    let onOrderTap: (Order) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if presenter.isLoading && presenter.orders.isEmpty {
                    // Loading State
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Loading your orders...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                } else if presenter.orders.isEmpty {
                    // Empty State
                    VStack(spacing: 20) {
                        Image(systemName: "bag.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        
                        VStack(spacing: 8) {
                            Text("No Orders Yet")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Your order history will appear here once you make your first purchase.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                } else {
                    // Orders List
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(presenter.orders) { order in
                                OrderRowView(order: order) {
                                    onOrderTap(order)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .padding(.bottom, 20)
                    }
                    .refreshable {
                        await presenter.refreshOrders()
                    }
                }
            }
            .navigationTitle("Order History")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        // Will be handled by the parent view dismissing the sheet
                    }
                }
            }
            .alert("Error", isPresented: .constant(presenter.errorMessage != nil)) {
                Button("OK") {
                    presenter.clearError()
                }
                Button("Retry") {
                    presenter.fetchOrders()
                }
            } message: {
                Text(presenter.errorMessage ?? "")
            }
        }
        .onAppear {
            if presenter.orders.isEmpty {
                presenter.fetchOrders()
            }
        }
    }
}

// MARK: - Order Row View
struct OrderRowView: View {
    let order: Order
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Header: Order ID and Date
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Order #\(order.id.prefix(8).uppercased())")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(order.formattedOrderDate)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Status Badge
                    Text(order.status.displayName)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(statusColor(for: order.status))
                        .cornerRadius(12)
                }
                
                // Order Items Preview
                HStack(spacing: 8) {
                    // Show first few item images
                    HStack(spacing: -8) {
                        ForEach(Array(order.items.prefix(3).enumerated()), id: \.offset) { index, item in
                            AsyncImageView(
                                url: item.productImageURL,
                                width: 32,
                                height: 32,
                                contentMode: .fill
                            )
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color(.systemBackground), lineWidth: 2)
                            )
                            .zIndex(Double(order.items.count - index))
                        }
                    }
                    
                    // Item count and total
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(order.itemCount) item\(order.itemCount != 1 ? "s" : "")")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text(order.formattedTotal)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Chevron
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(16)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func statusColor(for status: OrderStatus) -> Color {
        switch status {
        case .pending: return .orange
        case .confirmed: return .blue
        case .processing: return .purple
        case .shipped: return .indigo
        case .delivered: return .green
        case .cancelled: return .red
        }
    }
}

// MARK: - Order History Presenter
@MainActor
class OrderHistoryPresenter: ObservableObject {
    @Published var orders: [Order] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let interactor: OrderHistoryInteractorProtocol
    
    init(interactor: OrderHistoryInteractorProtocol = OrderHistoryInteractor()) {
        self.interactor = interactor
    }
    
    func fetchOrders() {
        Task {
            isLoading = true
            errorMessage = nil
            
            do {
                let fetchedOrders = try await interactor.fetchOrders()
                self.orders = fetchedOrders
            } catch {
                self.errorMessage = error.localizedDescription
            }
            
            isLoading = false
        }
    }
    
    func refreshOrders() async {
        do {
            let fetchedOrders = try await interactor.fetchOrders()
            self.orders = fetchedOrders
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
}

// MARK: - Preview
struct OrderHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        OrderHistoryView { _ in
            print("Order tapped")
        }
    }
}