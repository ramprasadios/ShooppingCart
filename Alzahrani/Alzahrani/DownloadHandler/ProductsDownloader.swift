//
//  ProductsDownloader.swift
//  Alzahrani
//
//  Created by Hardwin on 31/05/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation
import UIKit
import MagicalRecord

enum DownloadType: String {
	
	case firstTime     = "FirstTime"
	case refresh       = "RefreshDownload"
	case accountSwitch = "AccountSwitch"
	case englishDownload = "1"
	case arabicDownload  = "2"
}

class ProductsDownloader: NSObject {
	
	class var sharedInstance: ProductsDownloader {
		struct Static {
			static let instance = ProductsDownloader()
		}
		return Static.instance
	}
	
	func configureDownload(withType type: DownloadType) {
		switch type {
		case .firstTime:
			self.initialDownload()
		case .refresh, .accountSwitch:
			print("Clear DB and then download")
		case .englishDownload:
			self.downloadProductsWith(languageType: .english)
		case .arabicDownload:
			self.downloadProductsWith(languageType: .arabic)
		}
	}
	
	func downloadProductsWith(languageType type: LanguageType) {
		if DBManager.sharedManager().cleanAndResetupDB() {
			Product.deleteAllProducts()
			self.getBrandsList()
			self.getCategoriesList(ofLanguageType: type)
			self.getNewArrivalList()
			self.getTopSellingProducts()
		}
	}
	
	func initialDownload() {
		if DBManager.sharedManager().cleanAndResetupDB() {
			let userSelectedLanguage = UserDefaultManager.sharedManager().selectedLanguageId
			if let languageType = LanguageType(rawValue: userSelectedLanguage!) {
				//self.getBrandsList()
				self.getCategoriesList(ofLanguageType: languageType)
			}
		}
	}
	
	func getCategoriesList(ofLanguageType type: LanguageType) {
		
		switch type {
		case .arabic:
			
			let productsCount = ProductCategory.mr_findAll()?.count
			if productsCount! <= 0 {
				DownloadManager.sharedDownloadManager.getAllProductCategories(param: "2", completionHandler: { (success, result) in
					if success {
						
					}
				})
			}
		case .english:
			let productsCount = ProductCategory.mr_findAll()?.count
			if productsCount! <= 0 {
				DownloadManager.sharedDownloadManager.getAllProductCategories(param: "1", completionHandler: { (success, result) in
					if success {
						
					}
				})
			}
		}
	}
	
	func getNewArrivalList() {
		if let newArrivalProducts = NewArrival.mr_findAll() {
			print("Print \(Product.mr_findAll()?.count)")
			if newArrivalProducts.count <= 0 {
				if AppManager.isUserLoggedIn {
					if let customerGroupId = UserDefaultManager.sharedManager().customerGroupId {
						SyncManager.syncOperation(operationType: .getNewArrivalProducts, info: customerGroupId) { (response, error) in
							if error == nil {
								
							}
						}
						
					}
				} else {
					SyncManager.syncOperation(operationType: .getNewArrivalProducts, info: "1") { (response, error) in
						if error == nil {
							
						}
					}
				}
			}
		}
	}
	
	func getTopSellingProducts() {
		if let topSellingProducts = TopSelling.mr_findAll() {
			if topSellingProducts.count <= 0 {
				if AppManager.isUserLoggedIn {
					if let customerGroupId = UserDefaultManager.sharedManager().customerGroupId {
						SyncManager.syncOperation(operationType: .getTopSetllingProducts, info: customerGroupId) { (response, error) in
							if error == nil {
							}
						}
					}
				} else {
					SyncManager.syncOperation(operationType: .getTopSetllingProducts, info: "1") { (response, error) in
						if error == nil {
						}
					}
				}
			}
		}
	}
	
	func getBrandsList() {
		let brandsList = Brands.mr_findAll()?.count
		if brandsList! <= 0 {
			SyncManager.syncOperation(operationType: .getBrandsList, info: "") { (response, error) in
				if error == nil {
				}
			}
		}
	}
}

extension ProductsDownloader {
	
	func handleHomeScreenProducts() {
		if NetworkManager.sharedReachability.isReachable() {
			//Fetch All From Web
			
			var languageId: String?
			if let langId = LanguageType(rawValue: UserDefaultManager.sharedManager().selectedLanguageId!) {
				switch langId {
				case .english:
					languageId = "1"
				case .arabic:
					languageId = "2"
				}
			}
			print("Language is: \(languageId)")
			if let languageId = languageId {
				let customerGroupId = AppManager.getCustGroupId()
				let syncDataFormat = "&customer_group_id=\(customerGroupId)&language_id=\(languageId)"
				
				SyncManager.syncOperation(operationType: .getHomeScreenData, info: syncDataFormat, completionHandler: { (response, error) in
					if error == nil {
						if let newProductCollection = response as? [[String: AnyObject]] {
							print("Home screen Data: \(response)")
							DispatchQueue.main.async {
								var homeProducts = [String: AnyObject]()
								homeProducts["homeProductsSectionDict"] = newProductCollection as AnyObject?
								MagicalRecord.save({ (context) in
									HomeProducts.mr_import(from: homeProducts, in: context)
								})
							}
						}
					}
				})
			}
		}
	}
}
