//
//  WishList+Extension.swift
//  Alzahrani
//
//  Created by Hardwin on 30/05/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation
import MagicalRecord

extension WishLists {
    
    class func addProductToWishList(data: [String: AnyObject]) -> WishLists? {
        
        var wishList: WishLists?
        MagicalRecord.save(blockAndWait: { context in
            wishList = WishLists.mr_import(from: data, in: context)
        })
        return wishList
    }
    
    class func removeAllWishListData(inContext context: NSManagedObjectContext? = nil) {
        if let wishListData = self.getAllWishlists() {
            for wishListProd in wishListData {
                if let context = context {
                    if let productId = wishListProd.productId {
                        let _ = self.removeProduct(withId: productId, inContext: context)
                    }
                } else {
                    if let productId = wishListProd.productId {
                        let _ = self.removeProduct(withId: productId)
                    }
                }
            }
        }
    }
    
    class func removeProduct(withId id: String, inContext context: NSManagedObjectContext? = nil) -> Bool {
        var retVal: Bool = false
        if let context = context {
            if let product = self.getProductWith(productId: id) {
                retVal = product.mr_deleteEntity(in: context)
            }
            do {
                try context.save()
            } catch {
                print("Object Not Deleted")
            }
            return retVal
        } else {
            if let product = self.getProductWith(productId: id) {
                let localMOC = product.managedObjectContext
                localMOC?.delete(product)
                localMOC?.mr_saveToPersistentStoreAndWait()
            }
            return retVal
        }
    }
    
    class func getProductWith(productId id: String, inContext context: NSManagedObjectContext? = nil) -> WishLists? {
        
        let predicate = NSPredicate(format: "productId == %@", id)
        if let context = context {
            return WishLists.mr_findFirst(with: predicate, in: context)
        } else {
            return WishLists.mr_findFirst(with: predicate)
        }
    }
    
    class func getAllWishlists(inContext context: NSManagedObjectContext? = nil) ->  [WishLists]? {
        
        if let context = context {
            return WishLists.mr_findAll(in: context) as! [WishLists]?
        } else {
            return WishLists.mr_findAll() as! [WishLists]?
        }
    }
}


