//
//  ProductCategory+CoreDataProperties.swift
//  Alzahrani
//
//  Created by Ashok Kumar on 15/09/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation
import CoreData


extension ProductCategory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProductCategory> {
        return NSFetchRequest<ProductCategory>(entityName: "ProductCategory");
    }

    @NSManaged public var categoryId: String?
    @NSManaged public var imageURL: String?
    @NSManaged public var name: String?
    @NSManaged public var imageData: NSData?
    @NSManaged public var subCategories: NSSet?

}

// MARK: Generated accessors for subCategories
extension ProductCategory {

    @objc(addSubCategoriesObject:)
    @NSManaged public func addToSubCategories(_ value: SubCategories)

    @objc(removeSubCategoriesObject:)
    @NSManaged public func removeFromSubCategories(_ value: SubCategories)

    @objc(addSubCategories:)
    @NSManaged public func addToSubCategories(_ values: NSSet)

    @objc(removeSubCategories:)
    @NSManaged public func removeFromSubCategories(_ values: NSSet)

}
