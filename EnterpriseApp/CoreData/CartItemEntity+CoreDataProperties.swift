//
//  CartItemEntity+CoreDataProperties.swift
//  EnterpriseApp
//
//  Created by AI Assistant
//

import Foundation
import CoreData

extension CartItemEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CartItemEntity> {
        return NSFetchRequest<CartItemEntity>(entityName: "CartItemEntity")
    }

    @NSManaged public var id: String?
    @NSManaged public var productId: String?
    @NSManaged public var productTitle: String?
    @NSManaged public var productPrice: Double
    @NSManaged public var productImageURL: String?
    @NSManaged public var quantity: Int32
    @NSManaged public var dateAdded: Date?

}

extension CartItemEntity : Identifiable {

}