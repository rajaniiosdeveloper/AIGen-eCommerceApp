//
//  WishlistItemEntity+CoreDataProperties.swift
//  EnterpriseApp
//
//  Created by AI Assistant
//

import Foundation
import CoreData

extension WishlistItemEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WishlistItemEntity> {
        return NSFetchRequest<WishlistItemEntity>(entityName: "WishlistItemEntity")
    }

    @NSManaged public var id: String?
    @NSManaged public var productId: String?
    @NSManaged public var productTitle: String?
    @NSManaged public var productPrice: Double
    @NSManaged public var productImageURL: String?
    @NSManaged public var dateAdded: Date?

}

extension WishlistItemEntity : Identifiable {

}