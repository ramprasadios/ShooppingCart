//
//  WishListHandler.swift
//  Alzahrani
//
//  Created by Hardwin on 21/06/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation
import UIKit

struct WishListProducts {
    let productId: String
    let productName: String
    
    init(withProdId id: String, andProdName name: String) {
        self.productId = id
        self.productName = name
    }
}
class WishListHandler: NSObject {
    
    class var sharedInstance: WishListHandler {
        struct Static {
            static let instance = WishListHandler()
        }
        return Static.instance
    }
    
    var wishListProdArray = [WishListProducts]()
    
    func addWishListProduct(withInfo prodInfo: WishListProducts) {
        self.wishListProdArray.append(prodInfo)
    }
    
    func removeProduct(withInfo prodInfo: WishListProducts) {
        for (index, wishListProd) in self.wishListProdArray.enumerated() {
            if wishListProd.productId == prodInfo.productId {
                self.wishListProdArray.remove(at: index)
            }
        }
    }
    
    func checkForWishListProdWith(prodId id: String) -> Bool {
        var retVal: Bool = false
        for wishListProd in self.wishListProdArray {
            if wishListProd.productId == id {
                retVal = true
                break
            } else {
                retVal = false
                continue
            }
        }
        return retVal
    }
    
    func removeDuplicates(withInfo prodInfo: WishListProducts) {
        for (index, wishListProd) in self.wishListProdArray.enumerated() {
            if wishListProd.productId != prodInfo.productId {
                self.wishListProdArray.append(prodInfo)
            } else {
                self.wishListProdArray.remove(at: index)
            }
        }
    }
}
