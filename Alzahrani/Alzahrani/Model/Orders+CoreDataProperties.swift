//
//  Orders+CoreDataProperties.swift
//  Alzahrani
//
//  Created by Ashok Kumar on 15/09/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation
import CoreData


extension Orders {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Orders> {
        return NSFetchRequest<Orders>(entityName: "Orders");
    }

    @NSManaged public var offlineOrder: String?
    @NSManaged public var offlineProduct: NSSet?

}

// MARK: Generated accessors for offlineProduct
extension Orders {

    @objc(addOfflineProductObject:)
    @NSManaged public func addToOfflineProduct(_ value: OfflineProducts)

    @objc(removeOfflineProductObject:)
    @NSManaged public func removeFromOfflineProduct(_ value: OfflineProducts)

    @objc(addOfflineProduct:)
    @NSManaged public func addToOfflineProduct(_ values: NSSet)

    @objc(removeOfflineProduct:)
    @NSManaged public func removeFromOfflineProduct(_ values: NSSet)

}
