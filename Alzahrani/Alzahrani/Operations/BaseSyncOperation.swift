//
//  BaseSyncOperation.swift
//  Alzahrani
//
//  Created by Hardwin on 05/05/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit
import Alamofire

enum OperationType: String {
    case Assets = "AssetsSync"
    case Login  = "LoginSync"
    case Register = "Registeration"
    case getProductsList = "ProductsList"
    case getProductSubCategories = "ProductSubCategories"
    case imageDownloadOperation = "ImageDownloadOperation"
    case getNestedSubCategories = "getNestedSubCategories"
    case getNewArrivalProducts  = "getNewArrivalProducts"
    case getBrandsList          = "getBrandsList"
    case getHomeBannersList     = "getHomeBannersList"
    case forgotPassword         = "forgotPassword"
    case getTopSetllingProducts = "getTopSetllingProducts"
    case getAllProducts         = "getAllProducts"
    case importOperation        = "importOperation"
    case getSliderImages        = "getSliderImages"
    case uploadWishListData     = "uploadWishListData"
    case getAllWishLists        = "getAllWishLists"
    case deleteWishListData     = "deleteWishListData"
    case uploadMyCartListData   = "uploadMyCartListData"
    case getAllCartData         = "getAllCartData"
    case deleteCartProduct      = "deleteCartProduct"
    case downloadCartImage      = "downloadCartImage"
    case getCitiesList          = "getCitiesList"
    case getCountiesList        = "getCountiesList"
    case addNewAddress          = "addNewAddress"
    case placeOrder             = "placeOrder"
    case productSpecification   = "productSpecification"
    case onlineProductSearch    = "onlineProductSearch"
    case getBrandsOfCategory    = "getBrandsOfCategory"
    case onlinePayment          = "onlinePayment"
    case aramexShipping         = "aramexShipping"
    case getHomeScreenData      = "getHomeScreenData"
    case getUserExistingAddress = "getUserExistingAddress"
    case getProductData         = "getProductData"
    case getProductsFromBrandNameData = "getProductsFromBrandNameData"
    case getCitiesBasedOnZoneId = "getCitiesBasedOnZoneId"
    case getShippingCharges     = "getShippingCharges"
    case getBankDetails         = "getBankDetails"
    case getFilteredProducts    = "getFilteredProducts"
    case applyCouponCode        = "applyCouponCode"
    case writeReview            = "writeReview"
    case getFinalPrice          = "getFinalPrice"
    case getProductDetail       = "getProductDetail"
    case getPolicyTermsData     = "getPolicyTermsData"
	 case downloadAllProducts	  = "downloadAllProducts"
	case getMyProfileData =		"getMyProfileData"
	case generateSDKToken		= "generateSDKToken"
}

typealias SyncCompletionHandler = (_ result: Any? , _ error: ResponseError?) -> Void
typealias ImportCompletionHandler = ((_ success: Bool) -> Void)

public typealias DownloadSuccessHandler = (_ success : Bool, _ result: AnyObject?) -> ()

class BaseSyncOperation: Operation {
    
    var operationType = OperationType.Assets
    //Stores any temproary info to be used while sending request
    var userInfo: String?
    //Closure called when operation is completed
    var completionHandler: SyncCompletionHandler?
    //Stores the Temporary JSON Objects
    var userDict: [[String: AnyObject]]?
    //For ImageCompletion Handeling
    var imageCompletionHandler: ImportCompletionHandler?
    
    //MARK:- Initilization:
    
    init(info: String? = nil,
         userDict: [[String: AnyObject]]? = nil,
         operationType: OperationType,
         completionHandler: SyncCompletionHandler? = nil,
         importCompletion: ImportCompletionHandler? = nil) {
        
        super.init()
        userInfo = info
        self.userDict = userDict
        self.operationType = operationType
        self.completionHandler = completionHandler
        name = operationType.rawValue
    }
    
    override func main() {
        
        if isCancelled {
            print("Cancel Operation: \(self.name)")
            DispatchQueue.main.async {
                
                self.completionHandler?(nil, NetworkManager.connectionError)
            }
            return
        }
        //Closure
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        startProcessing()
    }
    
    deinit {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        print("Ending Operation: \(self.name)")
    }
}

extension BaseSyncOperation {
    func startProcessing() {
        //Look at child class
        assertionFailure("startProcessing must be overriden by subclass")
    }
}

extension String: ParameterEncoding {
    
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = data(using: .utf8, allowLossyConversion: false)
        return request
    }
}

