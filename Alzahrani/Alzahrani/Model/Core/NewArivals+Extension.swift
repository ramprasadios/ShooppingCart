//
//  NewArivals+Extension.swift
//  Alzahrani
//
//  Created by Hardwin on 10/06/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation
import UIKit
import MagicalRecord

extension NewArrival {
    
    class func getAllNewArrivals(inContext context: NSManagedObjectContext? = nil) -> [NewArrival]? {
        
        if let context = context {
            return NewArrival.mr_findAll(in: context) as! [NewArrival]?
        } else {
            return NewArrival.mr_findAll() as! [NewArrival]?
        }
    }
    
    class func getNewArrivalProductWith(prodId id: String, inContext context: NSManagedObjectContext? = nil) -> NewArrival? {
        let predicate = NSPredicate(format: "productId == %@", id)
        if let context = context {
            return NewArrival.mr_findFirst(with: predicate, in: context)
        } else {
            return NewArrival.mr_findFirst(with: predicate)
        }
    }
}
