//
//  LoginViewController.swift
//  Alzahrani
//
//  Created by Hardwin on 09/05/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit
import MagicalRecord

class LoginViewController: UIViewController {
    
    //MARK:- IB-Outlets:
    @IBOutlet weak var emailField: SkyFloatingLabelTextField!
    @IBOutlet weak var passwordField: SkyFloatingLabelTextField!
	
	var productsData = [[String: AnyObject]]()
	var myGroup = DispatchGroup()
    
    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    
    @IBAction func loginButtontapped(_ sender: Any) {
        self.loginUser()
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func newUserSignup(_ sender: Any) {
        let registerVc = self.storyboard?.instantiateViewController(withIdentifier: "RegistrationViewController") as? RegistrationViewController
        registerVc?.screenType = .login
        let menuNavController = UINavigationController(rootViewController: registerVc!)
        self.present(menuNavController, animated:true, completion: nil)
    }
    
    
    @IBAction func forgotPasswordTapped(_ sender: Any) {
//        if let forgotPasswordVc = self.storyboard?.instantiateViewController(withIdentifier: ForgotPasswordViewController.selfName()) as? ForgotPasswordViewController {
//            self.navigationController?.pushViewController(forgotPasswordVc, animated: true)
//        }
        
    }
   
}

//MARK:- Helper Methods:
extension LoginViewController {
    
    func validateUser() -> Bool {
        var errorMessage: String?
        
        var validEmail: Bool?
        if (self.emailField.text?.isValidEmail())! {
            validEmail = true
        } else {
            validEmail = false
            errorMessage = NSLocalizedString("Please enter Valid Email", comment: "")
            showAlertwith(alertMessage: errorMessage!)
        }
        var validPassword: Bool? = false
        if (((self.passwordField.text?.characters.count)! < 6) || (self.passwordField.text! == "")) {
            validPassword = false
            errorMessage = NSLocalizedString("Please enter Valid Password", comment: "")
            showAlertwith(alertMessage: errorMessage!)
        } else {
            validPassword = true
        }
        if (validEmail! && validPassword!) {
            return true
        } else {
            return false
        }
    }
    
    func loginUser() {
        if validateUser() {
            var languageId = ""
			if let languageType = AppManager.languageType() {
				switch languageType {
				case .arabic:
					languageId = "2"
				case .english:
					languageId = "1"
				}
			}
            if let emailid = self.emailField.text, let password = self.passwordField.text {
                let loginParameters = "email=\(emailid)&password=\(password)&language_id=\(languageId)"
                
                SyncManager.syncOperation(operationType: .Login, info: loginParameters, completionHandler: { (response, error) in
                    if error == nil {
                        print("Login Response: \(response)")
                        if let userData = response as? [String: AnyObject] {
                            if let error = userData["error"] as? [String: AnyObject] {
                                if let errorString = error["warning"] as? String {
                                    self.showAlertwith(alertMessage: errorString)
                                }
                            } else {
                                if let userId = userData["customer_id"] as? String, let userFirstName = userData["customer_firstname"] as? String, let userLastName = userData["customer_lastname"] as? String, let customerGroupId = userData["customer_group_id"] as? String, let email = userData["customer_email"] as? String, let mobile = userData["customer_mobile"] as? String {
                                    UserDefaultManager.sharedManager().isAuthenticated = true
                                    UserDefaultManager.sharedManager().loginUserId = userId
                                    UserDefaultManager.sharedManager().customerGroupId = customerGroupId
                                    UserDefaultManager.sharedManager().loginUserName = userFirstName + userLastName
                                    UserDefaultManager.sharedManager().userFirstName = userFirstName
                                    UserDefaultManager.sharedManager().userLastName = userLastName
                                    UserDefaultManager.sharedManager().customerEmail = email
                                    UserDefaultManager.sharedManager().customerMobile = mobile
                                    
                                    print("Login successful with Result \(response)")
											
                                    if DBManager.sharedManager().cleanAndResetupDB() {
                                        if AppManager.currentApplicationMode() == .offline {
                                            ProductsDownloader.sharedInstance.configureDownload(withType: .firstTime)
                                        }
                                    }
											if let custGroupId = userData["customer_group_id"] as? String {
												if custGroupId == "16" {
													let alertTitle = NSLocalizedString("Alzahrani", comment: "")
													let okTitle = NSLocalizedString("OK", comment: "")
													let cancleTitle = NSLocalizedString("Cancel", comment: "")
													let alertMessage = NSLocalizedString("DOWNLOAD_OFFLINE_DATA_PROMPT", comment: "")
													let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
													
													let okAction = UIAlertAction(title: okTitle, style: .default, handler: { (UIAlertAction) in
														UserDefaultManager.sharedManager().currentAppMode = "Offline"
														self.downloadOfflineData()
														
													})
													
													let cancelAction = UIAlertAction(title: cancleTitle, style: .default, handler: { (UIAlertAction) in
														NotificationCenter.default.post(name: Notification.Name("MyCartUpdateNotification"), object: nil)
														NotificationCenter.default.post(name: Notification.Name("WishListUpdateNotification"), object: nil)
														UserDefaultManager.sharedManager().isProductDwonloaded = false
														AppManager.setDefaultRootViewController(state: .Home)
													})
													alertController.addAction(okAction)
													alertController.addAction(cancelAction)
													
													self.present(alertController, animated: true, completion: nil)
												} else {
													NotificationCenter.default.post(name: Notification.Name("MyCartUpdateNotification"), object: nil)
													NotificationCenter.default.post(name: Notification.Name("WishListUpdateNotification"), object: nil)
													AppManager.setDefaultRootViewController(state: .Home)
												}
											}
										}
                            }
                        }
                    }
                })
            }
        }
        
        func showAlertWith(warningMsg msg: String) {
            let alertController = UIAlertController(title: Constants.alertTitle, message: msg, preferredStyle: .alert)
            let okAction = UIAlertAction(title: NSLocalizedString(Constants.alertAction, comment: ""), style: .default, handler: { (UIAlertAction) in
                NotificationCenter.default.post(name: Notification.Name(Constants.sliderMenuFieldTapNotification), object: nil)
            })
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
        
        func userDataFieldsValidation() {
            
            if emailField.text?.characters.count == 0 || isValidEmail(emailField.text!) == false {
                emailField.errorMessage = NSLocalizedString("Please enter Valid Email", comment: "")
            }
            if passwordField.text?.characters.count == 0 {
                passwordField.errorMessage = "Password must be minimum length of 6 characters."
            }
            if (passwordField.text?.characters.count)! <= 6 {
                passwordField.errorMessage = "Password must be minimum length of 6 characters."
            }
            else {
                
            }
        }
        
        func isValidEmail(_ testStr:String) -> Bool {
            
            let emailRegEx = "^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$"
            
            let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            let result = emailTest.evaluate(with: testStr)
            
            return result
        }
    }
    
    func showAlertwith(alertMessage msg: String) {
        let alertController = UIAlertController(title: Constants.alertTitle, message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

//MARK:- UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
	
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		
        if textField.returnKeyType == .next{
            emailField.resignFirstResponder()
            passwordField.becomeFirstResponder()
        }
        if textField.returnKeyType == .done{
            passwordField.resignFirstResponder()
        }
        return true
    }
	
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == emailField
        {
            textField.returnKeyType = .next
        }
        if textField == passwordField{
            textField.returnKeyType = .done
        }
    }
}


extension LoginViewController {
	
	func downloadOfflineData() {
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
														
														self.downloadBrandsData(withSuccessHandler: { (success) in
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
																
																						NotificationCenter.default.post(name: Notification.Name("MyCartUpdateNotification"), object: nil)
																						NotificationCenter.default.post(name: Notification.Name("WishListUpdateNotification"), object: nil)
																						AppManager.setDefaultRootViewController(state: .Home)

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

extension LoginViewController {
	
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
	
	func downloadBrandsData(withSuccessHandler successHandler: SuccessHandler? = nil) {
		SyncManager.syncOperation(operationType: .getBrandsList, info: "") { (response, error) in
			if error == nil {
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
			} else {
				successHandler?(false)
			}
		}
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
