//
//  LanguageViewController.swift
//  Alzahrani
//
//  Created by shilpa shree on 5/26/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit
import Localize_Swift
import MagicalRecord

enum LanguageType: String {
    case english = "English"
    case arabic = "Arabic"
}

enum AppMode: String {
    case online = "Online"
    case offline = "Offline"
}

extension LanguageType {
    
    static let caseValues = [english, arabic]
    static func count() -> Int {
        return self.caseValues.count
    }
}

class LanguageViewController: MirroringViewController {
    
    //MARK:- Properties
    var selectedLanguageType: LanguageType? = .english
    var selectedIndexPath: IndexPath?
	
	var productsData = [[String: AnyObject]]()
	var myGroup = DispatchGroup()
	
    @IBOutlet weak var applyButton: UIBarButtonItem!
    @IBOutlet weak var languageTableView: UITableView!
    
    //MARK:- LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func applyButtonTapped(_ sender: Any) {
		if AppManager.isUserLoggedIn {
			if AppManager.getLoggedInUserType() == .salesExecutive {
				let okTitle = NSLocalizedString("OK", comment: "")
				let cancleTitle = NSLocalizedString("Cancel", comment: "")
				let alertTitle = NSLocalizedString("Alzahrani", comment: "")
				
				let message = NSLocalizedString("DOWNLOAD_OFFLINE_DATA_PROMPT", comment: "")
				
				let alertController = UIAlertController(title: alertTitle, message: message, preferredStyle: .alert)
				let okAction = UIAlertAction(title: okTitle, style: .default, handler: { (UIAlertAction) in
					self.downloadOfflineData(withSuccessHandler: { (success) in
						if success {
							self.performLanguageChange()
						}
					})
				})
				
				let cancelAction = UIAlertAction(title: cancleTitle, style: .default, handler: { (UIAlertAction) in
					self.performLanguageChange()
					//FIXME:- New Change on 27/10/2017
					UserDefaultManager.sharedManager().currentAppMode = "Online"
					UserDefaultManager.sharedManager().isProductDwonloaded = false
					let _ = self.navigationController?.popViewController(animated: true)
					//FIXME:- New Change on 27/10/2017
				})
				
				alertController.addAction(okAction)
				alertController.addAction(cancelAction)
				
				self.present(alertController, animated: true, completion: nil)
			} else {
				self.performLanguageChange()
			}
		} else {
			self.performLanguageChange()
		}
    }
}

//MARK:- Helper Methods:
extension LanguageViewController: UITableViewDataSource {
	
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
	
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LanguageType.count()
    }
	
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LanguageTypeCell", for: indexPath) as? LanguageSelectionTableViewCell
        cell?.selectionStyle = .none
        
        if self.selectedIndexPath == indexPath {
            cell?.accessoryType = .checkmark
        } else {
            cell?.accessoryType = .none
        }
        cell?.languageImageView.image = UIImage(named: LanguageType.caseValues[indexPath.row].rawValue)
        cell?.languageNameLabel.text = LanguageType.caseValues[indexPath.row].rawValue
        
        if AppManager.languageType() == LanguageType.caseValues[indexPath.row] {
            cell?.accessoryType = .checkmark
        }
        return cell!
    }
}

//MARK:- UITableViewDelegate
extension LanguageViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            if cell.accessoryType == .checkmark {
                cell.accessoryType = .none
            } else {
                cell.accessoryType = .checkmark
            }
        }
        self.selectedIndexPath = indexPath
        UserDefaultManager.sharedManager().selectedLanguageId = LanguageType.caseValues[indexPath.row].rawValue
        self.languageTableView.reloadData()
    }
}

extension UIViewController {
    func loopThroughSubViewAndFlipTheImageIfItsAUIImageView(subviews: [UIView]) {
        if subviews.count > 0 {
            for subView in subviews {
                if subView.isMember(of: UIImageView.self) && subView.tag < 0 {
                    let toRightArrow = subView as! UIImageView
                    if let _img = toRightArrow.image {
                        toRightArrow.image = UIImage(cgImage: _img.cgImage!, scale:_img.scale , orientation: UIImageOrientation.upMirrored)
                    }
                }
                loopThroughSubViewAndFlipTheImageIfItsAUIImageView(subviews: subView.subviews)
            }
        }
    }
}


extension LanguageViewController {
	
	func performLanguageChange() {
		
		if let languageId = UserDefaultManager.sharedManager().selectedLanguageId {
			if let selectedLanguageType = LanguageType(rawValue: languageId) {
				switch selectedLanguageType {
				case .english:
					Localize.setCurrentLanguage("en")
					LanguageManager.setAppleLAnguageTo(lang: "en")
					UIView.appearance().semanticContentAttribute = .forceLeftToRight
					if AppManager.currentApplicationMode() == .offline {
						//                        ProductsDownloader.sharedInstance.configureDownload(withType: .englishDownload)
					}
				case .arabic:
					Localize.setCurrentLanguage("en")
					LanguageManager.setAppleLAnguageTo(lang: "ar")
					self.loopThroughSubViewAndFlipTheImageIfItsAUIImageView(subviews: self.view.subviews)
					UIView.appearance().semanticContentAttribute = .forceRightToLeft
					if AppManager.currentApplicationMode() == .offline {
						//                        ProductsDownloader.sharedInstance.configureDownload(withType: .arabicDownload)
					}
				}
				
				let rootviewcontroller: UIWindow = ((UIApplication.shared.delegate?.window)!)!
				rootviewcontroller.rootViewController = self.storyboard?.instantiateViewController(withIdentifier: "LanguageSelectionNavigationController")
				let mainwindow = (UIApplication.shared.delegate?.window!)!
				mainwindow.backgroundColor = UIColor(hue: 0.6477, saturation: 0.6314, brightness: 0.6077, alpha: 0.8)
				UIView.transition(with: mainwindow, duration: 0.55001, options: .transitionFlipFromLeft, animations: { () -> Void in
				}) { (finished) -> Void in
				}
				AppManager.setDefaultRootViewController(state: .Home)
			}
		}
	}
	
	
	func downloadOfflineData(withSuccessHandler successHandler: SuccessHandler? = nil) {
		UserDefaultManager.sharedManager().isProductDwonloaded = false
		UserDefaultManager.sharedManager().currentAppMode = "Offline"
		let message = NSLocalizedString("DOWNLOADING_PRODUCTS", comment: "")
		self.handleLoading(withMessage: message)
		ProductsDownloader.sharedInstance.configureDownload(withType: .firstTime)
		//ProductsDownloader.sharedInstance.handleHomeScreenProducts()
		let productCategories = ProductCategory.getAllProducts()
		print("Product Cat: \(productCategories)")
		self.downloadUserExistingAddress(withSuccessHandler: { (success) in
			if success {
				self.downloadSlidersData(withSuccessHandler: { (success) in
					if success {
						self.downloadOffersBannersData(withSuccessHandler: { (success) in
							if success {
								self.downloadHomeSectionsData(withSuccessHandler: { (success) in
									if success {
										self.downloadProductsData(withSuccessHandler: { (success) in
											if success {
												self.downloadProductCategories(withSuccessHandler: { (success) in
													if success {
														
														self.downloadBrandsInfoData(withSuccessHandler: { (success) in
															if success {
																self.downloadProductImages(withSuccessHandler: { (success) in
																	if success {
																		
																		self.downloadHomeProductImages(withSuccessHandler: { (success) in
																			if success {
																				self.dismissActivityLoading(withDismissHandler: { (success) in
																					DispatchQueue.main.async {
																						var stateInfoDict = [String: AnyObject]()
																						stateInfoDict["App_State"] = AppMode.offline as AnyObject?
																						NotificationCenter.default.post(name: Notification.Name("APP_STATE_NOTIFICATION"), object: stateInfoDict)
																						UserDefaultManager.sharedManager().currentAppMode = "Online"
																						UserDefaultManager.sharedManager().isProductDwonloaded = true
																						
																						successHandler?(true)
																					}
																				})
																			}
																		})
																	} else {
																		ProgressIndicatorController.dismissProgressView()
																		self.showErrorDownloadAlertToUser(withErrorMessage: "Error Downloading Product Images")
																		UserDefaultManager.sharedManager().isProductDwonloaded = false
																	}
																})
															} else {
																ProgressIndicatorController.dismissProgressView()
																self.showErrorDownloadAlertToUser(withErrorMessage: "Error Downloading Brands Data")
																UserDefaultManager.sharedManager().isProductDwonloaded = false
															}
														})
													} else {
														ProgressIndicatorController.dismissProgressView()
														self.showErrorDownloadAlertToUser(withErrorMessage: "Error Downloading Product Categories")
														UserDefaultManager.sharedManager().isProductDwonloaded = false
													}
												})
												
											} else {
												ProgressIndicatorController.dismissProgressView()
												self.showErrorDownloadAlertToUser(withErrorMessage: "Error Downloading Products Data")
												UserDefaultManager.sharedManager().isProductDwonloaded = false
											}
										})
									} else {
										ProgressIndicatorController.dismissProgressView()
										self.showErrorDownloadAlertToUser(withErrorMessage: "Error Downloading Home Screen Data")
										UserDefaultManager.sharedManager().isProductDwonloaded = false
									}
								})
							} else {
								ProgressIndicatorController.dismissProgressView()
								self.showErrorDownloadAlertToUser(withErrorMessage: "Error Downloading Offers Data")
								UserDefaultManager.sharedManager().isProductDwonloaded = false
							}
						})
						
					} else {
						ProgressIndicatorController.dismissProgressView()
						self.showErrorDownloadAlertToUser(withErrorMessage: "Error Downloading Slider Data")
						UserDefaultManager.sharedManager().isProductDwonloaded = false
						
					}
				})
			} else {
				ProgressIndicatorController.dismissProgressView()
				self.showErrorDownloadAlertToUser(withErrorMessage: "Error Downloading User Existing Address")
				UserDefaultManager.sharedManager().isProductDwonloaded = false
				
			}
		})
	}
}

extension LanguageViewController {
	
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
					print("Product Response: \(prodResponse)")
					self.productsData = prodResponse
					
					for var product in prodResponse {
						var specificationsList = [[String: AnyObject]]()
						var specificationDict = [String: AnyObject]()
						specificationDict["product_id"] = product["product_id"]
						if let enProductSpecification = product["product_specification"] as? [[String: AnyObject]] {
							for specification in enProductSpecification {
								specificationDict["enName"] = specification["name"]
								specificationDict["enText"] = specification["text"]
								
								specificationsList.append(specificationDict)
							}
						}
						
						if let arProductSpecification = product["arproduct_specification"] as? [[String: AnyObject]] {
							for specification in arProductSpecification {
								specificationDict["arName"] = specification["name"]
								specificationDict["arText"] = specification["text"]
								
								specificationsList.append(specificationDict)
							}
						}
						product["SpecificationsDict"] = specificationsList as AnyObject?
						self.didFinishAllProductDownload(data: product)
					}
				}
				
				successHandler?(true)
				//ProgressIndicatorController.dismissProgressView()
			} else {
				successHandler?(false)
				//ProgressIndicatorController.dismissProgressView()
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
	
	func downloadBrandsInfoData(withSuccessHandler successHandler: SuccessHandler? = nil) {
		SyncManager.syncOperation(operationType: .getBrandsList, info: "") { (response, error) in
			if error == nil {
				print("Brands Downloaded \(response)")
				
				self.downloadBrandsData(withSuccessHandler: { (success) in
					if success {
						successHandler?(true)
					} else {
						successHandler?(false)
					}
				})
			}
		}
	}
	
	func downloadBrandsData(withSuccessHandler successHandler: SuccessHandler? = nil) {
		self.dismissActivityLoading(withDismissHandler: { (success) in
			if success {
				ProgressIndicatorController.showProgress(withText: "Downloading Brands", closure: { (progressIndicatorController) in
					if let brandsList = Brands.getAllBrands() {
						DispatchQueue.global(qos: .utility).async {
							for (index, brand) in brandsList.enumerated() {
								if let image = brand.brandImage {
									let prorperURL = image.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
									let imageURlStr = URLBuilder.getImageDownloadBaseURL() + prorperURL!
									
									if let url = URL(string: imageURlStr) {
										do {
											let imageData = try Data(contentsOf: url)
											let percentage = Float(Float(index) / Float(brandsList.count))
											//source.add(data: UInt(percentage))
											DispatchQueue.main.async {
												ProgressIndicatorController.sharedProgressController.updateProgress(withProgress: percentage)
											}
											MagicalRecord.save({ (context) in
												let localProd = brand.mr_(in: context)
												localProd?.brandImageData = imageData as NSData?
											}, completion: { (success, error) in
												print("Success Save Image")
												
											})
										} catch let error {
											print("Error : \(error.localizedDescription)")
										}
									}
								}
								if index == brandsList.count - 1 {
									successHandler?(true)
								}
							}
						}
					}
				})
			}
		})
	}
	
	
	func downloadProductImages(withSuccessHandler successHandler: SuccessHandler? = nil) {
		
		self.dismissActivityLoading { (success) in
			ProgressIndicatorController.showProgress(withText: "Downloading Products") { (progressIndicatorController) in
				var progressCounter: Float = 0
				let source = DispatchSource.makeUserDataAddSource(queue: .main)
				
				source.setEventHandler(handler: { [unowned self] in
					progressCounter = Float(source.data)
					
					ProgressIndicatorController.sharedProgressController.updateProgress(withProgress: progressCounter)
				})
				source.resume()
				
				if let products = Product.getAllProducts() {
					DispatchQueue.global(qos: .utility).async {
						for (index, product) in products.enumerated() {
							if index <= products.count {
								self.myGroup.enter()
								if let productImageURL = product.image {
									let prorperURL = productImageURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
									let imageURlStr = URLBuilder.getImageDownloadBaseURL() + prorperURL!
									
									if let url = URL(string: imageURlStr) {
										do {
											let imageData = try Data(contentsOf: url)
											let percentage = Float(Float(index) / Float(products.count))
											source.add(data: UInt(percentage))
											DispatchQueue.main.async {
												ProgressIndicatorController.sharedProgressController.updateProgress(withProgress: percentage)
											}
											MagicalRecord.save({ (context) in
												let localProd = product.mr_(in: context)
												localProd?.imageData = imageData as NSData?
											}, completion: { (success, error) in
												print("Success Save Image")
												
											})
										} catch let error {
											print("Error : \(error.localizedDescription)")
										}
									}
								}
							}
							if index == products.count - 1 {
								successHandler?(true)
							}
						}
					}
				}
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
