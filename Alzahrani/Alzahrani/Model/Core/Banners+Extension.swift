//
//  Banners+Extension.swift
//  Alzahrani
//
//  Created by Hardwin on 11/06/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation
import MagicalRecord

extension Banners {
    
    class func getAllBannersData(inContext context: NSManagedObjectContext? = nil) -> [Banners]? {
        
        if let context = context {
            return Banners.mr_findAll(in: context) as! [Banners]?
        } else {
            return Banners.mr_findAll() as! [Banners]?
        }
    }
    
    class func deleteAllRecords(inContext context: NSManagedObjectContext? = nil) {
        
        let bannersData = self.getAllBannersData()
        for banner in bannersData! {
            banner.mr_deleteEntity()
            do {
                try banner.managedObjectContext?.save()
            } catch {
                print("Changes Saved")
            }
        }
    }
}
