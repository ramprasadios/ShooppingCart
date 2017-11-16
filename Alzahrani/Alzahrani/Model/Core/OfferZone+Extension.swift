//
//  OfferZone+Extension.swift
//  Alzahrani
//
//  Created by Hardwin on 14/06/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation
import MagicalRecord

extension OfferZone {
    
    class func getAllOffersList(inContext context: NSManagedObjectContext? = nil) -> [OfferZone]? {
        
        if let context = context {
            return OfferZone.mr_findAll(in: context) as! [OfferZone]?
        } else {
            return OfferZone.mr_findAll() as! [OfferZone]?
        }
    }
}
