//
//  OfflineProducts+CoreDataProperties.swift
//  Alzahrani
//
//  Created by Ashok Kumar on 15/09/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation
import CoreData


extension OfflineProducts {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<OfflineProducts> {
        return NSFetchRequest<OfflineProducts>(entityName: "OfflineProducts");
    }

    @NSManaged public var productId: String?
    @NSManaged public var quantity: String?
    @NSManaged public var order: Orders?

}
