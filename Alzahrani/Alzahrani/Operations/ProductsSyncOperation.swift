
//
//  ProductsSyncOperation.swift
//  Alzahrani
//
//  Created by Hardwin on 12/05/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation
import Alamofire
import MagicalRecord

typealias ImportCompletion = ((_ success: Bool) -> Void)
class ProductsSyncOperation: BaseSyncOperation {
    
}

//MARK:- Handle operation types
extension ProductsSyncOperation {
    
    override func startProcessing() {
        switch (self.operationType) {
        case .getProductsList:
            self.getAllProductCategories()
        case .getProductSubCategories:
            self.getProductSubCategories()
        case .getNestedSubCategories:
            self.getNestedSubCategories()
        case .getNewArrivalProducts:
            self.getNewArrivalProducts()
        case .getBrandsList:
            self.getAllBrandsList()
        case .getTopSetllingProducts:
            self.getTopSellingProducts()
        case .getAllProducts:
            self.downloadAllProducts()
        case .getAllWishLists:
            self.downloadAllWishLists()
        case .getAllCartData:
            self.downloadAllCartData()
        case .productSpecification:
            self.getProductSpecification()
        case .onlineProductSearch:
            self.onlineProductSearch()
        case .getBrandsOfCategory:
            self.getBrandsBasedOncategoryId()
        case .getHomeScreenData:
            self.getHomeScreenProductData()
        case .getProductData:
            self.getProductData()
        case .getProductsFromBrandNameData:
            self.getProductsFromBrandNameData()
        case .getShippingCharges:
            self.getShippingCharges()
        case .getFilteredProducts:
            self.getFilteredProducts()
        case .getProductDetail:
            self.getProductDetails()
		case .downloadAllProducts:
			   self.downloadAllProductsData()
        default:
            break
        }
    }
}

//MARK:- Parse and Retrieve Data
extension ProductsSyncOperation {
    
    func getProductsFromBrandNameData()
    {
        if let userInfo = userInfo {
            let url = URLBuilder.getProductsFromBrandNameURL() + userInfo
              NetworkManager.defaultManger.request(url, method: .get, parameters: [:], encoding: URLEncoding.methodDependent).validate().generateResponseSerialization { (Response) in
                                
                if Response.error == nil {
                    //print("Product Response is \(Response.JSON)")
                    self.completionHandler?(Response.JSON, Response.error)
                }else {
                    print("Product Response is \(Response.JSON)")
                    self.completionHandler?(nil, Response.error)
                }
                
            }
        }
    }
    
    func getProductData()
    {
        
        if let userInfo = userInfo {
            let url = URLBuilder.getProductURL() + userInfo
            print("call Product service \(url)")
            NetworkManager.defaultManger.request(url, method: .get, parameters: [:], encoding: URLEncoding.methodDependent).validate().generateResponseSerialization { (Response) in
                
               

                if Response.error == nil {
                     print("Product Response is \(Response.JSON)")
                    self.completionHandler?(Response.JSON, Response.error)
                }else {
                     print("Product Response is \(Response.JSON)")
                    self.completionHandler?(nil, Response.error)
                }
                
            }
            }
        
    }
    
    //MARK:- All Products
    func getHomeScreenProductData()
    {
        if let userInfo = userInfo {
        let url = URLBuilder.getHomeScreenDataURL() + userInfo
         NetworkManager.defaultManger.request(url, method: .get, parameters: [:], encoding: URLEncoding.methodDependent).validate().generateResponseSerialization { (Response) in
           
            if Response.error == nil {
              
                if let response = Response.JSON as? [[String: AnyObject]] {
                    
                    for product in response {
							var productInfoData = product
							if let imageURL = productInfoData["image"] as? String {
								let prorperURL = imageURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
								SyncManager.syncOperation(operationType: .imageDownloadOperation, info: prorperURL, completionHandler: { (imageData, error) in
									if error == nil {
										if let productImageData = imageData as? Data {
											productInfoData["imageData"] = productImageData as AnyObject?
											self.didFinishAllProductDownload(data: productInfoData)
										}
									} else {
										productInfoData["imageData"] = nil
										self.didFinishAllProductDownload(data: productInfoData)
									}
								})
							} else {
								productInfoData["imageData"] = nil
								self.didFinishAllProductDownload(data: productInfoData)
							}
						}
                }
                self.completionHandler?(Response.JSON, Response.error)
            } else {
                self.completionHandler?(nil, Response.error)
            }
        }
    }
}

    //MARK:- All Categories
    func getAllProductCategories() {
        if let userInfo = userInfo {
            let url = URLBuilder.getProductsListURL() + userInfo
            NetworkManager.defaultManger.request(url, method: .get, parameters: [:], encoding: URLEncoding.methodDependent).validate().generateResponseSerialization { (Response) in
                
                if Response.error == nil {
                    print("Category Response111 is \(Response.JSON)")
                    if let response = Response.JSON as? [[String: AnyObject]] {
                        
                        for product in response {
                            self.didFinishAllCategoriesListDownload(data: product)
                        }
                    }
                    self.completionHandler?(Response.JSON, Response.error)
                }
            }
        }
    }
    
    //MARK:- Sub Categories
    func getProductSubCategories() {
        let url = URLBuilder.getProductSubcategoriesURL() + userInfo!
        NetworkManager.defaultManger.request(url, method: .get, parameters: [:], encoding: URLEncoding.methodDependent).validate().generateResponseSerialization { (Response) in
            
            if Response.error == nil {
                if let responseData = Response.JSON as? [[String: AnyObject]] {
                    for subCategory in responseData {
                        self.didFinishAllSubCategoriesDownload(data: subCategory)
                    }
                }
               // print("Sub Categories data is \(Response.JSON)")
                self.completionHandler?(Response.JSON, Response.error)
            } else {
                //print("Error Occured In Sub Categoties \(Response.error!)")
                self.completionHandler?(nil, Response.error)
            }
        }
    }
    
    //MARK:- Nested Categories
    func getNestedSubCategories() {
        let url = URLBuilder.getProductSubcategoriesURL() + userInfo!
        NetworkManager.defaultManger.request(url, method: .get, parameters: [:], encoding: URLEncoding.methodDependent).validate().generateResponseSerialization { (Response) in
            if Response.error == nil {
                if let responseData = Response.JSON as? [[String: AnyObject]] {
                    for nestedCategory in responseData {
                        self.didFinishNestedCategoryDownload(data: nestedCategory)
                    }
                }
                self.completionHandler?(Response.JSON, Response.error)
            } else {
                self.completionHandler?(nil, Response.error)
            }
        }
    }
    
    //MARK:- Get New Arrival Products:
    func getNewArrivalProducts() {
        if let userInfo = userInfo {
            let url = URLBuilder.getNewArrivatURL() + userInfo
            NetworkManager.defaultManger.request(url, method: .get, parameters: [:], encoding: URLEncoding.methodDependent).generateResponseSerialization(completion: { (Response) in
                if Response.error == nil {
                    if let Response = Response.JSON {
                       // print("New Arrival: \(Response)")
                    }
                    
                    if let newArrivalCollection = Response.JSON as? [[String: AnyObject]] {
                        for newArrivalProd in newArrivalCollection {
                            self.didFinishAllNewArrivalDownload(data: newArrivalProd)
                        }
                    }
                    
                    self.completionHandler?(Response.JSON, Response.error)
                } else {
                    self.completionHandler?(nil, Response.error)
                }
            })
        }
    }
    
    //MARK:- Get All Brands:
    func getAllBrandsList() {
        NetworkManager.defaultManger.request(URLBuilder.getBrandsURL(), method: .get, parameters: [:], encoding: URLEncoding.methodDependent).validate().generateResponseSerialization { (Response) in
            if Response.error == nil {
                //print("Brands: \(Response.JSON)")
                
                if let brandsData = Response.JSON as? [[String: AnyObject]] {

                    for brand in brandsData {
						self.didFinishAllBrandsListDownload(data: brand)
                        /*
						var brandsDict = [String: AnyObject]()
						if let brandsImage = brand["image"] as? String {
                            SyncManager.syncOperation(operationType: .imageDownloadOperation, info: brandsImage, completionHandler: { (imageData, error) in
                                if let imageData = imageData {
                                    
                                    if error == nil {
                                        brandsDict["imageData"] = imageData as AnyObject?
                                        brandsDict["image"] = brand["image"]
                                        brandsDict["name"] = brand["name"]
                                        brandsDict["category_id"] = brand["category_id"]
                                        brandsDict["manufacturer_id"] = brand["manufacturer_id"]
                                        
                                        self.didFinishAllBrandsListDownload(data: brandsDict)
                                    }
                                }
                            })
                        } */
                    }
                }
                self.completionHandler?(Response.JSON, Response.error)
            } else {
                self.completionHandler?(nil, Response.error)
            }
        }
    }
    
    //MARK:- Top Selling Products:
    func getTopSellingProducts() {
        if let userInfo = userInfo {
            let url = URLBuilder.getTopSellingProductsURL() + userInfo
            NetworkManager.defaultManger.request(url, method: .get, parameters: [:], encoding: URLEncoding.methodDependent).validate().generateResponseSerialization { (Response) in
                if Response.error == nil {
                    //print("Top Selling Products: \(Response.JSON)")
                    self.completionHandler?(Response.JSON, Response.error)
                } else {
                    self.completionHandler?(nil, Response.error)
                }
                if let topSellingCollection = Response.JSON as? [[String: AnyObject]] {
                    for topSellingProd in topSellingCollection {
                        self.didFinishDownloadingAllTopSellingProducts(data: topSellingProd)
                    }
                }
            }
        }
    }
    
    //MARK:- Products Download:
    func downloadAllProducts() {
        if let userInfo = userInfo {
            let url = URLBuilder.getProductsBasedOnCategory() + userInfo
            NetworkManager.defaultManger.request(url, method: .get, parameters: [:], encoding: URLEncoding.methodDependent).validate().generateResponseSerialization { (Response) in
                if Response.error == nil {
                   print("Products List: \(Response.JSON)")
                    if let response = Response.JSON as? [[String: AnyObject]] {
                        self.completionHandler?(response, Response.error)
                    }
                } else {
                    self.completionHandler?(nil, Response.error)
                }
            }
        }
    }
    
    //MARK:- Get Product Specification:
    func getProductSpecification() {
        if let userInfo = userInfo {
            let url = URLBuilder.getProductSpecificationsURL() + userInfo
            NetworkManager.defaultManger.request(url, method: .get, parameters: [:], encoding: URLEncoding.methodDependent).validate().generateResponseSerialization { (Response) in
                if Response.error == nil {
                    //print("Product Specification: \(Response.JSON)")
                    self.completionHandler?(Response.JSON, nil)
                } else {
                    self.completionHandler?(nil, Response.error)
                }
            }
        }
    }
    
    func onlineProductSearch() {
        if let userInfo = userInfo {
            let url = URLBuilder.getSearchProductURL() + userInfo
            let finalURL = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            NetworkManager.defaultManger.request(finalURL!, method: .get, parameters: [:], encoding: URLEncoding.methodDependent).validate().generateResponseSerialization(completion: { (Response) in
                if Response.error == nil {
                    self.completionHandler?(Response.JSON, Response.error)
                } else {
                    self.completionHandler?(nil, Response.error)
                }
            })
        }
    }
    
    func getBrandsBasedOncategoryId() {
        if let userInfo = userInfo {
            let url = URLBuilder.getBrandsBasedOnCategory() + userInfo
            NetworkManager.defaultManger.request(url, method: .get, parameters: [:], encoding: URLEncoding.methodDependent).validate().generateResponseSerialization(completion: { (Response) in
                if Response.error == nil {
						if let brandsData = Response.JSON as? [[String: AnyObject]] {
							for brand in brandsData {
								self.saveBrandsOfCategory(withData: brand)
							}
						}
                    self.completionHandler?(Response.JSON, Response.error)
                } else {
                    self.completionHandler?(nil, Response.error)
                }
            })
        }
    }
}

//MARK:- WishLists Download:
extension ProductsSyncOperation {
    
    func downloadAllWishLists() {
        if let userInfo = userInfo {
            let url = userInfo
            NetworkManager.defaultManger.request(url,
                                                 method: .get,
                                                 parameters: [:],
                                                 encoding: URLEncoding.methodDependent)
                .validate().generateResponseSerialization { (Response) in
                    if Response.error == nil {
                        WishLists.removeAllWishListData()
                        if let wishListInfo = Response.JSON as? [String: AnyObject] {
                            if let wishListData = wishListInfo["products"] as? [[String: AnyObject]] {
                                for wishListProd in wishListData {
                                    self.didFinishAllWishListDownload(data: wishListProd)
                                }
                            }
                        }
                        self.completionHandler?(Response, Response.error)
                    } else {
                        self.completionHandler?(nil, Response.error)
                    }
            }
        }
    }
    
    func downloadAllCartData() {
        if let userInfo = userInfo {
            let url = URLBuilder.getAllMyCartLists() + userInfo
            NetworkManager.defaultManger.request(url,
                                                 method: .get,
                                                 parameters: [:],
                                                 encoding: URLEncoding.methodDependent)
                .validate().generateResponseSerialization { (Response) in
                    if Response.error == nil {
                        //delete cart object.
                        MyCart.removeAllMyCartListData()
                        //print("MyCart List Response: \(Response.JSON)")
                        if let myCartListInfo = Response.JSON as? [[String: AnyObject]] {
                            if let myCartListData = myCartListInfo.first {
                                if let myCartList = myCartListData["products"] as? [[String: AnyObject]] {
                                    var lastObjStatus: Bool = false
                                    for (index, wishListProd) in myCartList.enumerated() {
                                        if index == myCartList.count {
                                            lastObjStatus = true
                                        } else {
                                            lastObjStatus = false
                                        }
                                        self.didFinishAllMyCartListDownload(data: wishListProd, isLastObject: lastObjStatus)
                                    }
                                }
                            }
                        }
                        self.completionHandler?(Response.JSON, Response.error)
                    } else {
                        self.completionHandler?(nil, Response.error)
                    }
            }
        }
    }
}

//MARK:- Sub Download Operations:
extension ProductsSyncOperation {
    
    func downloadBrandSubCategories(withCategoryId id: String?) {
        if let categoryId = id {
            
            if let subCategories = SubCategories.getSubCategoriesBy(parentId: categoryId), subCategories.count == 0 {
                
                if let languageType = LanguageType(rawValue: UserDefaultManager.sharedManager().selectedLanguageId!) {
                    switch languageType {
                    case .arabic:
                        let param = categoryId + "&language_id=\("2")"
                        DownloadManager.sharedDownloadManager.downloadSubCategories(withParams: param)
                    case .english:
                        let param = categoryId + "&language_id=\("1")"
                        DownloadManager.sharedDownloadManager.downloadSubCategories(withParams: param)
                    }
                }
            }
        }
    }
}

//MARK:- Get Shipping Charges:
extension ProductsSyncOperation {
    
    func getShippingCharges() {
        
        if let userInfo = userInfo {
            let url = URLBuilder.getShippingChargesURL() + userInfo
            NetworkManager.defaultManger.request(url, method: .get, parameters: [:], encoding: URLEncoding.methodDependent).generateResponseSerialization(completion: { (Response) in
                if Response.error == nil {
                    self.completionHandler?(Response.JSON, nil)
                } else {
                    self.completionHandler?(nil, Response.error)
                }
            })
        }
    }
}

//MARK:- Product Filtering:
extension ProductsSyncOperation {
    
    func getFilteredProducts() {
        if let userInfo = userInfo {
            let url = URLBuilder.getProductsBasedOnCategory() + userInfo
            NetworkManager.defaultManger.request(url, method: .get, parameters: [:], encoding: URLEncoding.methodDependent).validate().generateResponseSerialization(completion: { (Response) in
                if Response.error == nil {
                    self.completionHandler?(Response.JSON, nil)
                } else {
                    self.completionHandler?(nil, Response.error)
                }
            })
        }
    }
    
    func getProductDetails() {
        if let userInfo = userInfo {
            let url = URLBuilder.getProductURL() + userInfo
            NetworkManager.defaultManger.request(url, method: .get, parameters: [:], encoding: URLEncoding.methodDependent).validate().generateResponseSerialization(completion: { (Response) in
                if Response.error == nil {
                    self.completionHandler?(Response.JSON, nil)
                    print("Product Detail Response: \(Response.JSON)")
                } else {
                    self.completionHandler?(nil, Response.error)
                }
            })
        }
    }
	
	func downloadAllProductsData() {
		
		if let userInfo = self.userInfo {
			let url = URLBuilder.downloadAllProductsData() + userInfo
			
			NetworkManager.defaultManger.request(url, method: .get, parameters: [:], encoding: URLEncoding.methodDependent).validate().generateResponseSerialization(completion: { (Response) in
				if Response.error == nil {
					self.completionHandler?(Response.JSON, nil)
					print("Product List Response: \(Response.JSON)")
				} else {
					self.completionHandler?(nil, Response.error)
					print("Error: \(Response.error?.localizedDescription)")
				}
			})
		}
	}
}

//MARK:- Helper Methods
extension ProductsSyncOperation {
    
    func didFinishAllCategoriesListDownload(data: [String: AnyObject]) {
        
        if AppManager.currentApplicationMode() == .offline {
            MagicalRecord.save({ (context) in
                _ = ProductCategory.mr_import(from: data, in: context)
            }) { (success, error) in
                NotificationCenter.default.post(name: Notification.Name("ProductCategorySaveSuccessNotification"), object: nil)
            }
        }
    }
    
    func didFinishAllProductDownload(data: [String: AnyObject]) {
        
        if AppManager.currentApplicationMode() == .offline {
            MagicalRecord.save(blockAndWait: { context in
                _ = Product.mr_import(from: data, in: context)
            })
        }
    }
   
    func didFinishAllSubCategoriesDownload(data: [String: AnyObject]) {
        
        if AppManager.currentApplicationMode() == .offline {
            MagicalRecord.save(blockAndWait: { context in
                _ = SubCategories.mr_import(from: data, in: context)
            })
        }
    }
    
    func didFinishNestedCategoryDownload(data: [String: AnyObject]) {
        
        if AppManager.currentApplicationMode() == .offline {
            MagicalRecord.save(blockAndWait: { context in
                _ = NestedSubCategory.mr_import(from: data, in: context)
            })
        }
    }
    
    func didFinishAllBrandsListDownload(data: [String: AnyObject]) {
        
        if AppManager.currentApplicationMode() == .offline {
            MagicalRecord.save(blockAndWait: { context in
                _ = Brands.mr_import(from: data, in: context)
            })
        }
    }
    
    func didFinishAllNewArrivalDownload(data: [String: AnyObject]) {
        if AppManager.currentApplicationMode() == .offline {
            MagicalRecord.save(blockAndWait: { context in
                _ = NewArrival.mr_import(from: data, in: context)
            })
        }
    }
    
    func didFinishDownloadingAllTopSellingProducts(data: [String: AnyObject]) {
        
        if AppManager.currentApplicationMode() == .offline {
            MagicalRecord.save({ context in
                _ = TopSelling.mr_import(from: data, in: context)
            }) { (success, error) in
                if success {
                    NotificationCenter.default.post(name: Notification.Name("TopSellingDownloadSuccessNotification"), object: nil)
                }
            }
        }
    }
    
    func didFinishAllWishListDownload(data: [String: AnyObject]) {
        
            MagicalRecord.save(blockAndWait: { context in
                _ = WishLists.mr_import(from: data, in: context)
            })
    }
    
    func didFinishAllMyCartListDownload(data: [String: AnyObject], isLastObject isEnd: Bool) {
        
            MagicalRecord.save(blockAndWait: { context in
                _ = MyCart.mr_import(from: data, in: context)
            })
    }
	
	func saveBrandsOfCategory(withData data: [String: AnyObject]) {
		
		if AppManager.currentApplicationMode() == .offline {
			MagicalRecord.save(blockAndWait: { context in
				_ = BrandsCategory.mr_import(from: data, in: context)
			})
		}
	}
}

