//
//  Banners+CoreDataProperties.swift
//  Alzahrani
//
//  Created by Prakash on 19/07/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation
import CoreData


extension Banners {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Banners> {
        return NSFetchRequest<Banners>(entityName: "Banners");
    }

    @NSManaged public var categoryId: String?
    @NSManaged public var categoryName: String?
    @NSManaged public var image: String?
    @NSManaged public var imageData: NSData?
    @NSManaged public var menuType: String?
    @NSManaged public var name: String?

}
