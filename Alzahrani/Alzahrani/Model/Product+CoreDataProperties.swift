//
//  Product+CoreDataProperties.swift
//  Alzahrani
//
//  Created by Ashok Kumar on 04/10/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation
import CoreData


extension Product {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Product> {
        return NSFetchRequest<Product>(entityName: "Product");
    }

    @NSManaged public var arDescription: String?
    @NSManaged public var arName: String?
    @NSManaged public var arStockStatus: String?
    @NSManaged public var availability: Int16
    @NSManaged public var image: String?
    @NSManaged public var imageData: NSData?
    @NSManaged public var isInCart: Bool
    @NSManaged public var isProductLiked: Bool
    @NSManaged public var manufacturerId: Int32
    @NSManaged public var maxQuanity: Int16
    @NSManaged public var minQuantity: Int16
    @NSManaged public var model: String?
    @NSManaged public var price: Double
    @NSManaged public var prodCategoryId: String?
    @NSManaged public var productDescription: String?
    @NSManaged public var productId: String?
    @NSManaged public var productName: String?
    @NSManaged public var productViewedCount: Int32
    @NSManaged public var reviews: String?
    @NSManaged public var soldQuantity: String?
    @NSManaged public var specialPrice: String?
    @NSManaged public var stockStatus: String?
    @NSManaged public var stockStatusId: String?
    @NSManaged public var section: Product?
    @NSManaged public var specifications: NSSet?

}

// MARK: Generated accessors for specifications
extension Product {

    @objc(addSpecificationsObject:)
    @NSManaged public func addToSpecifications(_ value: Specifications)

    @objc(removeSpecificationsObject:)
    @NSManaged public func removeFromSpecifications(_ value: Specifications)

    @objc(addSpecifications:)
    @NSManaged public func addToSpecifications(_ values: NSSet)

    @objc(removeSpecifications:)
    @NSManaged public func removeFromSpecifications(_ values: NSSet)

}
