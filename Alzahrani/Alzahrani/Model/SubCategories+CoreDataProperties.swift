//
//  SubCategories+CoreDataProperties.swift
//  Alzahrani
//
//  Created by Hardwin on 19/05/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation
import CoreData


extension SubCategories {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SubCategories> {
        return NSFetchRequest<SubCategories>(entityName: "SubCategories");
    }

    @NSManaged public var parentId: String?
    @NSManaged public var name: String?
    @NSManaged public var subCategoryId: String?
    @NSManaged public var productCategory: ProductCategory?

}
