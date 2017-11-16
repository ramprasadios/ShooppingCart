//
//  User+CoreDataProperties.swift
//  Alzahrani
//
//  Created by Ashok Kumar on 14/09/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User");
    }

    @NSManaged public var firstName: String?
    @NSManaged public var lastName: String?
    @NSManaged public var emailAddress: String?
    @NSManaged public var telephone: String?
    @NSManaged public var employeeId: String?
    @NSManaged public var depertment: String?
    @NSManaged public var address: NSSet?

}

// MARK: Generated accessors for address
extension User {

    @objc(addAddressObject:)
    @NSManaged public func addToAddress(_ value: Address)

    @objc(removeAddressObject:)
    @NSManaged public func removeFromAddress(_ value: Address)

    @objc(addAddress:)
    @NSManaged public func addToAddress(_ values: NSSet)

    @objc(removeAddress:)
    @NSManaged public func removeFromAddress(_ values: NSSet)

}
