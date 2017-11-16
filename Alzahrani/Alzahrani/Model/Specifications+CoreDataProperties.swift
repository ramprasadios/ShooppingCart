//
//  Specifications+CoreDataProperties.swift
//  Alzahrani
//
//  Created by Ashok Kumar on 04/10/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation
import CoreData


extension Specifications {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Specifications> {
        return NSFetchRequest<Specifications>(entityName: "Specifications");
    }

    @NSManaged public var title: String?
    @NSManaged public var detail: String?
    @NSManaged public var arDetail: String?
    @NSManaged public var arTitle: String?
    @NSManaged public var product: Product?

}
