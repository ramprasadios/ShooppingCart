//
//  Brands+Extension.swift
//  Alzahrani
//
//  Created by Hardwin on 01/06/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation
import MagicalRecord

extension Brands {
    
    class func getBrandWith(id: String, inContext context: NSManagedObjectContext? = nil) -> Brands? {
        
        let predicate = NSPredicate(format: "categoryId = %@", id)
        if let context = context {
            return Brands.mr_findFirst(with: predicate, in: context)
        } else {
            return Brands.mr_findFirst(with: predicate)
        }
    }
    
    class func getAllBrands(inContext context: NSManagedObjectContext? = nil) -> [Brands]? {
        
        if let context = context {
            return Brands.mr_findAll(in: context) as! [Brands]?
        } else {
            return Brands.mr_findAll() as! [Brands]?
        }
    }
    
    class func getBrandWith(manufacturer id: Int32, inContext context: NSManagedObjectContext? = nil) -> Brands? {
        
        let predicate = NSPredicate(format: "manufactureId = %@", id.description)
        if let context = context {
            return Brands.mr_findFirst(with: predicate, in: context)
        } else {
            return Brands.mr_findFirst(with: predicate)
        }
    }
}
