//
//  TopSelling+CoreDataProperties.swift
//  Alzahrani
//
//  Created by Hardwin on 23/06/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation
import CoreData


extension TopSelling {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TopSelling> {
        return NSFetchRequest<TopSelling>(entityName: "TopSelling");
    }

    @NSManaged public var arDescription: String?
    @NSManaged public var arName: String?
    @NSManaged public var availability: Int16
    @NSManaged public var desc: String?
    @NSManaged public var isInCart: Bool
    @NSManaged public var isProductLiked: Bool
    @NSManaged public var maxQuantity: Int16
    @NSManaged public var minQuantity: Int16
    @NSManaged public var name: String?
    @NSManaged public var price: String?
    @NSManaged public var productCode: String?
    @NSManaged public var productid: String?
    @NSManaged public var productImage: String?
    @NSManaged public var reviews: String?
    @NSManaged public var soldQuantity: String?
    @NSManaged public var specialPrice: String?
    @NSManaged public var stockStatus: String?

}
