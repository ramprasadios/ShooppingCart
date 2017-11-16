//
//  Brands+CoreDataProperties.swift
//  Alzahrani
//
//  Created by Hardwin on 20/06/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation
import CoreData


extension Brands {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Brands> {
        return NSFetchRequest<Brands>(entityName: "Brands");
    }

    @NSManaged public var brandImage: String?
    @NSManaged public var brandName: String?
    @NSManaged public var categoryId: String?
    @NSManaged public var manufactureId: String?
    @NSManaged public var brandImageData: NSData?

}
