//
//  NestedSubCategory+CoreDataProperties.swift
//  Alzahrani
//
//  Created by Hardwin on 22/05/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation
import CoreData


extension NestedSubCategory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NestedSubCategory> {
        return NSFetchRequest<NestedSubCategory>(entityName: "NestedSubCategory");
    }

    @NSManaged public var name: String?
    @NSManaged public var parentId: String?
    @NSManaged public var nestedCategoryId: String?

}
