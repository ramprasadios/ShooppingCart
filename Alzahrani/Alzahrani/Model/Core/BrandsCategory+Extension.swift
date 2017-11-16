//
//  BrandsCategory+Extension.swift
//  Alzahrani
//
//  Created by Ashok Kumar on 18/09/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation
import MagicalRecord

extension BrandsCategory {
	
	class func getAllBrands(ofCategoryId id: String, inContext context: NSManagedObjectContext? = nil) -> [BrandsCategory]? {
		let predicate = NSPredicate(format: "categoryId = %@", id)
		if let context = context {
			return BrandsCategory.mr_findAll(with: predicate, in: context) as! [BrandsCategory]?
		} else {
			return BrandsCategory.mr_findAll(with: predicate) as! [BrandsCategory]?
		}
	}
}
