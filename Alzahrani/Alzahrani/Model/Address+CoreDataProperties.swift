//
//  Address+CoreDataProperties.swift
//  Alzahrani
//
//  Created by Ashok Kumar on 14/09/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation
import CoreData


extension Address {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Address> {
        return NSFetchRequest<Address>(entityName: "Address");
    }

    @NSManaged public var firstName: String?
    @NSManaged public var lastName: String?
    @NSManaged public var company: String?
    @NSManaged public var address1: String?
    @NSManaged public var address2: String?
    @NSManaged public var city: String?
    @NSManaged public var postCode: String?
    @NSManaged public var country: String?
    @NSManaged public var countryId: String?
    @NSManaged public var zoneId: String?
    @NSManaged public var zoneName: String?
    @NSManaged public var zoneCode: String?
    @NSManaged public var user: User?

}
