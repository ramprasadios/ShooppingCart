//
//  Sections+CoreDataProperties.swift
//  Alzahrani
//
//  Created by Ashok Kumar on 04/09/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation
import CoreData


extension Sections {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Sections> {
        return NSFetchRequest<Sections>(entityName: "Sections");
    }

    @NSManaged public var sectionName: String?
    @NSManaged public var products: NSSet?
    @NSManaged public var homeProducts: HomeProducts?

}

// MARK: Generated accessors for products
extension Sections {

    @objc(addProductsObject:)
    @NSManaged public func addToProducts(_ value: Product)

    @objc(removeProductsObject:)
    @NSManaged public func removeFromProducts(_ value: Product)

    @objc(addProducts:)
    @NSManaged public func addToProducts(_ values: NSSet)

    @objc(removeProducts:)
    @NSManaged public func removeFromProducts(_ values: NSSet)

}
