//
//  WishLists+CoreDataProperties.swift
//  Alzahrani
//
//  Created by Hardwin on 22/07/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation
import CoreData


extension WishLists {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WishLists> {
        return NSFetchRequest<WishLists>(entityName: "WishLists");
    }

    @NSManaged public var availability: String?
    @NSManaged public var image: String?
    @NSManaged public var price: String?
    @NSManaged public var productDesc: String?
    @NSManaged public var productId: String?
    @NSManaged public var productName: String?
    @NSManaged public var arName: String?
    @NSManaged public var specialPrice: String?

}
