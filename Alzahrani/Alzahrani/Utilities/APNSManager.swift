//
//  APNSManager.swift
//  Alzahrani
//
//  Created by Hardwin on 11/07/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation

class APNSManager: NSObject {
    
    class func handlePushNotification(withPayload payload: [String: AnyObject]) {
        var productDict = [String: AnyObject]()
        if let productId = payload["product_id"] as? String {
            if AppManager.currentApplicationMode() == .offline {
                if let product = Product.getProductWith(productId: productId) {
                    let productData = self.getProductData(withProduct: product)
                    productDict["productData"] = productData as AnyObject?
                    NotificationCenter.default.post(name: Notification.Name("ShowProductNotification"), object: productDict)
                }
            }
        }
    }
}


extension APNSManager {
    
    class func getProductData(withProduct product: Product) -> ProductData {
        
        let currentProduct = ProductData(withName: (product.productName!), withProductId: (product.productId!), andDescription: (product.productDescription!), (product.model!), (product.price.description
			), prodImage: (product.image!), (product.isInCart), (product.isProductLiked), availability: (product.availability.description), (product.arName)!, (product.arDescription)!)
        
        return currentProduct
    }
}
