//
//  HomeProducts+CoreDataProperties.swift
//  Alzahrani
//
//  Created by Ashok Kumar on 04/09/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation
import CoreData


extension HomeProducts {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HomeProducts> {
        return NSFetchRequest<HomeProducts>(entityName: "HomeProducts");
    }

    @NSManaged public var sectionName: String?
    @NSManaged public var sections: Sections?

}
