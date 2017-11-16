//
//  TopSelling+Extension.swift
//  Alzahrani
//
//  Created by Hardwin on 25/05/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation
import MagicalRecord

extension TopSelling {
    
    class func getAllTopSellings(inContext context: NSManagedObjectContext? = nil) -> [TopSelling]? {
        
        if let context = context {
            return TopSelling.mr_findAll(in: context) as! [TopSelling]?
        } else {
            return TopSelling.mr_findAll() as! [TopSelling]?
        }
    }
    
    class func getTopSellingProductWith(prodId id: String, inContext context: NSManagedObjectContext? = nil) -> TopSelling? {
        let predicate = NSPredicate(format: "productid == %@", id)
        if let context = context {
            return TopSelling.mr_findFirst(with: predicate, in: context)
        } else {
            return TopSelling.mr_findFirst(with: predicate)
        }
    }
}
