//
//  SubCategories+Extension.swift
//  Alzahrani
//
//  Created by Hardwin on 19/05/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation
import UIKit
import MagicalRecord

extension SubCategories {
    
    class func getAllSubCategories(inContext context: NSManagedObjectContext? = nil) -> [SubCategories]? {
        
        if let context = context {
            return SubCategories.mr_findAll(in: context) as! [SubCategories]?
        } else {
            return SubCategories.mr_findAll() as! [SubCategories]?
        }
    }
    
    class func getSubCategoriesBy(parentId id: String, inContext context: NSManagedObjectContext? = nil) -> [SubCategories]? {
        let predicate = NSPredicate(format: "parentId = %@", id)
        if let context = context {
            return SubCategories.mr_findAll(with: predicate, in: context) as? [SubCategories]
        } else {
            return SubCategories.mr_findAll(with: predicate) as? [SubCategories]
        }
    }
    
    class func getAllSubCategories(matchingText text: String, inContext context: NSManagedObjectContext? = nil) ->  [SubCategories]? {
        
        let predicate = NSPredicate(format: "name CONTAINS[cd] %@", text.lowercased())
        if let context = context {
            return Product.mr_findAll(with: predicate, in: context) as! [SubCategories]?
        } else {
            return Product.mr_findAll(with: predicate) as! [SubCategories]?
        }
    }
    
}
