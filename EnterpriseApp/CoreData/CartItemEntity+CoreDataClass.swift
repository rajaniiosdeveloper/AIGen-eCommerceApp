//
//  CartItemEntity+CoreDataClass.swift
//  EnterpriseApp
//
//  Created by AI Assistant
//

import Foundation
import CoreData

@objc(CartItemEntity)
public class CartItemEntity: NSManagedObject {
    
    var totalPrice: Double {
        return productPrice * Double(quantity)
    }
    
    var formattedPrice: String {
        return "₹\(String(format: "%.2f", productPrice))"
    }
    
    var formattedTotalPrice: String {
        return "₹\(String(format: "%.2f", totalPrice))"
    }
    
    func toCartItem() -> CartItem {
        let product = Product(
            id: productId ?? "",
            title: productTitle ?? "",
            description: "",
            price: productPrice,
            imageURL: productImageURL ?? "",
            category: "",
            rating: 0,
            stock: 10,
            brand: ""
        )
        
        return CartItem(product: product, quantity: Int(quantity))
    }
}