//
//  Orders+Extension.swift
//  Alzahrani
//
//  Created by Ashok Kumar on 14/09/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation
import MagicalRecord

extension Orders {
	
	class func getAllOrdersData(inContext context: NSManagedObjectContext? = nil) -> [Orders]? {
		
		if let context = context {
			return Orders.mr_findAll(in: context) as! [Orders]?
		} else {
			return Orders.mr_findAll() as! [Orders]?
		}
	}
}
