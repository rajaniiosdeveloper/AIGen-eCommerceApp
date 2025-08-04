//
//  WishlistItemEntity+CoreDataClass.swift
//  EnterpriseApp
//
//  Created by AI Assistant
//

import Foundation
import CoreData

@objc(WishlistItemEntity)
public class WishlistItemEntity: NSManagedObject {
    
    var formattedPrice: String {
        return "₹\(String(format: "%.2f", productPrice))"
    }
    
    func toWishlistItem() -> WishlistItem {
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
        
        return WishlistItem(product: product)
    }
}