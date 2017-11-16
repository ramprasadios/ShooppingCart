//
//  Product+Extension.swift
//  Alzahrani
//
//  Created by Hardwin on 29/05/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation
import MagicalRecord

extension Product {
    
    class func getAllProducts(matchingText text: String, inContext context: NSManagedObjectContext? = nil) ->  [Product]? {
        
        let predicate = NSPredicate(format: "productName CONTAINS[cd] %@", text.lowercased())
        let arNamePredicate = NSPredicate(format: "arName CONTAINS[cd] %@", text)
        let productCodePredicate = NSPredicate(format: "model CONTAINS[cd] %@", text)
        
        let compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate, arNamePredicate, productCodePredicate])
        if let context = context {
            return Product.mr_findAll(with: compoundPredicate, in: context) as! [Product]?
        } else {
            return Product.mr_findAll(with: compoundPredicate) as! [Product]?
        }
    }
    
    class func getProductWith(productId id: String, inContext context: NSManagedObjectContext? = nil) -> Product? {
        let predicate = NSPredicate(format: "productId == %@", id)
        if let context = context {
            return Product.mr_findFirst(with: predicate, in: context)
        } else {
            return Product.mr_findFirst(with: predicate)
        }
    }
    
    class func getProductWith(categoryId id: String, inContext context: NSManagedObjectContext? = nil) -> Product? {
        let predicate = NSPredicate(format: "prodCategoryId == %@", id)
        if let context = context {
            return Product.mr_findFirst(with: predicate, in: context)
        } else {
            return Product.mr_findFirst(with: predicate)
        }
    }
    
    class func getAllProducts(inContext context: NSManagedObjectContext? = nil) -> [Product]? {
        if let context = context {
            return Product.mr_findAll(in: context) as! [Product]?
        } else {
            return Product.mr_findAll() as! [Product]?
        }
    }
    
    class func deleteAllProducts(inContext context: NSManagedObjectContext? = nil) {
        if let context = context {
            let _ = self.getAllProducts(inContext: context)
        } else {
            if let products = self.getAllProducts() {
                for product in products {
                    do {
                        product.mr_deleteEntity()
                        try product.managedObjectContext?.save()
                    } catch {
                        print("Error Saving Changes")
                    }
                }
            }
        }
    }
    
    class func getAllProductsWith(preducateInfo info: String
        , withPredicate predicate: NSPredicate? = nil, isAsssending assending: Bool? = nil, inContext context: NSManagedObjectContext? = nil) -> [Product]? {
        if let context = context {
            return Product.mr_findAllSorted(by: info, ascending: assending!, in: context) as! [Product]?
        } else if let predicate = predicate {
            return Product.mr_findAllSorted(by: info, ascending: assending!, with: predicate) as! [Product]?
        } else {
            return Product.mr_findAllSorted(by: info, ascending: assending!) as! [Product]?
        }
    }
}
