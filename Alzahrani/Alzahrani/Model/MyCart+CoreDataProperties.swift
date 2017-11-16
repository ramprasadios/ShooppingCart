//
//  MyCart+CoreDataProperties.swift
//  Alzahrani
//
//  Created by Hardwin on 26/07/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation
import CoreData


extension MyCart {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MyCart> {
        return NSFetchRequest<MyCart>(entityName: "MyCart");
    }

    @NSManaged public var cartId: String?
    @NSManaged public var maxQuantity: String?
    @NSManaged public var minQuantity: String?
    @NSManaged public var price: String?
    @NSManaged public var productId: String?
    @NSManaged public var productImage: String?
    @NSManaged public var productName: String?
    @NSManaged public var productsCount: String?
    @NSManaged public var quantity: String?
    @NSManaged public var totalPrice: String?
    @NSManaged public var cartTotalPrice: String?

}
