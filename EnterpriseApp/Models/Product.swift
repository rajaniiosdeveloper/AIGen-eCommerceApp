//
//  Product.swift
//  EnterpriseApp
//
//  Created by AI Assistant
//

import Foundation

// MARK: - Product Entity
struct Product: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let description: String
    let shortDescription: String
    let price: Double
    let imageURL: String
    let category: String
    let rating: Double
    let stock: Int
    let brand: String
    
    init(id: String = UUID().uuidString,
         title: String,
         description: String,
         shortDescription: String = "",
         price: Double,
         imageURL: String,
         category: String = "General",
         rating: Double = 0.0,
         stock: Int = 10,
         brand: String = "") {
        self.id = id
        self.title = title
        self.description = description
        self.shortDescription = shortDescription.isEmpty ? String(description.prefix(80)) + "..." : shortDescription
        self.price = price
        self.imageURL = imageURL
        self.category = category
        self.rating = rating
        self.stock = stock
        self.brand = brand
    }
    
    var formattedPrice: String {
        return "₹\(String(format: "%.2f", price))"
    }
    
    var isInStock: Bool {
        return stock > 0
    }
}

// MARK: - Cart Item Entity
struct CartItem: Identifiable, Codable {
    let id: String
    let product: Product
    var quantity: Int
    let dateAdded: Date
    
    init(product: Product, quantity: Int = 1) {
        self.id = UUID().uuidString
        self.product = product
        self.quantity = quantity
        self.dateAdded = Date()
    }
    
    var totalPrice: Double {
        return product.price * Double(quantity)
    }
    
    var formattedTotalPrice: String {
        return "₹\(String(format: "%.2f", totalPrice))"
    }
}

// MARK: - Wishlist Item Entity
struct WishlistItem: Identifiable, Codable {
    let id: String
    let product: Product
    let dateAdded: Date
    
    init(product: Product) {
        self.id = UUID().uuidString
        self.product = product
        self.dateAdded = Date()
    }
}

// MARK: - User Entity
struct User: Codable {
    let id: String
    let name: String
    let email: String
    
    init(id: String = UUID().uuidString, name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
    }
}

// MARK: - Authentication Models
struct AuthRequest: Codable {
    let email: String
    let password: String
}

struct AuthResponse: Codable {
    let user: User
    let token: String
    let refreshToken: String?
    let expiresIn: Int
}

struct RegisterRequest: Codable {
    let name: String
    let email: String
    let password: String
}

// MARK: - Category Models
struct Category: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let imageURL: String?
    let productCount: Int
    
    init(id: String = UUID().uuidString, name: String, imageURL: String? = nil, productCount: Int = 0) {
        self.id = id
        self.name = name
        self.imageURL = imageURL
        self.productCount = productCount
    }
}

// MARK: - Order Models
struct Order: Identifiable, Codable {
    let id: String
    let userId: String
    let items: [OrderItem]
    let totalAmount: Double
    let status: OrderStatus
    let orderDate: Date
    let deliveryDate: Date?
    let shippingAddress: String
    
    init(id: String = UUID().uuidString,
         userId: String,
         items: [OrderItem],
         totalAmount: Double,
         status: OrderStatus = .pending,
         orderDate: Date = Date(),
         deliveryDate: Date? = nil,
         shippingAddress: String) {
        self.id = id
        self.userId = userId
        self.items = items
        self.totalAmount = totalAmount
        self.status = status
        self.orderDate = orderDate
        self.deliveryDate = deliveryDate
        self.shippingAddress = shippingAddress
    }
    
    var formattedTotal: String {
        return "₹\(String(format: "%.2f", totalAmount))"
    }
    
    var formattedOrderDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: orderDate)
    }
    
    var itemCount: Int {
        return items.reduce(0) { $0 + $1.quantity }
    }
}

struct OrderItem: Identifiable, Codable {
    let id: String
    let productId: String
    let productTitle: String
    let productImageURL: String
    let quantity: Int
    let unitPrice: Double
    let totalPrice: Double
    
    init(id: String = UUID().uuidString,
         productId: String,
         productTitle: String,
         productImageURL: String,
         quantity: Int,
         unitPrice: Double) {
        self.id = id
        self.productId = productId
        self.productTitle = productTitle
        self.productImageURL = productImageURL
        self.quantity = quantity
        self.unitPrice = unitPrice
        self.totalPrice = unitPrice * Double(quantity)
    }
    
    var formattedUnitPrice: String {
        return "₹\(String(format: "%.2f", unitPrice))"
    }
    
    var formattedTotalPrice: String {
        return "₹\(String(format: "%.2f", totalPrice))"
    }
}

enum OrderStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case confirmed = "confirmed"
    case processing = "processing"
    case shipped = "shipped"
    case delivered = "delivered"
    case cancelled = "cancelled"
    
    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .confirmed: return "Confirmed"
        case .processing: return "Processing"
        case .shipped: return "Shipped"
        case .delivered: return "Delivered"
        case .cancelled: return "Cancelled"
        }
    }
    
    var color: String {
        switch self {
        case .pending: return "orange"
        case .confirmed: return "blue"
        case .processing: return "purple"
        case .shipped: return "indigo"
        case .delivered: return "green"
        case .cancelled: return "red"
        }
    }
}

// MARK: - API Response Models
struct ProductsResponse: Codable {
    let products: [Product]
    let total: Int
    let skip: Int
    let limit: Int
}

struct CategoriesResponse: Codable {
    let categories: [Category]
    let total: Int
}

struct OrdersResponse: Codable {
    let orders: [Order]
    let total: Int
    let skip: Int
    let limit: Int
}

struct APIError: Error, Codable {
    let message: String
    let code: Int
}