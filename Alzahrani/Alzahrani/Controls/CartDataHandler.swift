//
//  CartDataHandler.swift
//  Alzahrani
//
//  Created by Hardwin on 21/06/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation
import UIKit

class CartDataHandler: NSObject {
    
    class var sharedInstance: CartDataHandler {
        struct Static {
            static let instance = CartDataHandler()
        }
        return Static.instance
    }
    
    var cartProdArray = [WishListProducts]()
    
    func addCartProduct(withInfo prodInfo: WishListProducts) {
        self.cartProdArray.append(prodInfo)
    }
    
    func removeProduct(withInfo prodInfo: WishListProducts) {
        for (index, wishListProd) in self.cartProdArray.enumerated() {
            if wishListProd.productId == prodInfo.productId {
                self.cartProdArray.remove(at: index)
            }
        }
    }
    
    func checkForCartProdWith(prodId id: String) -> Bool {
        var retVal: Bool = false
        for wishListProd in self.cartProdArray {
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
}
