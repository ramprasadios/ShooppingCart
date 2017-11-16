//
//  UploadSyncOperation.swift
//  Alzahrani
//
//  Created by Hardwin on 10/06/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation
import Alamofire
import MagicalRecord

class UploadSyncOperation: BaseSyncOperation {
    
}

extension UploadSyncOperation {
    
    override func startProcessing() {
        switch (self.operationType) {
        case .uploadWishListData:
            self.uploadWishlistData()
        case .deleteWishListData:
            self.deleteWishListData()
        case .uploadMyCartListData:
            self.uploadMyCartListData()
        case .deleteCartProduct:
            self.deleteCartProduct()
        case .placeOrder:
            self.placeOrder()
        case .onlinePayment:
            self.onlinePaymentTransaction()
        case .aramexShipping:
            self.getAramexShippingCharges()
        case .applyCouponCode:
            self.applyCouponCode()
        case .writeReview:
            self.writeUserReviews()
        case .getFinalPrice:
            self.getFinalPrice()
        case .getPolicyTermsData:
            self.getReturnsPolicyData()
        default:
            break
        }
    }
}

//MARK:- Upload Data
extension UploadSyncOperation {
    
    func uploadWishlistData() {
        if let userInfo = userInfo {
            
            NetworkManager.defaultManger.request(URLBuilder.getwishListUploadURL(), method: .post, parameters: [:], encoding: userInfo).validate().responseJSON(completionHandler: { (response) in
                if response.error == nil {
                    self.completionHandler?(response.result.value, nil)
                } else {
                    self.completionHandler?(nil, nil)
                }
            })
        }
    }
    
    func uploadMyCartListData() {
        if let userInfo = userInfo {
              print("userInfo: \(userInfo)")
            print(URLBuilder.getMyCartUploadURL())
            NetworkManager.defaultManger.request(URLBuilder.getMyCartUploadURL(), method: .post, parameters: [:], encoding: userInfo).validate().generateResponseSerialization(completion: { (Response) in
                if Response.error == nil {
                    print("Add To Cart Response: \(Response.JSON)")
                    self.completionHandler?(Response.JSON, nil)
                } else {
                    self.completionHandler?(nil, Response.error)
                }
            })
            
            /* NetworkManager.defaultManger.request(URLBuilder.getMyCartUploadURL(), method: .post, parameters: [:], encoding: userInfo).validate().responseJSON(completionHandler: { (response) in
                if response.error == nil {
                    print("Add To Cart Response: \(response.result.value)")
                    self.completionHandler?(response.result.value, nil)
                } else {
                    self.completionHandler?(nil, ResponseError(error: response.result.error.debugDescription))
                }
            }) */
        }
    }
}

//MARK:- Delete data
extension UploadSyncOperation {
    
    func deleteWishListData() {
        if let userInfo = userInfo {//URLBuilder.getWishListDeleteURL()
            
            NetworkManager.defaultManger.request(URLBuilder.getWishListDeleteURL(), method: .post, parameters: [:], encoding: userInfo).validate().responseJSON(completionHandler: { (response) in
                if response.error == nil {
                    self.completionHandler?(response.result.value, nil)
                } else {
                    self.completionHandler?(nil, nil)
                }
            })
        }
    }
        
    func deleteCartProduct() {
        if let userInfo = userInfo {
            NetworkManager.defaultManger.request(URLBuilder.getMyCartDeleteURL(),
                                                 method: .post,
                                                 parameters: [:],
                                                 encoding: userInfo)
                .validate().generateResponseSerialization(completion: { (Response) in
                    if Response.error == nil {
                        print("Response:11 \(Response.JSON)")
                        self.completionHandler?(Response, nil)
                    } else {
                        self.completionHandler?(nil, ResponseError(error: "DeletePoductError"))
                    }
                })
        }
    }
    
    func placeOrder() {
        if let userInfo = userInfo {
            NetworkManager.defaultManger.request(URLBuilder.getPlaceOrderURL(), method: .post, parameters: [:], encoding: userInfo).validate().responseJSON(completionHandler: { (response) in
                if response.error == nil {
                    print("Product place Response: \(response.result.value)")
                    self.completionHandler?(response.result.value, nil)
                } else {
                    self.completionHandler?(nil, ResponseError.init(error: response.error.debugDescription))
                }
            })
        }
    }
    
    func onlinePaymentTransaction() {
        if let userInfo = userInfo {
            NetworkManager.defaultManger.request(URLBuilder.getPaymentGatewayURL(), method: .post, parameters: [:], encoding: userInfo).validate().responseJSON(completionHandler: { (resposne) in
                if resposne.error == nil {
                    self.completionHandler?(resposne.result.value, nil)
                } else {
                    self.completionHandler?(nil, nil)
                }
            })
        }
    }
    
    func getAramexShippingCharges() {
        if let userInfo = userInfo {
            NetworkManager.defaultManger.request(URLBuilder.aramexShippingURL(), method: .post, parameters: [:], encoding: userInfo).validate().generateResponseSerialization(completion: { (response) in
                if response.error == nil {
                    print("Aramex Shipping response: \(response.JSON)")
                    self.completionHandler?(response.JSON, nil)
                } else {
                    self.completionHandler?(nil, response.error)
                }
            })
        }
    }
    
    func applyCouponCode() {
        
        if let userInfo = userInfo {
            
            NetworkManager.defaultManger.request(URLBuilder.getCouponCodeURL(), method: .post, parameters: [:], encoding: userInfo).validate().responseJSON(completionHandler: { (response) in
                if response.error == nil {
                    var responseObject = [String: AnyObject]()
                    print("Coupon Code Response: \(response.result.value)")
                    if let responseData = response.result.value as? [String: AnyObject] {
                        if let responseInfo = responseData["records"] as? [[String: AnyObject]] {
                            responseObject["CouponInfo"] = responseInfo.first as AnyObject?
                        }
                        
                        if let successInfo = responseData["success"] as? String {
                            responseObject["SuccessInfo"] = successInfo as AnyObject?
                        } else {
                            if let errorInfo = responseData["error"] as? String {
                                responseObject["ErrorInfo"] = errorInfo as AnyObject?
                            }
                        }
                        self.completionHandler?(responseObject, nil)
                    }
                } else {
                    print("Error Applying Coupon")
                    self.completionHandler?(nil, ResponseError.init(error: response.error.debugDescription))
                }
            })
        }
    }
    
    func writeUserReviews() {
        if let userInfo = userInfo {
            NetworkManager.defaultManger.request(URLBuilder.writeReviewsURL(), method: .post, parameters: [:], encoding: userInfo).validate().responseJSON(completionHandler: { (responseData) in
                if responseData.error == nil {
                    print("Coupon Code Response: \(responseData.result.value)")
                    self.completionHandler?(responseData.result.value, nil)
                } else {
                    self.completionHandler?(nil, ResponseError(error: responseData.result.error as! String))
                }
            })
        }
    }
    
    func getFinalPrice() {
        if let userInfo = userInfo {
            let url = URLBuilder.getFinalPriceURL() + userInfo
            NetworkManager.defaultManger.request(url, method: .get, parameters: [:], encoding: URLEncoding.methodDependent).validate().generateResponseSerialization(completion: { (Response) in
                if Response.error == nil {
                    print("Final Price: \(Response.JSON)")
                    self.completionHandler?(Response.JSON, nil)
                } else {
                    self.completionHandler?(nil, Response.error)
                }
            })
        }
    }
    
    func getReturnsPolicyData() {
        if let userInfo = userInfo {
            let url = URLBuilder.getPolicyData() + userInfo
            NetworkManager.defaultManger.request(url, method: .get, parameters: [:], encoding: URLEncoding.methodDependent).validate().generateResponseSerialization(completion: { (Response) in
                if Response.error == nil {
                    print("Policy Info: \(Response.JSON)")
                    self.completionHandler?(Response.JSON, nil)
                } else {
                    self.completionHandler?(nil, Response.error)
                }
            })

        }
    }
}
