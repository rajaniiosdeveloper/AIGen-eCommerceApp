//
//  OrderDetailView.swift
//  EnterpriseApp
//
//  Created by AI Assistant
//

import SwiftUI

// MARK: - Order Detail View
struct OrderDetailView: View {
    let order: Order
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Order Header
                    VStack(spacing: 16) {
                        // Status Circle
                        ZStack {
                            Circle()
                                .fill(statusColor(for: order.status).opacity(0.2))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: statusIcon(for: order.status))
                                .font(.title)
                                .foregroundColor(statusColor(for: order.status))
                        }
                        
                        VStack(spacing: 8) {
                            Text("Order #\(order.id.prefix(8).uppercased())")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(order.status.displayName)
                                .font(.headline)
                                .foregroundColor(statusColor(for: order.status))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 6)
                                .background(statusColor(for: order.status).opacity(0.1))
                                .cornerRadius(20)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Order Information
                    VStack(spacing: 16) {
                        InfoCard(title: "Order Details") {
                            VStack(spacing: 12) {
                                InfoRow(label: "Order Date", value: order.formattedOrderDate)
                                
                                Divider()
                                
                                InfoRow(label: "Items", value: "\(order.itemCount) item\(order.itemCount != 1 ? "s" : "")")
                                
                                Divider()
                                
                                InfoRow(label: "Total Amount", value: order.formattedTotal)
                                
                                if let deliveryDate = order.deliveryDate {
                                    Divider()
                                    InfoRow(label: "Delivery Date", value: formatDate(deliveryDate))
                                }
                            }
                        }
                        
                        // Shipping Address
                        InfoCard(title: "Shipping Address") {
                            Text(order.shippingAddress)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        // Order Items
                        InfoCard(title: "Items Ordered") {
                            VStack(spacing: 16) {
                                ForEach(order.items) { item in
                                    OrderItemRowView(item: item)
                                    
                                    if item.id != order.items.last?.id {
                                        Divider()
                                    }
                                }
                            }
                        }
                        
                        // Order Summary
                        InfoCard(title: "Order Summary") {
                            VStack(spacing: 12) {
                                ForEach(order.items) { item in
                                    HStack {
                                        Text("\(item.quantity)x \(item.productTitle)")
                                            .font(.subheadline)
                                        
                                        Spacer()
                                        
                                        Text(item.formattedTotalPrice)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                    }
                                }
                                
                                Divider()
                                
                                HStack {
                                    Text("Total")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                    
                                    Spacer()
                                    
                                    Text(order.formattedTotal)
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    Spacer()
                }
            }
            .navigationTitle("Order Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        // Will be handled by the parent view dismissing the sheet
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
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
    
    private func statusIcon(for status: OrderStatus) -> String {
        switch status {
        case .pending: return "clock"
        case .confirmed: return "checkmark.circle"
        case .processing: return "gear"
        case .shipped: return "shippingbox"
        case .delivered: return "checkmark.circle.fill"
        case .cancelled: return "xmark.circle"
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Info Card
struct InfoCard<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Info Row
struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

// MARK: - Order Item Row View
struct OrderItemRowView: View {
    let item: OrderItem
    
    var body: some View {
        HStack(spacing: 12) {
            // Product Image
            AsyncImageView(
                url: item.productImageURL,
                width: 60,
                height: 60,
                contentMode: .fill
            )
            .cornerRadius(8)
            
            // Product Info
            VStack(alignment: .leading, spacing: 4) {
                Text(item.productTitle)
                    .font(.headline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                
                HStack {
                    Text("Qty: \(item.quantity)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(item.formattedUnitPrice)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(item.formattedTotalPrice)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                }
            }
            
            Spacer()
        }
    }
}

// MARK: - Preview
struct OrderDetailView_Previews: PreviewProvider {
    static var previews: some View {
        OrderDetailView(order: Order(
            id: "order123",
            userId: "user1",
            items: [
                OrderItem(
                    productId: "1",
                    productTitle: "iPhone 15 Pro",
                    productImageURL: "https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=500",
                    quantity: 1,
                    unitPrice: 134900.00
                ),
                OrderItem(
                    productId: "2",
                    productTitle: "AirPods Pro",
                    productImageURL: "https://images.unsplash.com/photo-1606220945770-b5b6c2c55bf1?w=500",
                    quantity: 2,
                    unitPrice: 24900.00
                )
            ],
            totalAmount: 184700.00,
            status: .delivered,
            orderDate: Date(),
            deliveryDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()),
            shippingAddress: "123 Main St, Mumbai, MH 400001"
        ))
    }
}