//
//  DownloaderViewController.swift
//  Alzahrani
//
//  Created by Ashok Kumar on 28/09/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit
import MagicalRecord

class DownloaderViewController: UIViewController {
	
	
	@IBOutlet weak var progressIndicatorView: UIView!
	@IBOutlet weak var progressBar: UIProgressView!
	@IBOutlet weak var progressTitle: UILabel!
	
	var progressTitleLabel: String = "" {
		didSet {
			DispatchQueue.main.async {
				self.progressTitle.text = self.progressTitleLabel
			}
		}
	}
	var myGroup = DispatchGroup()

    override func viewDidLoad() {
        super.viewDidLoad()
		self.downloadOfflineData()
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.progressTitle.text = "Test change"
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension DownloaderViewController {
	
	func downloadOfflineData() {
		
		ProductsDownloader.sharedInstance.configureDownload(withType: .firstTime)
		//ProductsDownloader.sharedInstance.handleHomeScreenProducts()
		let productCategories = ProductCategory.getAllProducts()
		print("Product Cat: \(productCategories)")
		self.downloadUserExistingAddress { (success) in
			if success {
				DispatchQueue.main.async {
					self.progressTitle.text = "Test change 1"
					self.progressBar.setProgress(0.1, animated: false)
				}
				self.downloadSlidersData(withSuccessHandler: { (success) in
					if success {
						DispatchQueue.main.async {
							self.progressTitle.text = "Test change 2"
							self.progressBar.setProgress(0.4, animated: false)
						}
						self.downloadOffersBannersData(withSuccessHandler: { (success) in
							if success {
								DispatchQueue.main.async {
									self.progressTitle.text = "Test change 3"
									self.progressBar.setProgress(0.6, animated: false)
								}
								self.downloadHomeSectionsData(withSuccessHandler: { (success) in
									if success {
										DispatchQueue.main.async {
											self.progressTitle.text = "Test change 4"
											self.progressBar.setProgress(0.5, animated: false)
										}
										self.downloadProductsData(withSuccessHandler: { (success) in
											if success {
												DispatchQueue.main.async {
													self.progressTitle.text = "Test change 5"
													self.progressBar.setProgress(0.6, animated: false)
												}
												self.downloadProductCategories(withSuccessHandler: { (success) in
													if success {
														DispatchQueue.main.async {
															self.progressTitle.text = "Test change 6"
															self.progressBar.setProgress(0.7, animated: false)
														}
														self.downloadProductImages(withSuccessHandler: { (success) in
															if success {
																self.downloadHomeProductImages(withSuccessHandler: { (success) in
																	if success {
																		DispatchQueue.main.async {
																			var stateInfoDict = [String: AnyObject]()
																			stateInfoDict["App_State"] = AppMode.offline as AnyObject?
																			NotificationCenter.default.post(name: Notification.Name("APP_STATE_NOTIFICATION"), object: stateInfoDict)
																			
																			NotificationCenter.default.post(name: Notification.Name("MyCartUpdateNotification"), object: nil)
																			NotificationCenter.default.post(name: Notification.Name("WishListUpdateNotification"), object: nil)
																			
																			UserDefaultManager.sharedManager().currentAppMode = "Online"
																			
																			UserDefaultManager.sharedManager().isProductDwonloaded = true
																			AppManager.setDefaultRootViewController(state: .Home)
																		}
																	}
																})
															}
														})
													}
												})
											} else {
												ProgressIndicatorController.dismissProgressView()
												self.showErrorDownloadAlertToUser(withErrorMessage: "Error Downloading Products Data")
											}
										})
									} else {
										ProgressIndicatorController.dismissProgressView()
										self.showErrorDownloadAlertToUser(withErrorMessage: "Error Downloading Home Screen Data")
									}
								})
							} else {
								ProgressIndicatorController.dismissProgressView()
								self.showErrorDownloadAlertToUser(withErrorMessage: "Error Downloading Offers Data")
							}
						})
						
					} else {
						ProgressIndicatorController.dismissProgressView()
						self.showErrorDownloadAlertToUser(withErrorMessage: "Error Downloading Slider Data")
					}
				})
			}
		}
	}
}

extension DownloaderViewController {
	
	func downloadHomeSectionsData(withSuccessHandler successHandler: SuccessHandler? = nil) {
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
							var homeProducts = [String: AnyObject]()
							homeProducts["homeProductsSectionDict"] = newProductCollection as AnyObject?
							MagicalRecord.save({ (context) in
								HomeProducts.mr_import(from: homeProducts, in: context)
							})
							successHandler?(true)
						}
					} else {
						successHandler?(false)
					}
				})
			}
		}
	}
	
	func downloadProductsData(withSuccessHandler successHandler: SuccessHandler? = nil) {
		let languageId = (AppManager.languageType() == .arabic) ? "2" : "1"
		let syncFormat = "&language_id=\(languageId)&customer_group_id=16"
		SyncManager.syncOperation(operationType: .downloadAllProducts, info: syncFormat) { (response, error) in
			if error == nil {
				if let prodResponse = response as? [[String: AnyObject]] {
					for productData in prodResponse {
						self.didFinishAllProductDownload(data: productData)
					}
					successHandler?(true)
				}
			} else {
				successHandler?(false)
			}
		}
	}
	
	func downloadSlidersData(withSuccessHandler successHandler: SuccessHandler? = nil) {
		
		SyncManager.syncOperation(operationType: .getSliderImages, info: "") { (response, error) in
			print("response====: \(response)")
			if error == nil {
				
				if let imageResponse = response as? [[String: AnyObject]] {
					for bannerImage in imageResponse {
						if let sliderImageInfo = bannerImage["module_data"] as? String {
							if let JSONObject = sliderImageInfo.parseJSONString as? [String: AnyObject] {
								print("JSON Object: \(JSONObject)")
								if let imageSection = JSONObject["slides"] as? [[String: AnyObject]] {
									for imageObject in imageSection {
										var bannerDict = [String: AnyObject]()
										if let imageData = imageObject["image"] as? [String: AnyObject] {
											if let imageURL = imageData["1"] as? String {
												print("Image URL: \(imageURL)")
												bannerDict["image"] = imageURL as AnyObject
											}
										}
										if let imageURLStr = bannerDict["image"] as? String {
											let prorperURL = imageURLStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
											SyncManager.syncOperation(operationType: .imageDownloadOperation, info: prorperURL, completionHandler: { (imageData, error) in
												if error == nil {
													bannerDict["imageData"] = imageData as AnyObject?
													
													if let productLink = imageObject["link"] as? [String: AnyObject] {
														bannerDict["menuType"]=productLink["menu_type"] as AnyObject
														
														print("Image menuType: \(bannerDict["menuType"])")
														if let menuItem = productLink["menu_item"] as? [String: AnyObject] {
															bannerDict["id"] = menuItem["id"] as AnyObject
															bannerDict["name"] = menuItem["name"] as AnyObject
														}
													}
													
													MagicalRecord.save(blockAndWait: { context in
														let _ = Banners.mr_import(from: bannerDict, in: context)
													})
												} else {
													
												}
											})
										}
									}
								}
							}
						}
					}
					successHandler?(true)
				}
			} else {
				successHandler?(false)
			}
		}
	}
	
	func downloadOffersBannersData(withSuccessHandler successHandler: SuccessHandler? = nil) {
		SyncManager.syncOperation(operationType: .getHomeBannersList, info: "") { (response, error) in
			if error == nil {
				if let imageResponse = response as? [[String: AnyObject]] {
					for banner in imageResponse {
						if let bannerData = banner["module_data"] as? String {
							if let JSONObject = bannerData.parseJSONString as? [String: AnyObject] {
								print("JSON Object: \(JSONObject)")
								var offerProduDict = [String: AnyObject]()
								if let imagesSection = JSONObject["sections"] as? [[String: AnyObject]] {
									for imageObject in imagesSection {
										if let imageData = imageObject["image"] as? [String: AnyObject] {
											if let imageURL = imageData["1"] as? String {
												offerProduDict["image"] = imageURL as AnyObject?
												print("Image URL: \(imageURL)")
											}
										}
										
										if let imageURLStr = offerProduDict["image"] as? String {
											let prorperURL = imageURLStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
											SyncManager.syncOperation(operationType: .imageDownloadOperation, info: prorperURL, completionHandler: { (imageData, error) in
												if error == nil {
													offerProduDict["imageData"] = imageData as AnyObject?
													
													if let linkId = imageObject["link"] as? [String: AnyObject] {
														offerProduDict["menuType"]=linkId["menu_type"] as AnyObject
														if let item = linkId["menu_item"] as? [String: AnyObject] {
															
															if let linkImageId = item["id"] as? String, let offerImageNam = item["name"] as? String {
																offerProduDict["categoryId"] = linkImageId as AnyObject?
																offerProduDict["name"] = offerImageNam as AnyObject?
															}
														}
													}
													
													MagicalRecord.save(blockAndWait: { context in
														let _ = OfferZone.mr_import(from: offerProduDict, in: context)
													})
												}
											})
										}
									}
								}
							}
						}
					}
				}
				successHandler?(true)
			} else {
				successHandler?(false)
			}
		}
	}
	
	func downloadBrandsData(withSuccessHandler successHandler: SuccessHandler? = nil) {
		successHandler?(true)
	}
	
	
	func downloadProductImages(withSuccessHandler successHandler: SuccessHandler? = nil) {
		if let products = Product.getAllProducts() {
			
			DispatchQueue.main.async {
				for (index, product) in products.enumerated() {
					self.myGroup.enter()
					if index <= 200 {
						self.progressTitleLabel = "Test change \(index)"
						if let productImageURL = product.image {
							let prorperURL = productImageURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
							let imageURlStr = URLBuilder.getImageDownloadBaseURL() + prorperURL!
							
							
							
								DispatchQueue.global().async {
									if let url = URL(string: imageURlStr) {
										do {
											let imageData = try Data(contentsOf: url)
											
											MagicalRecord.save({ (context) in
												let localProd = product.mr_(in: context)
												localProd?.imageData = imageData as NSData?
											}, completion: { (success, error) in
												print("Success Save Image")
												
												DispatchQueue.main.async {
													
													self.progressTitleLabel = "Test change \(index)"
													self.progressTitle.setNeedsDisplay()
													let percentage = Float(Float(index) / Float(/*products.count*/ 200.0))
													self.progressBar.setProgress(percentage, animated: false)
													if self.progressBar.progress == 1.0 {
														self.progressBar.isHidden = true
														self.progressIndicatorView.isHidden = true
														self.progressTitle.isHidden = true
													}
													self.progressBar.setNeedsDisplay()
												}
											})
										} catch let error {
											print("Error : \(error.localizedDescription)")
										}
									}
								}
						} else {
							print("Error Image URL")
						}
					}
					if index == 200 {
						successHandler?(true)
					}
				}
			}
		}
	}
	
	func didFinishAllProductDownload(data: [String: AnyObject]) {
		
		if AppManager.currentApplicationMode() == .offline {
//			MagicalRecord.save({ (context) in
//				_ = Product.mr_import(from: data, in: context)
//			}, completion: { (success, error) in
//				print("Image Save Success")
//			})
			MagicalRecord.save(blockAndWait: { context in
				_ = Product.mr_import(from: data, in: context)
			})
		}
	}
	
	func handleLoading(withMessage message: String) {
		ProgressIndicatorController.showLoading(withText: message, closure: { (ProgressIndicatorController) in
			print("Progress Indicator Started")
		})
	}
	
	func dismissActivityLoading(withDismissHandler handler: SuccessHandler? = nil) {
		ProgressIndicatorController.dismissProgressView { (success) in
			if success {
				handler?(true)
			} else {
				handler?(false)
			}
		}
	}
	
	func showErrorDownloadAlertToUser(withErrorMessage message: String) {
		let title = Constants.alertTitle
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
		alertController.addAction(okAction)
		self.present(alertController, animated: true, completion: nil)
	}
	
	func downloadProductCategories(withSuccessHandler successHandler: SuccessHandler? = nil) {
		let productCategories = ProductCategory.getAllProducts()
		print("Product Categories: \(productCategories)")
		
		if let productCategories = ProductCategory.getAllProducts() {
			
			for category in productCategories {
				
				if let categoryImage = category.imageURL {
					let properURL = categoryImage.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
					
					SyncManager.syncOperation(operationType: .imageDownloadOperation, info: properURL, completionHandler: { (imageData, error) in
						if error == nil {
							do {
								DispatchQueue.main.async {
									self.progressTitle.text = "Test change 6"
								}

								MagicalRecord.save({ (context) in
									let localCategory = category.mr_(in: context)
									if let data = imageData as? Data {
										localCategory?.imageData = data as NSData?
									}
								})
							}
						}
					})
				}
			}
			successHandler?(true)
		}
	}
	
	func downloadHomeProductImages(withSuccessHandler successHandler: SuccessHandler? = nil) {
		if let sectionList = Sections.getAllSectionsList() {
			for section in sectionList {
				if let products = section.products?.allObjects as? [Product] {
					for product in products {
						if let productImageURL = product.image {
							let properURL = productImageURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
							
							SyncManager.syncOperation(operationType: .imageDownloadOperation, info: properURL, completionHandler: { (imageData, error) in
								if error == nil {
									do {
										MagicalRecord.save({ (context) in
											let localProduct = product.mr_(in: context)
											if let data = imageData as? Data {
												localProduct?.imageData = data as NSData?
											}
										})
									}
								}
							})
						}
					}
				}
			}
			successHandler?(true)
		}
	}
	
	func downloadUserExistingAddress(withSuccessHandler successHandler: SuccessHandler? = nil) {
		
		if let currentUserId = UserDefaultManager.sharedManager().loginUserId {
			var addressInfo = [String: AnyObject]()
			SyncManager.syncOperation(operationType: .getMyProfileData, info: currentUserId, completionHandler: { (response, error) in
				if error == nil {
					if let userData = response as? [[String: AnyObject]] {
						let user = userData.first
						addressInfo["firstname"] = user?["firstname"] as? String as AnyObject?
						addressInfo["lastname"] = user?["lastname"] as? String as AnyObject?
						addressInfo["email"] = user?["email"] as? String as AnyObject?
						addressInfo["telephone"] = user?["telephone"] as? String as AnyObject?
					}
					
					SyncManager.syncOperation(operationType: .getUserExistingAddress, info: currentUserId) { (response, error) in
						if error == nil {
							//self.userExistingAddressData = []
							if let responseData = response as? [[String: AnyObject]] {
								
								
								for adressObj in responseData {
									for key in adressObj.keys {
										if let addressData = adressObj[key] as? [String: AnyObject] {
											addressInfo["UserAddressDict"] = addressData as AnyObject?
											
											MagicalRecord.save({ (context) in
												User.mr_import(from: addressInfo, in: context)
											})
										}
									}
								}
							}
							successHandler?(true)
						} else {
							successHandler?(false)
						}
					}
				}
			})
			
		}
	}
}

