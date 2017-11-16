//
//  Address+Extension.swift
//  Alzahrani
//
//  Created by Ashok Kumar on 14/09/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation
import MagicalRecord

extension Address {
	
	class func getAllAddressData(inContext context: NSManagedObjectContext? = nil) -> [Address]? {
		
		if let context = context {
			return Address.mr_findAll(in: context) as! [Address]?
		} else {
			return Address.mr_findAll() as! [Address]?
		}
	}
}
