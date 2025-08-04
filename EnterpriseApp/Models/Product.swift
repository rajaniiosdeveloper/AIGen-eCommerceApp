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

// MARK: - API Response Models
struct ProductsResponse: Codable {
    let products: [Product]
    let total: Int
    let skip: Int
    let limit: Int
}

struct APIError: Error, Codable {
    let message: String
    let code: Int
}