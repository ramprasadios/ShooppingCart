//
//  ProductCategories+Extension.swift
//  Alzahrani
//
//  Created by Hardwin on 19/05/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation
import MagicalRecord

extension ProductCategory {
    
    class func getAllProducts(inContext context: NSManagedObjectContext? = nil) -> [ProductCategory]? {
        
        if let context = context {
            return ProductCategory.mr_findAll(in: context) as! [ProductCategory]?
        } else {
            return ProductCategory.mr_findAll() as! [ProductCategory]?
        }
    }
    
    class func getCategoryWith(categoryId id: String, inContext context: NSManagedObjectContext? = nil) -> ProductCategory? {
        
        let predicate = NSPredicate(format: "categoryId == %@", id)
        
        if let context = context {
            return ProductCategory.mr_findFirst(with: predicate, in: context)
        } else {
            return ProductCategory.mr_findFirst(with: predicate)
        }
    }
}
