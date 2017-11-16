//
//  Sections+Extension.swift
//  Alzahrani
//
//  Created by Ashok Kumar on 05/09/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation
import MagicalRecord

extension Sections {
	
	class func getAllSectionsList(inContext context: NSManagedObjectContext? = nil) -> [Sections]? {
		
		let predicate = NSPredicate(format: "ANY products.productId != nil")
		if let context = context {
			return Sections.mr_findAllSorted(by: "sectionName", ascending: true, with: predicate, in: context) as! [Sections]?
			//return Sections.mr_findAll(with: predicate, in: context) as! [Sections]?
		} else {
			return Sections.mr_findAllSorted(by: "sectionName", ascending: true, with: predicate) as! [Sections]?
			//return Sections.mr_findAll(with: predicate) as! [Sections]?
		}
	}
}
