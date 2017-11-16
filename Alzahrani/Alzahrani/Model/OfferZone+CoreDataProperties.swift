//
//  OfferZone+CoreDataProperties.swift
//  Alzahrani
//
//  Created by Prakash on 19/07/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation
import CoreData


extension OfferZone {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<OfferZone> {
        return NSFetchRequest<OfferZone>(entityName: "OfferZone");
    }

    @NSManaged public var image: String?
    @NSManaged public var imageData: NSData?
    @NSManaged public var linkId: String?
    @NSManaged public var prodName: String?
    @NSManaged public var menuType: String?
    @NSManaged public var name: String?

}
