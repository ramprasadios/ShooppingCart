//
//  BrandsCategory+CoreDataProperties.swift
//  Alzahrani
//
//  Created by Ashok Kumar on 18/09/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation
import CoreData


extension BrandsCategory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BrandsCategory> {
        return NSFetchRequest<BrandsCategory>(entityName: "BrandsCategory");
    }

    @NSManaged public var categoryId: String?
    @NSManaged public var manufactureId: String?

}
