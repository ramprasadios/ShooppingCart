//
//  MyCart+Extension.swift
//  Alzahrani
//
//  Created by Hardwin on 10/06/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation
import MagicalRecord

extension MyCart {
    
    class func addProductToMyCartList(data: [String: AnyObject]) -> MyCart? {
        
        var myCartList: MyCart?
        MagicalRecord.save(blockAndWait: { context in
            myCartList = MyCart.mr_import(from: data, in: context)
        })
        return myCartList
    }
    
    class func removeAllMyCartListData(inContext context: NSManagedObjectContext? = nil) {
        if let myCartData = self.getAllMyCartlist() {
            for myCartProd in myCartData {
                if let context = context {
                    if let productId = myCartProd.productId {
                        let _ = self.removeProduct(withId: productId, inContext: context)
                    }
                } else {
                    if let productId = myCartProd.productId {
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

    class func getProductWith(productId id: String, inContext context: NSManagedObjectContext? = nil) -> MyCart? {
        
        let predicate = NSPredicate(format: "productId == %@", id)
        if let context = context {
            return MyCart.mr_findFirst(with: predicate, in: context)
        } else {
            return MyCart.mr_findFirst(with: predicate)
        }
    }
    
    class func getAllMyCartlist(inContext context: NSManagedObjectContext? = nil) ->  [MyCart]? {
        if let context = context {
            return MyCart.mr_findAll(in: context) as! [MyCart]?
        } else {
            return MyCart.mr_findAll() as! [MyCart]?
        }
    }
}
