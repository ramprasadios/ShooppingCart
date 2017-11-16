//
//  NewArrival+CoreDataProperties.swift
//  Alzahrani
//
//  Created by Hardwin on 23/06/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation
import CoreData


extension NewArrival {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NewArrival> {
        return NSFetchRequest<NewArrival>(entityName: "NewArrival");
    }

    @NSManaged public var arDescription: String?
    @NSManaged public var arName: String?
    @NSManaged public var availability: Int16
    @NSManaged public var isInCart: Bool
    @NSManaged public var isProductLiked: Bool
    @NSManaged public var maxQuantity: Int16
    @NSManaged public var minQuantity: Int16
    @NSManaged public var name: String?
    @NSManaged public var price: String?
    @NSManaged public var prodDescription: String?
    @NSManaged public var productCode: String?
    @NSManaged public var productId: String?
    @NSManaged public var productImage: String?
    @NSManaged public var reviews: String?
    @NSManaged public var soldQuantity: String?
    @NSManaged public var specialPrice: String?
    @NSManaged public var stockStatus: String?

}
