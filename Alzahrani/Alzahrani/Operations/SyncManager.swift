//
//  SyncManager.swift
//  Alzahrani
//
//  Created by Hardwin on 05/05/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class SyncManager: NSObject {
    
    fileprivate static var syncQueueManager = BaseOperationQueueManager()
    
    class var sharedSyncQueueManager: BaseOperationQueueManager {
        return syncQueueManager
    }
}

//MARK:- Helper Methods

extension SyncManager {
    
    class func syncOperation(operationType type: OperationType,
                             info: String?,
                             completionHandler: SyncCompletionHandler? = nil) {
        var operation: BaseSyncOperation!
        if NetworkManager.sharedReachability.isReachable() {
            switch type {
            case .Assets:
                break
            case .Register, .Login, .forgotPassword, .getCitiesList, .getCountiesList, .addNewAddress, .getUserExistingAddress, .getCitiesBasedOnZoneId, .getBankDetails, .getMyProfileData, .generateSDKToken:
                operation = RegisterSyncOperation(info: info, operationType: type, completionHandler: completionHandler)
                syncQueueManager.addBackgroundTaskUIOperation(operation: operation)
                
            case .getProductsList, .getProductSubCategories, .getNestedSubCategories, .getBrandsList, .getTopSetllingProducts, .getNewArrivalProducts, .getHomeScreenData, .getProductData, .getProductsFromBrandNameData, .getShippingCharges, .getFilteredProducts:

                operation = ProductsSyncOperation(info: info, operationType: type, completionHandler: completionHandler)
                syncQueueManager.addDownloadOperation(operation: operation)
                
            case .getAllProducts, .importOperation, .getAllWishLists, .getAllCartData, .productSpecification, .onlineProductSearch, .getBrandsOfCategory, .getProductDetail, .downloadAllProducts:
                operation = ProductsSyncOperation(info: info, operationType: type, completionHandler: completionHandler)
                syncQueueManager.addProductDownloadOperation(operation: operation)
                
            case .imageDownloadOperation, .getHomeBannersList, .getSliderImages, .downloadCartImage:
                operation = ImageSyncOperation(info: info, operationType: type, completionHandler: completionHandler)
                syncQueueManager.addPictureMetaDataOperation(operation: operation)
                
            case .uploadWishListData, .deleteWishListData, .uploadMyCartListData, .deleteCartProduct, .placeOrder, .onlinePayment, .aramexShipping, .applyCouponCode, .writeReview, .getFinalPrice, .getPolicyTermsData:
                operation = UploadSyncOperation(info: info, operationType: type, completionHandler: completionHandler)
                syncQueueManager.addUploadOperation(operation: operation)
            }
        } else {
            completionHandler?(nil, NetworkManager.connectionError)
        }
    }
    
    class func importSyncOperation(operationType type: OperationType,
                                   info: [[String: AnyObject]]?,
                                   completionHandler: ImportCompletionHandler? = nil) {
        var operation: BaseSyncOperation!
        switch type {
        case .importOperation:
            operation = ImportSyncOperation(info: "", userDict: info, operationType: .importOperation, importCompletion: completionHandler)
            syncQueueManager.addProductDownloadOperation(operation: operation)
        default:
            print("")
        }
        
    }
    
    /**
     Starts reachability observing
     */
    class func startObservingReachability() {
        let reachability = NetworkManager.sharedReachability
        
        reachability.whenReachable = { reachability in
        }
        
        reachability.whenUnreachable = { reachability in
            
        }
        
        let _ = reachability.startNotifier()
        
        // Initial reachability check
        if reachability.isReachable() {
            
        }
    }
}
