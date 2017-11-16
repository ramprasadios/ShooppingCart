//
//  NestedSubCategory+Extension.swift
//  Alzahrani
//
//  Created by Hardwin on 25/05/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation
import MagicalRecord

extension NestedSubCategory {
    
    class func getAllNestedCategoriesWith(parentId id: String, inContext context: NSManagedObjectContext? = nil) ->  [NestedSubCategory]? {
        let predicate = NSPredicate(format: "parentId = %@", id)
        if let context = context {
            return NestedSubCategory.mr_findAll(with: predicate, in: context) as! [NestedSubCategory]?
        } else {
            return NestedSubCategory.mr_findAll(with: predicate) as! [NestedSubCategory]?
        }
    }
    
    class func getAllNestedCategories(inContext context: NSManagedObjectContext? = nil) -> [NestedSubCategory]? {
        
        if let context = context {
            return NestedSubCategory.mr_findAll(in: context) as! [NestedSubCategory]?
        } else {
            return NestedSubCategory.mr_findAll() as! [NestedSubCategory]?
        }
    }
}
