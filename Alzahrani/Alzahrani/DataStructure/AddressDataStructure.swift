//
//  AddressDataStructure.swift
//  Alzahrani
//
//  Created by Hardwin on 14/06/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation
import UIKit

struct UserAddressData {
    
    let customerId: String
    let customerGroupId: String
    let firstName: String
    let lastName: String
    let company: String
    let company_id: String
    let address1: String
    let address2: String
    let city: String
    let postCode: String
    let country: String
    let countryId: String
    let zone: String
    let zoneId: String
    let paymentCode: String
    
    init(customerId custId: String, _ grpId: String, _ fName: String, _ lName:String, _ company: String,
         _ compId: String, _ addr1: String, _ addr2: String, _ city: String, _ postCode: String, _ country: String,
        _ countryId: String, _ zone: String, _ zoneId: String , _ paymentCode: String) {
        
        self.customerId = custId
        self.customerGroupId = grpId
        self.firstName = fName
        self.lastName = lName
        self.company = company
        self.company_id = compId
        self.address1 = addr1
        self.address2 = addr2
        self.city = city
        self.postCode = postCode
        self.country = country
        self.countryId = countryId
        self.zone = zone
        self.zoneId = zoneId
        self.paymentCode = paymentCode
    }
}

class UserShipppingAddress {
    
    class var sharedInstance: UserShipppingAddress {
        struct Static {
            static let instance = UserShipppingAddress()
        }
        return Static.instance
    }
    
    var userAddressData = [UserAddressData]()
    var userDefaultAddress: UserAddressData!
    
    var userExistingAddressData = [UserAddressData]()
    var deleveryExitingAddressData = [UserAddressData]()
    var billingExitingAddressData = [UserAddressData]()
    
    var deleveryNewAddressData = [UserAddressData]()
    var billingNewAddressData = [UserAddressData]()
    var userNewAddressData = [UserAddressData]()

}
