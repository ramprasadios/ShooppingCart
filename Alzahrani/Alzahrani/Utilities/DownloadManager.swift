//
//  DownloadManager.swift
//  Alzahrani
//
//  Created by Hardwin on 19/05/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation
import UIKit
import MagicalRecord

class DownloadManager: NSObject {
    
    class var sharedDownloadManager : DownloadManager {
        struct Static {
            static let instance = DownloadManager()
        }
        return Static.instance
    }
    
    var languageId: String {
        var retVal: String?
        if let type = LanguageType(rawValue: (UserDefaultManager.sharedManager().selectedLanguageId)!) {
            
            switch type {
            case .arabic:
                retVal = "2"
            case .english:
                retVal = "1"
            }
        }
        return retVal!
    }
    
    //MARK:- Life Cycle
    //Singleton class Should be of private init
    private override init() {
        super.init()
    }
}

//MARK:- SubCategories
extension DownloadManager {
    
    func getAllProductCategories(param userInfo : String ,completionHandler: DownloadSuccessHandler? = nil) {
        
        SyncManager.syncOperation(operationType: .getProductsList, info: userInfo) { (response, error) in
            if (response != nil) {
                if let productsList = response as? [[String: AnyObject]] {
                    
                    for product in productsList {
                        if let categoryId = product["category_id"] as? String {
                            let parameters = categoryId + "&language_id=\(self.languageId)"
                            self.downloadSubCategories(withParams: parameters)
									self.downloadBrands(OfCategoryId: categoryId)
                        }
                    }
                    completionHandler?(true, response as AnyObject?)
                }
            } else {
                completionHandler?(false, response as AnyObject?)
                print("Error Found \(error)")
            }
        }
    }
    
    func downloadSubCategories(withParams param: String, completionhandler: DownloadSuccessHandler? = nil) {
        SyncManager.syncOperation(operationType: .getProductSubCategories, info: param) { (response, error) in
            if response != nil {
                if let subCategoriesList = response as? [[String: AnyObject]] {
                    for subCategory in subCategoriesList {
                        if let subCategoryId = subCategory["category_id"] as? String {
                            let parameters = subCategoryId + "&language_id=\(self.languageId)"
                            //self.downloadAllProduct(withCategoryId: suCategoryId)
                            self.downloadSubSubCategory(withId: parameters, completionHandler: { (success, result) in
                                if success {
                                    if let nextedCategoriesList = result as? [[String: AnyObject]] {
                                        if nextedCategoriesList.count == 0 {
                                            //self.downloadAllProduct(withCategoryId: subCategoryId)
                                        } else {
                                            for nestedCategory in nextedCategoriesList {
                                                if let categoryId = nestedCategory["category_id"] as? String {
                                                    //self.downloadAllProduct(withCategoryId: categoryId)
                                                }
                                            }
                                        }
                                    }
                                    print("Nested Category Downloaded")
                                } else {
                                    print("Error downloading the nested Categories")
                                }
                            })
                        } else {
                            
                        }
                    }
                }
                completionhandler?(true, response as AnyObject?)
            } else {
                completionhandler?(false, response as AnyObject?)
            }
        }
    }
    
    func downloadSubSubCategory(withId id: String, completionHandler: DownloadSuccessHandler? = nil) {
        SyncManager.syncOperation(operationType: .getNestedSubCategories, info: id) { (result, error) in
            if error == nil {
                
                completionHandler?(true, result as AnyObject?)
            } else {
                completionHandler?(false, result as AnyObject?)
            }
        }
    }
    
    func downloadAllProduct(withCategoryId id: String, withHandler completionHandler: DownloadSuccessHandler? = nil) {
        var param: String = ""
        if AppManager.isUserLoggedIn {
            if let custGrpId = UserDefaultManager.sharedManager().customerGroupId {
                param = id + "&customer_group_id=\(custGrpId)"
            } else {
                param = id + "&customer_group_id=\(1)"
            }
        } else {
            param = id + "&customer_group_id=\(1)"
        }
        SyncManager.syncOperation(operationType: .getAllProducts, info: param) { (respose, error) in
            if error == nil {
                if let products = respose as? [[String: AnyObject]] {
                    self.saveDownloadedProduct(withProduct: products)
                }
                completionHandler?(true, respose as AnyObject?)
            } else {
                completionHandler?(false, respose as AnyObject?)
            }
        }
    }
    
    func saveDownloadedProduct(withProduct product: [[String: AnyObject]]?) {
        if let productsData = product {
            SyncManager.importSyncOperation(operationType: .importOperation, info: productsData, completionHandler: { (success) in
                if success {
                }
            })
        }
    }
	
	func downloadBrands(OfCategoryId id: String) {
		SyncManager.syncOperation(operationType: .getBrandsOfCategory, info: id) { (success, error) in
			if (success != nil) {
				
			}
		}
	}
}
