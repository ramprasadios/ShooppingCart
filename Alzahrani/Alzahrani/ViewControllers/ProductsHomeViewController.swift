
//
//  ProductsHomeViewController.swift
//  Alzahrani
//
//  Created by Hardwin on 02/05/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit
import Speech
import MagicalRecord

class ProductsHomeViewController: UIViewController {
	
	//MARK:- IB-Outlets:
	@IBOutlet weak var productsTableView: UITableView!
	@IBOutlet weak var searchTextField: SearchTextField!
	
	@IBOutlet weak var hambergerMenuButtonItem: UIBarButtonItem!
	
	
	//Properties:
	var images = ["image1", "image2", "image3", "image4"]
	fileprivate let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "ar-SA"))!
	fileprivate var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
	fileprivate var recognitionTask: SFSpeechRecognitionTask?
	fileprivate let audioEngine = AVAudioEngine()
	var picker = UIImagePickerController()
	var voiceSearchResult: String = ""
	var imageScrollTimer : Timer!
	var searchByVoiceText: String? {
		didSet {
			
			self.showSearchResults(withText: voiceSearchResult)
		}
	}
	
	var categoriesInfo = [[String: AnyObject]]()
	var newArrivalsInfo = [[String: AnyObject]]()
	var topSelllingInfo = [[String: AnyObject]]()
	var productListInfo=[[String: AnyObject]]()
	var productInfo=[[String: AnyObject]]()
	var categoryInfo=[[String: AnyObject]]()
	var offerZoneInfo=[[String: AnyObject]]()
	var sectionTitleInfo=[String]()
	let myGroup = DispatchGroup()
	var bannerData = [BannerInfoData]()
	var brandsListInfo = [[String: AnyObject]]()
	
	
	//MARK:- Life Cycle:
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
		self.initialDownload()
		self.initialUISetup()
		self.setupVoiceSearch()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		self.setupAutoScrollFunctionality()
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.setNavigationBarImage()
		self.view.endEditing(true)
		self.setupStatusBarView()
		self.downloadMyCartData()
		self.downloadWishlists()
		self.searchTextField.text = ""
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		self.removeNavigationBarImage()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: sender)
		if segue.identifier == Constants.showSubCategories {
			if let subCategoriesVc = segue.destination as? SubCategoriesViewController {
				print("SubCategories VC = \(subCategoriesVc)")
			}
		}
	}
	
	//IB Action Mehtods:
	@IBAction func searchProductsFromVoice(_ sender: Any) {
		
		if let searchVoiceVc = self.storyboard?.instantiateViewController(withIdentifier: VoiceSearchWindowViewController.selfName()) as? VoiceSearchWindowViewController {
			self.present(searchVoiceVc, animated: true, completion: nil)
		}
		/* if audioEngine.isRunning {
		audioEngine.stop()
		recognitionRequest?.endAudio()
		} else {
		startRecording()
		} */
	}
	
	@IBAction func searchProductsFromImage(_ sender: Any) {
		
		let optionMenuController = UIAlertController(title: nil, message: "", preferredStyle: .actionSheet)
		
		let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: {
			(alert: UIAlertAction!) -> Void in
			self.camera()
		})
		let gallerAction = UIAlertAction(title: "Photo Library", style: .default, handler: {
			(alert: UIAlertAction!) -> Void in
			self.photolibrary()
		})
		
		optionMenuController.addAction(cameraAction)
		optionMenuController.addAction(gallerAction)
		
		self.present(optionMenuController, animated: true, completion: nil)
	}
	
	@IBAction func searchButtonAction(_ sender: Any) {
		self.showSearchResults()
	}
	
	deinit {
		self.imageScrollTimer.invalidate()
	}
}

//MARK:- Helper Methods:
extension ProductsHomeViewController {
	
	func initialDownload() {
		
		if AppManager.currentApplicationMode() == .online {
			self.downloadSlidersData()
			self.getProductList()
			self.downloadAllCategories()
			self.downloadBrandsData()
			//self.downloadBrandsData()
//			self.downloadNewArrivals()
//			self.downloadTopSelliings()
		}
		
		//self.downloadProductBasedOnId(productId: "3641")
	}
	
	func initialUISetup() {
		
		self.setNavigationBarImage()
		self.setupLeftBarButtonItem()
		self.picker.delegate = self
		self.registerCustomTableCellNibs()
		self.addNotificationObserver()
		self.handleCartProductChanges()
		self.searchTextField.addTarget(self, action: #selector(ProductsHomeViewController.textFieldDidChange), for: .editingChanged)
		
		if UIDevice.current.userInterfaceIdiom == .pad {
			self.navigationController?.navigationBar.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: 200.0)
		}
	}
	
	func showAlertWith(warningMsg msg: String) {
		let alertController = UIAlertController(title: Constants.alertTitle, message: msg, preferredStyle: .alert)
		let okAction = UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
			let loginVc = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
			let menuNavController = UINavigationController(rootViewController: loginVc!)
			self.present(menuNavController, animated:true, completion: nil)
		})
		alertController.addAction(okAction)
		
		self.present(alertController, animated: true, completion: nil)
	}
	
	func initialTableViewSetup() {
		self.productsTableView.estimatedRowHeight = 150.0
		self.productsTableView.rowHeight = UITableViewAutomaticDimension
	}
	
	func getProductList() {
		if NetworkManager.sharedReachability.isReachable() {
			//Fetch All From Web
			self.productListInfo = []
			self.sectionTitleInfo = []
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
								self.productListInfo=newProductCollection
							}
							
							for newProd in newProductCollection {
								print("newProd:\(newProd)");
								if let sectionTitle=newProd["section_title"] as? String {
									self.sectionTitleInfo.append(sectionTitle)
								}
								
								let nib = UINib(nibName: "NewArrivalsTableViewCell", bundle: nil)
								self.productsTableView.register(nib, forCellReuseIdentifier: "NewArrivalsTableViewCell")
							}
						}
					}
					self.productsTableView.reloadData();
				})
			}
		}
	}
	
	func downloadSlidersData(withSuccessaHandler successHandler: SuccessHandler? = nil) {
		self.bannerData = []
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
										if let imageData = imageObject["image"] as? [String: AnyObject], let productLink = imageObject["link"] as? [String: AnyObject] {
											
											var imageURLStr = ""
											if let imageURL = imageData["1"] as? String {
												
												imageURLStr = imageURL
											}
											
											bannerDict["menuType"] = productLink["menu_type"] as AnyObject
											
											print("Image menuType: \(bannerDict["menuType"])")
											if let menuItem = productLink["menu_item"] as? [String: AnyObject], let menuType = productLink["menu_type"] as? String {
												if let linkId = menuItem["id"] as? String, let name = menuItem["name"] as? String {
													let bannnerInfo = BannerInfoData(withBannerImage: imageURLStr, andLink: linkId, withMenuType: menuType, andName: name)
													
													self.bannerData.append(bannnerInfo)
												}
											} else {
												let bannnerInfo = BannerInfoData(withBannerImage: imageURLStr, andLink: "", withMenuType: "custom", andName: "")
												
												self.bannerData.append(bannnerInfo)
											}
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
	
	func downloadBrandsData() {
		let custGrpId = (AppManager.isUserLoggedIn) ? UserDefaultManager.sharedManager().customerGroupId : "1"
		SyncManager.syncOperation(operationType: .getBrandsList, info: custGrpId) { (response, error) in
			
			if error == nil {
				
				print("New Arrival Response: \(response)")
				
				if let newArrivalsInfo = response as? [[String: AnyObject]] {
					self.brandsListInfo = newArrivalsInfo
				}
			}
		}
	}
	
	func registerCustomTableCellNibs() {
		
		let nib1 = UINib(nibName: "ImageScrollTableViewCell", bundle: nil)
		self.productsTableView.register(nib1, forCellReuseIdentifier: "ImageScrollTableViewCell")
		let nib2 = UINib(nibName: "OffersListTableViewCell", bundle: nil)
		self.productsTableView.register(nib2, forCellReuseIdentifier: "OffersListTableViewCell")
		let nib3 = UINib(nibName: "BrowseByCategoryTableViewCell", bundle: nil)
		self.productsTableView.register(nib3, forCellReuseIdentifier: "BrowseByCategoryTableViewCell")
		let nib4 = UINib(nibName: "OurBrandsTableViewCell", bundle: nil)
		self.productsTableView.register(nib4, forCellReuseIdentifier: "OurBrandsTableViewCell")
		let sectionHeaderNib = UINib(nibName: HomeSectionHeader.selfName(), bundle: nil)
		self.productsTableView.register(sectionHeaderNib, forHeaderFooterViewReuseIdentifier: HomeSectionHeader.selfName())
		let nib5 = UINib(nibName: "NewArrivalsTableViewCell", bundle: nil)
		self.productsTableView.register(nib5, forCellReuseIdentifier: "NewArrivalsTableViewCell")
	}
	
	func setupVoiceSearch() {
		speechRecognizer.delegate = self
		
		SFSpeechRecognizer.requestAuthorization { (authStatus) in
			
			var isButtonEnabled = false
			
			switch authStatus {
			case .authorized:
				isButtonEnabled = true
				
			case .denied:
				isButtonEnabled = false
				print("User denied access to speech recognition")
				
			case .restricted:
				isButtonEnabled = false
				print("Speech recognition restricted on this device")
				
			case .notDetermined:
				isButtonEnabled = false
				print("Speech recognition not yet authorized")
			}
			
			OperationQueue.main.addOperation() {
				//self.voiceButton.isEnabled = isButtonEnabled
				self.searchTextField.searchByVoiceButton?.isEnabled = isButtonEnabled
			}
		}
	}
	
	///Used for recording
	func startRecording() {
		
		if recognitionTask != nil {
			recognitionTask?.cancel()
			recognitionTask = nil
		}
		
		let audioSession = AVAudioSession.sharedInstance()
		do {
			try audioSession.setCategory(AVAudioSessionCategoryRecord)
			try audioSession.setMode(AVAudioSessionModeMeasurement)
			try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
		} catch {
			print("audioSession properties weren't set because of an error.")
		}
		
		recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
		guard let inputNode = audioEngine.inputNode else {
			fatalError("Audio engine has no input node")
		}
		
		guard let recognitionRequest = recognitionRequest else {
			fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
		}
		
		recognitionRequest.shouldReportPartialResults = true
		
		recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
			
			var isFinal = false
			
			if result != nil {
				
				self.searchTextField.text = result?.bestTranscription.formattedString
				self.searchByVoiceText = self.searchTextField.text
				isFinal = (result?.isFinal)!
			}
			
			if error != nil || isFinal {
				self.audioEngine.stop()
				self.audioEngine.inputNode?.removeTap(onBus: 0)
				
				self.recognitionRequest = nil
				self.recognitionTask = nil
				
				//self.voiceButton.isEnabled = true
				self.searchTextField.searchByVoiceButton?.isEnabled = true
			}
		})
		
		let recordingFormat = inputNode.outputFormat(forBus: 0)
		inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
			self.recognitionRequest?.append(buffer)
		}
		
		audioEngine.prepare()
		
		do {
			try audioEngine.start()
		} catch {
			print("audioEngine couldn't start because of an error.")
		}
		
		self.searchTextField.text = "Say something, I'm listening!"
	}
	
	func photolibrary() {
		picker.allowsEditing = false
		picker.sourceType = .photoLibrary
		picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
		present(picker, animated: true, completion: nil)
	}
	
	func camera() {
		
		if UIImagePickerController.isSourceTypeAvailable(.camera) {
			picker.allowsEditing = false
			picker.sourceType = UIImagePickerControllerSourceType.camera
			picker.cameraCaptureMode = .photo
			picker.modalPresentationStyle = .fullScreen
			present(picker,animated: true,completion: nil)
		} else {
			noCamera()
		}
	}
	
	func noCamera() {
		
		let alertVC = UIAlertController(
			title: "No Camera",
			message: "Sorry, this device has no camera",
			preferredStyle: .alert)
		let okAction = UIAlertAction(
			title: "OK",
			style:.default,
			handler: nil)
		alertVC.addAction(okAction)
		present(
			alertVC,
			animated: true,
			completion: nil)
	}
	
	func setNavigationBarImage() {
		let navbarImageView = UIImage(named: "NavBarLogo")
		//        let navbarImageView = UIImage(named: "navBarNew")
		self.navigationController?.navigationBar.setBackgroundImage(navbarImageView?.resizableImage(withCapInsets: UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0), resizingMode: .stretch), for: .top, barMetrics: .default)
	}
	
	func setupLeftBarButtonItem() {
		if let hambergerImage = UIImage(named: "hamberger_menu_Icon") {
			let leftBarButtonItem = UIBarButtonItem(image: hambergerImage, style: .plain, target: self, action: #selector(ProductsHomeViewController.showUserMenu))
			if AppManager.languageType() == .arabic {
				self.navigationItem.rightBarButtonItem = leftBarButtonItem
			} else {
				self.navigationItem.leftBarButtonItem = leftBarButtonItem
			}
		}
	}
	
	func showUserMenu() {
		NotificationCenter.default.post(name: Notification.Name(Constants.hambergerTappedNotification), object: nil)
	}
	
	///Only used for making the status bar Transparent.
	func setupStatusBarView() {
		
		if let statusWindow = UIApplication.shared.value(forKey: "statusBarWindow") as? UIView {
			let statusBar = statusWindow.subviews[0] as UIView
			statusBar.backgroundColor = UIColor.white.withAlphaComponent(0.45)
		}
	}
	
	func downloadMyCartData() {
		
		if AppManager.currentApplicationMode() == .online {
			if NetworkManager.sharedReachability.isReachable() {
				if AppManager.isUserLoggedIn {
					//Fetch All From Web
					
					let userDefaults = UserDefaultManager.sharedManager()
					var languageId: String?
					if let langId = LanguageType(rawValue: UserDefaultManager.sharedManager().selectedLanguageId!) {
						switch langId {
						case .english:
							languageId = "1"
						case .arabic:
							languageId = "2"
						}
					}
					if let customerId = userDefaults.loginUserId, let customerGroupId = userDefaults.customerGroupId, let languageId = languageId {
						let syncDataFormat = "&customer_group_id=\(customerGroupId)&customer_id=\(customerId)&language_id=\(languageId)"
						
						SyncManager.syncOperation(operationType: .getAllCartData, info: syncDataFormat, completionHandler: { (response, error) in
							if error == nil {
								print("Response MyCart: \(response)")
								if let _ = response as? [[String: AnyObject]] {
									NotificationCenter.default.post(name: Notification.Name("MyCartUpdateNotification"), object: nil)
								}
							}
						})
					}
				}
			}
		} else {
			NotificationCenter.default.post(name: Notification.Name("MyCartUpdateNotification"), object: nil)
		}
	}
	
	func downloadWishlists() {
		if AppManager.currentApplicationMode() == .online {
			if NetworkManager.sharedReachability.isReachable() {
				if AppManager.isUserLoggedIn {
					//Fetch All From Web
					
					WishLists.removeAllWishListData()
					if let customerId = UserDefaultManager.sharedManager().loginUserId {
						let url = URLBuilder.getAllWishLists()
						
						if let customerGroupId = UserDefaultManager.sharedManager().customerGroupId {
							let syncDataFormat = url + "&customer_id=\(customerId)&customer_group_id=\(customerGroupId)"
							SyncManager.syncOperation(operationType: .getAllWishLists, info: syncDataFormat, completionHandler: { (response, error) in
								
								if error == nil {
									DispatchQueue.main.async {
										
									}
									
									NotificationCenter.default.post(name: Notification.Name("WishListUpdateNotification"), object: nil)
								} else {
								}
							})
						}
					}
				}
			}
		} else {
			NotificationCenter.default.post(name: Notification.Name("WishListUpdateNotification"), object: nil)
		}
	}
	
	
	func addNotificationObserver() {
		NotificationCenter.default.addObserver(self, selector: #selector(ProductsHomeViewController.showTappedMenu), name: NSNotification.Name(rawValue: Constants.sliderMenuFieldTapNotification), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(ProductsHomeViewController.handleLoginSuccess), name: NSNotification.Name(rawValue: Constants.loginSuccessNotification), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(ProductsHomeViewController.signupSuccess), name: Notification.Name(Constants.signupSuccessNotification), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(ProductsHomeViewController.voiceSearchButtonTapped), name: Notification.Name("VoiceSearchButtonTapped"), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(ProductsHomeViewController.handleCartProductChanges), name: Notification.Name("MyCartUpdateNotification"), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(ProductsHomeViewController.handleMyWishlistChanges), name: Notification.Name("WishListUpdateNotification"), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(ProductsHomeViewController.handleMyWishlistAdd), name: Notification.Name("WishListAddNotification"), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(ProductsHomeViewController.handleCartAdd), name: Notification.Name("CartAddNotification"), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(ProductsHomeViewController.showProductDetailPage), name: Notification.Name("ShowProductNotification"), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(ProductsHomeViewController.downloadProductDetail), name: Notification.Name("ShowProductDetailsNotification"), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(ProductsHomeViewController.reloadUI), name: Notification.Name("APP_STATE_NOTIFICATION"), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(ProductsHomeViewController.reachabilityChanged(notification:)), name: Notification.Name("ReachabilityChangedNotification"), object: nil)
	}
	
	func titleImageView() {
		
	}
	
	func printDownloadedProducts() {
		let allProducts = ProductCategory.mr_findAll()
		print("All Downloaded Products are \(allProducts)")
	}
	
	func setupAutoScrollFunctionality() {
		guard self.imageScrollTimer == nil else { return }
		
		DispatchQueue.main.async {
			self.imageScrollTimer = Timer.scheduledTimer(timeInterval: 20.0, target: self, selector: #selector(ProductsHomeViewController.timerFired), userInfo: nil, repeats: true)
		}
	}
	
	@objc func timerFired() {
		NotificationCenter.default.post(name: Notification.Name(Constants.timerFiredNotification), object: nil)
	}
	
	func showSubCategories(ofParentId id:String, withCategory category: [String: AnyObject]? = nil) {
		if AppManager.currentApplicationMode() == .online {
			if let subCategoryVc = self.storyboard?.instantiateViewController(withIdentifier: "SubCategoriesViewController") as?  SubCategoriesViewController {
				subCategoryVc.parentId = id
				subCategoryVc.selectedCategory = category
				self.navigationController?.pushViewController(subCategoryVc, animated: true)
			}
		} else {
			let productListVc = self.storyboard?.instantiateViewController(withIdentifier: "ProductListViewController") as!  ProductListViewController
			productListVc.selectedSubCategory = id
			productListVc.fromScreenType = .home
			self.navigationController?.pushViewController(productListVc, animated: true)
		}
	}
	
	func showSearchResults(withText text: String? = "") {
		let searchResultsVc = self.storyboard?.instantiateViewController(withIdentifier: "SearchResultViewController") as? SearchResultViewController
		searchResultsVc?.searchDataText = text
		self.navigationController?.pushViewController(searchResultsVc!, animated: false)
		//        let searchResultController = UINavigationController(rootViewController: searchResultsVc!)
		//        self.present(searchResultController, animated: true, completion: nil)
	}
	
	func textFieldDidChange(textField: UITextField) {
		self.showSearchResults(withText: textField.text)
	}
	
	func handelRateApp(appId: String = "id1247525461", completion: @escaping ((_ success: Bool)->())) {
		guard let url = URL(string : "itms-apps://itunes.apple.com/app/" + appId) else {
			completion(false)
			return
		}
		guard #available(iOS 10, *) else {
			completion(UIApplication.shared.openURL(url))
			return
		}
		UIApplication.shared.open(url, options: [:], completionHandler: completion)
	}
	
	func shareAPP() {
		let subject_text = NSLocalizedString("SUBJECT_TEXT", comment: "")
		let app_share_content = NSLocalizedString("SHARE_APP_CONTENT", comment: "")
		let downloadApp_text = NSLocalizedString("DOWNLOAD_APP", comment: "")
		let app_download_link = NSLocalizedString("APP_DOWNLOAD_LINK", comment: "")
		let textToShare = [app_share_content, " ", downloadApp_text, " ", app_download_link] as [Any]
		let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
		activityViewController.setValue(subject_text, forKey: "Subject")
		activityViewController.popoverPresentationController?.sourceView = self.view
		
		self.present(activityViewController, animated: true, completion: nil)
	}
}

//MARK:- UITableViewDataSource
extension ProductsHomeViewController: UITableViewDataSource {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		if AppManager.currentApplicationMode() == .online {
			let size=self.sectionTitleInfo.count+4
			return size
		} else {
			if let sectionCount = Sections.mr_findAll()?.count {
				return sectionCount + 4
			} else {
				return 0
			}
		}
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section == 0 {
			let cell = tableView.dequeueReusableCell(withIdentifier: "ImageScrollTableViewCell", for: indexPath) as? ImageScrollTableViewCell
			cell?.bannerData = self.bannerData
			cell?.reloadUIData()
			cell?.cellTappedCallback = { (success, id,menuType,brandName) in
				if success {
					let product = Product.getProductWith(productId: id)
					print("product details--:\(product)")
					
					if AppManager.currentApplicationMode() == .offline
					{
						if let productName = product?.productName, let desc = product?.productDescription, let _ = product?.model, let price = product?.price, let image = product?.image {
							if let productVc = self.storyboard?.instantiateViewController(withIdentifier: ProductDetailViewController.selfName()) as? ProductDetailViewController {
								productVc.currentProduct = ProductData(withName: (product?.productName!)!, withProductId: (product?.productId!)!, andDescription: (product?.productDescription!)!, (product?.model!)!, (product?.price.description)!, prodImage: (product?.image!)!, (product?.isInCart)!, (product?.isProductLiked)!, availability: (product?.availability.description)!, "","")
								
								self.navigationController?.pushViewController(productVc, animated: true)
							}
						} else {
							if let subCategories = SubCategories.getSubCategoriesBy(parentId: id) {
								if subCategories.count != 0 {
									self.showSubCategories(ofParentId: id)
								}
							}
						}
					}
					else{
						if(menuType=="product")
						{
							
							self.myGroup.enter()
							
							self.downloadProductBasedOnId(productId: id)
							
							
							self.myGroup.notify(queue: DispatchQueue.main) {
								var singleProduct=[String: AnyObject]()
								
								singleProduct=self.productInfo[0]
								
								
								let productDetailVc = self.storyboard?.instantiateViewController(withIdentifier: "ProductDetailViewController") as!  ProductDetailViewController
								
								productDetailVc.currentProductInfo =  singleProduct
								productDetailVc.fromScreenType = .banner
								self.navigationController?.pushViewController(productDetailVc, animated: true)
								
							}
						}
						else if(menuType=="category")
						{
							
							/* self.myGroup.enter()
							
							self.downloadProductFromBrandName(category_id: id, brandName: brandName)
							self.myGroup.notify(queue: DispatchQueue.main) {
							//print("===category==\(self.categoryInfo)")
							
							var finalCatList=[[String:AnyObject]]()
							
							for newcat in self.categoryInfo
							{
							var singleCat=[String:AnyObject]()
							
							let name=newcat["name"]
							let description=newcat["description"]
							singleCat=newcat
							singleCat["arName"]=name
							singleCat["arDescription"]=description
							
							
							finalCatList.append(singleCat)
							
							}
							
							//print("===finalCatList==\(finalCatList)") */
							
							let productListVc = self.storyboard?.instantiateViewController(withIdentifier: "ProductListViewController") as!  ProductListViewController
							//productListVc.productsListInfo=finalCatList
							productListVc.subCategory=false
							productListVc.bannerBrandName = brandName
							productListVc.bannerBrandId = id
							productListVc.fromScreenType = .banner
							self.navigationController?.pushViewController(productListVc, animated: true)
						}
					}
					//}
				}
			}
			cell?.selectionStyle = .none
			return cell!
			
		} else if indexPath.section == 1 {
			
			let cell = tableView.dequeueReusableCell(withIdentifier: "OffersListTableViewCell", for: indexPath) as? OffersListTableViewCell
			cell?.selectionStyle = .none
			cell?.reloadUI()
			cell?.cellTapHandler = {(success, id,menuType,brandName) in
				if success {
					
					/* if let subCategories = SubCategories.getSubCategoriesBy(parentId: id) {
					if subCategories.count != 0 {
					self.showSubCategories(ofParentId: id)
					
					}
					
					}*/
					
					if(menuType=="product")
					{
						self.showIndicator()
						print("===product==")
						self.myGroup.enter()
						
						self.downloadProductBasedOnId(productId: id)
						
						
						self.myGroup.notify(queue: DispatchQueue.main) {
							var singleProduct=[String: AnyObject]()
							
							singleProduct=self.productInfo[0]
							
							
							let productDetailVc = self.storyboard?.instantiateViewController(withIdentifier: "ProductDetailViewController") as!  ProductDetailViewController
							
							productDetailVc.currentProductInfo =  singleProduct
							productDetailVc.fromScreenType = .offers
							self.navigationController?.pushViewController(productDetailVc, animated: true)
							self.removeIndicator()
							
						}
					}
					else if(menuType=="category")
					{
						/* self.showIndicator()
						print("===category==")
						self.myGroup.enter()
						
						self.downloadOfferZoneProduct(category_id: id)
						
						self.myGroup.notify(queue: DispatchQueue.main) {
						print("===category==\(self.offerZoneInfo)") */
						
						
						
						let productListVc = self.storyboard?.instantiateViewController(withIdentifier: "ProductListViewController") as!  ProductListViewController
						//productListVc.productsListInfo=self.offerZoneInfo
						productListVc.offerBrandId = id
						productListVc.fromScreenType = .offers
						productListVc.subCategory=false
						self.navigationController?.pushViewController(productListVc, animated: true)
						//self.removeIndicator()
						//}
					}
					
				}
			}
			return cell!
			
		} else if indexPath.section == 2 {
			
			if(self.categoriesInfo.count>0)
			{
				print("Categories Response: \(self.categoriesInfo)")
			}
			else{
				if AppManager.currentApplicationMode() == .online {
					self.productsTableView.reloadData()
				}
			}
			let cell = tableView.dequeueReusableCell(withIdentifier: "BrowseByCategoryTableViewCell", for: indexPath) as? BrowseByCategoryTableViewCell
			if AppManager.currentApplicationMode() == .online {
				cell?.setDataSource(withData: self.categoriesInfo)
				cell?.reloadUI()
			} else {
				if let allCategories = ProductCategory.getAllProducts() {
					cell?.productCategories = allCategories
					cell?.reloadUI()
				}
			}
			
			cell?.cellTapCallback = { (success, id, category) in
				if success {
					self.showSubCategories(ofParentId: id, withCategory: category)
				}
			}
			cell?.selectionStyle = .none
			
			return cell!
		}
			
		else if indexPath.section == 3 {
			let cell = tableView.dequeueReusableCell(withIdentifier: "OurBrandsTableViewCell", for: indexPath) as? OurBrandsTableViewCell
			cell?.selectionStyle = .none
			if AppManager.currentApplicationMode() == .online {
				cell?.brandsListInfo = self.brandsListInfo
			} else {
				cell?.updateFetchRequest()
			}
			cell?.reloadUI()
			cell?.cellTappedHandler = { (success, id, name, image) in
				if success {
					
					if AppManager.currentApplicationMode() == .online {
						let brandvc = self.storyboard?.instantiateViewController(withIdentifier: "BrandViewController") as?  BrandsViewController
						brandvc?.selectedBrandId = id
						brandvc?.selectedBrandName = name
						brandvc?.selectedBrandImage = image
						self.navigationController?.pushViewController(brandvc!, animated: true)
					} else {
						if let productListVc = self.storyboard?.instantiateViewController(withIdentifier: "ProductListViewController") as? ProductListViewController {
							productListVc.selectedSubCategory = id
							productListVc.fromScreenType = .brands
							self.navigationController?.pushViewController(productListVc, animated: true)
						}
					}
				}
			}
			return cell!
			
		}
		else if indexPath.section == 224 {
			let cell = tableView.dequeueReusableCell(withIdentifier: "NewArrivalsTableViewCell", for: indexPath) as? NewArrivalsTableViewCell
			cell?.setDataSource(withData: self.newArrivalsInfo)
			cell?.reloadUI()
			cell?.delegate = self
			cell?.selectionStyle = .none
			cell?.cellTappedHandler = { (success, newArrivalProd, productData, productInfo) in
				if success {
					let productDetailVc = self.storyboard?.instantiateViewController(withIdentifier: "ProductDetailViewController") as!  ProductDetailViewController
					if AppManager.currentApplicationMode() == .offline {
						var productData: ProductData?
						
						if AppManager.languageType() == .english {
							if let newArrivalProd = newArrivalProd {
								/* productData = ProductData(withName: newArrivalProd.productName ?? "", withProductId: newArrivalProd.productId!, andDescription: newArrivalProd.productDescription!, newArrivalProd.model ?? "", (newArrivalProd.price), prodImage: (newArrivalProd.image!), newArrivalProd.isInCart, newArrivalProd.isProductLiked, specialPrice: newArrivalProd.specialPrice ?? "", availability: (newArrivalProd.availability.description), newArrivalProd.arName!,  newArrivalProd.arDescription!) */
							}
						} else {
							if let newArrivalProd = newArrivalProd {
								/* productData = ProductData(withName: newArrivalProd.arName ?? "", withProductId: newArrivalProd.productId!, andDescription: newArrivalProd.arDescription!, newArrivalProd.model ?? "", newArrivalProd.price, prodImage: newArrivalProd.image!, newArrivalProd.isInCart, newArrivalProd.isProductLiked, specialPrice: newArrivalProd.specialPrice ?? "", availability: newArrivalProd.availability.description, newArrivalProd.arName!, newArrivalProd.arDescription!) */
							}
							productDetailVc.currentProduct = productData
						}
						self.navigationController?.pushViewController(productDetailVc, animated: true)
					} else {
						productDetailVc.currentProduct = productData
						productDetailVc.currentProductInfo = productInfo!
						self.navigationController?.pushViewController(productDetailVc, animated: true)
					}
				}
			}
			//            cell?.delegate = self
			return cell!
			
		} else if indexPath.section == 215 {
			let cell = tableView.dequeueReusableCell(withIdentifier: "MostCellingTableViewCell", for: indexPath) as? MostCellingTableViewCell
			cell?.selectionStyle = .none
			cell?.delegate = self
			cell?.setDataSource(withData: self.topSelllingInfo)
			cell?.reloadUI()
			cell?.cellTappedHandler = { (success, topSellingProduct, productInfoData, productInfo) in
				if success {
					
					let productDetailVc = self.storyboard?.instantiateViewController(withIdentifier: "ProductDetailViewController") as!  ProductDetailViewController
					
					if AppManager.currentApplicationMode() == .offline {
						var productData: ProductData?
						if AppManager.languageType() == .english {
							/* if let productInfoData = topSellingProduct {
								productData = ProductData(withName: productInfoData.name ?? "", withProductId: (productInfoData.productid)!, andDescription: (productInfoData.desc)!, productInfoData.productCode ?? "", (0.0), prodImage: (productInfoData.productImage!), (productInfoData.isInCart), (productInfoData.isProductLiked), specialPrice: productInfoData.specialPrice ?? "", availability: productInfoData.availability.description, productInfoData.arName!, productInfoData.arDescription!)
								productDetailVc.currentProduct = productData
								self.navigationController?.pushViewController(productDetailVc, animated: true)
							} */
						} else {
							if let productInfoData = topSellingProduct {
								productData = ProductData(withName: productInfoData.arName ?? "", withProductId: (productInfoData.productid)!, andDescription: productInfoData.arDescription ?? "", productInfoData.productCode ?? "", ("price"), prodImage: (productInfoData.productImage!), (productInfoData.isInCart), (productInfoData.isProductLiked), specialPrice: productInfoData.specialPrice ?? "", availability: productInfoData.availability.description, productInfoData.arName!, productInfoData.arDescription!)
								
								productDetailVc.currentProduct = productData
								self.navigationController?.pushViewController(productDetailVc, animated: true)
							}
						}
					} else {
						productDetailVc.currentProduct = productInfoData
						productDetailVc.currentProductInfo = productInfo!
						self.navigationController?.pushViewController(productDetailVc, animated: true)
					}
				}
			}
			return cell!
		} else {
			let section_index=indexPath.section-4
			
			var product=[[String: AnyObject]]()
			product=self.downloadProducts(indexValue: section_index)
			
			let cell = tableView.dequeueReusableCell(withIdentifier: "NewArrivalsTableViewCell", for: indexPath) as? NewArrivalsTableViewCell
			//MARK:- Fixme
			if AppManager.currentApplicationMode() == .offline {
			 let sectionData = Sections.getAllSectionsList()
				var sectionProductsData = [Product]()
				if let sectionProducts = sectionData?[section_index].products?.allObjects as? [Product] {
					for product in sectionProducts {
						if product.productId != "0" {
							sectionProductsData.append(product)
						}
					}
					cell?.productDataSource = sectionProductsData
				}
			} else {
				cell?.setDataSource(withData: product)
			}
			cell?.reloadUI()
			cell?.delegate = self
			cell?.selectionStyle = .none
			cell?.cellTappedHandler = { (success, newArrivalProd, productData, productInfo) in
				if success {
					let productDetailVc = self.storyboard?.instantiateViewController(withIdentifier: "ProductDetailViewController") as!  ProductDetailViewController
					if AppManager.currentApplicationMode() == .offline {
						
						if let newArrivalProd = newArrivalProd {
							productDetailVc.currentProdId = newArrivalProd
						}
						self.navigationController?.pushViewController(productDetailVc, animated: true)
					} else {
						productDetailVc.currentProduct = productData
						productDetailVc.currentProductInfo = productInfo!
						self.navigationController?.pushViewController(productDetailVc, animated: true)
					}
				}
			}
			
			return cell!
		}
	}
}

//MARK:- UITableViewDelegates
extension ProductsHomeViewController: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		
		let sectionHeaderView = tableView.dequeueReusableHeaderFooterView(withIdentifier: HomeSectionHeader.selfName()) as? HomeSectionHeader
		sectionHeaderView?.contentView.backgroundColor = UIColor(rgba: "EBEBF1")
		
		
		if(section==1)
		{
			print("section----:\(section)")
			sectionHeaderView?.sectionHeaderName.text = ""
		}
		else if(section==2)
		{
			
			sectionHeaderView?.sectionHeaderName.text = NSLocalizedString("Book By Categories", comment: "")
		}
		else if (section==3)
		{
			
			sectionHeaderView?.sectionHeaderName.text = NSLocalizedString("Our Brands", comment: "")
			
		}
		else
		{
			if(section>3)
			{
				if AppManager.currentApplicationMode() == .online {
					let titleName=self.sectionTitleInfo[section-4]
					
					sectionHeaderView?.sectionHeaderName.text = NSLocalizedString(titleName, comment: "")
				} else {
					let sectionData = Sections.getAllSectionsList()
					if let section = sectionData?[section - 4] {
						if let sectionName = section.sectionName {
							sectionHeaderView?.sectionHeaderName.text = sectionName
						}
					}
				}
			}
		}
		if UIDevice.current.userInterfaceIdiom == .pad {
			sectionHeaderView?.sectionHeaderName.font = UIFont.boldSystemFont(ofSize: 28.0)
		} else {
			sectionHeaderView?.sectionHeaderName.font = UIFont.boldSystemFont(ofSize: 14.0)
		}
		
		return sectionHeaderView
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if (section == 0) {
			return 0.0
		} else if (section == 1) {
			if UIDevice.current.userInterfaceIdiom == .pad {
				return 25.0
			} else {
				return 15.0
			}
		} else {
			if UIDevice.current.userInterfaceIdiom == .pad {
				return 75.0
			} else {
				return 30.0
			}
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if ((indexPath.section == 4) || (indexPath.section == 5)) {
			if UIDevice.current.userInterfaceIdiom == .pad {
				return 320.0
			} else {
				return 210.0
			}
		} else if (indexPath.section == 3) {
			
			if UIDevice.current.userInterfaceIdiom == .pad {
				return 100.0
			} else {
				return 60.0
			}
		} else if (indexPath.section == 0) {
			
			if UIDevice.current.userInterfaceIdiom == .pad {
				return 300.0
			} else {
				return 150.0
			}
		} else if (indexPath.section == 1) {
			if UIDevice.current.userInterfaceIdiom == .pad {
				return 140.0
			} else {
				return 80.0
			}
		} else if (indexPath.section == 2) {
			if UIDevice.current.userInterfaceIdiom == .pad {
				return 375.0
			} else {
				return 200.0
			}
		} else {
			if UIDevice.current.userInterfaceIdiom == .pad {
				return 320.0
			} else {
				return 210.0
			}
		}
	}
}

//MARK:- CellTapHandlerProtocolDelegate
extension ProductsHomeViewController: CellTapHandlerProtocol {
	
	func collectionCellTapped(at indexPath: IndexPath, ofCell cell: UITableViewCell) {
		
		if let subCategoryVc = self.storyboard?.instantiateViewController(withIdentifier: "SubCategoriesViewController") as?  SubCategoriesViewController {
			self.navigationController?.pushViewController(subCategoryVc, animated: true)
		}
	}
}

//MARK:- SFSpeechRecognizerDelegate
extension ProductsHomeViewController: SFSpeechRecognizerDelegate {
	
	func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
		if available {
			//self.voiceButton.isEnabled = true
			self.searchTextField.searchByVoiceButton?.isEnabled = true
		} else {
			//self.voiceButton.isEnabled = false
			self.searchTextField.searchByVoiceButton?.isEnabled = false
		}
	}
}

//MARK:- UIImagePickerControllerDelegate
extension ProductsHomeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		let _ = info[UIImagePickerControllerOriginalImage] as! UIImage
		dismiss(animated:true, completion: nil)
	}
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		dismiss(animated:true, completion: nil)
	}
}

//MARK:- UITextFieldDelegate:
extension ProductsHomeViewController: UITextFieldDelegate {
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		self.showSearchResults()
		textField.resignFirstResponder()
	}
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		self.showSearchResults()
		return true
	}
}

extension ProductsHomeViewController {
	
	func showTappedMenu(notification: Notification) {
		let _ = self.navigationController?.popToRootViewController(animated: true)
		if let notificationObject = notification.userInfo {
			if AppManager.isUserLoggedIn {
				if AppManager.getLoggedInUserType() == .salesExecutive {
					if let storyBoardId = notificationObject[Constants.keyLogin] as? SalesRepMenu {
						switch storyBoardId {
						case .LogoutUser:
							let alertController = UIAlertController(title: NSLocalizedString("Alzahrani", comment: ""), message: NSLocalizedString("LOGOUT_CONFIRMATION_POPUP", comment: ""), preferredStyle: .alert)
							let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .destructive, handler: { (UIAlertAction) in
								UserDefaultManager.sharedManager().isAuthenticated = false
								AppManager.logoutUser()
								self.initialDownload()
								self.productsTableView.reloadData()
								NotificationCenter.default.post(name: Notification.Name(Constants.userLoggedOutNotification), object: nil)
							})
							let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: nil)
							alertController.addAction(okAction)
							alertController.addAction(cancelAction)
							self.present(alertController, animated: true, completion: nil)
							
						case .MyAccount:
							if let myAccountVc = self.storyboard?.instantiateViewController(withIdentifier: "MyAccountsViewController") as? MyAccountsViewController {
								self.navigationController?.pushViewController(myAccountVc, animated: true)
							}
						case .OrderHistory:
							if let myAccountVc = self.storyboard?.instantiateViewController(withIdentifier: OrderHistoryTableViewController.selfName()) as? OrderHistoryTableViewController {
								self.navigationController?.pushViewController(myAccountVc, animated: true)
							}
						case .MyWishList:
							if let WishListVc = self.storyboard?.instantiateViewController(withIdentifier: MyWishlistViewController.selfName()) as? MyWishlistViewController {
								self.navigationController?.pushViewController(WishListVc, animated: true)
							}
						case .CustomerService:
							if let contactUsVc = self.storyboard?.instantiateViewController(withIdentifier: ContactNewViewController.selfName()) as? ContactNewViewController{
								self.navigationController?.pushViewController(contactUsVc, animated: true)
							}
						case .RateUs:
							self.handelRateApp(completion: { (success) in
								print("Successfully rated the App")
							})
							
						case .ShareApp:
							self.shareAPP()
							
						case .Settings:
							SyncManager.sharedSyncQueueManager.cancelAllQueues()
							if let settingsVc = self.storyboard?.instantiateViewController(withIdentifier: "SettingsViewController") as? SettingsViewController {
								self.navigationController?.pushViewController(settingsVc, animated: true)
							}
							
						default:
							break
						}
					}
				} else {
					if let storyBoardId = notificationObject[Constants.keyLogin] as? LoggedInUser {
						switch storyBoardId {
						case .LogoutUser:
							let alertController = UIAlertController(title: NSLocalizedString("Alzahrani", comment: ""), message: NSLocalizedString("LOGOUT_CONFIRMATION_POPUP", comment: ""), preferredStyle: .alert)
							let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .destructive, handler: { (UIAlertAction) in
								UserDefaultManager.sharedManager().isAuthenticated = false
								AppManager.logoutUser()
								self.initialDownload()
								self.productsTableView.reloadData()
								NotificationCenter.default.post(name: Notification.Name(Constants.userLoggedOutNotification), object: nil)
							})
							let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: nil)
							alertController.addAction(okAction)
							alertController.addAction(cancelAction)
							self.present(alertController, animated: true, completion: nil)
						case .MyAccount:
							if let myAccountVc = self.storyboard?.instantiateViewController(withIdentifier: "MyAccountsViewController") as? MyAccountsViewController {
								self.navigationController?.pushViewController(myAccountVc, animated: true)
							}
						case .OrderHistory:
							if let myAccountVc = self.storyboard?.instantiateViewController(withIdentifier: OrderHistoryTableViewController.selfName()) as? OrderHistoryTableViewController {
								self.navigationController?.pushViewController(myAccountVc, animated: true)
							}
						case .MyWishList:
							if let WishListVc = self.storyboard?.instantiateViewController(withIdentifier: MyWishlistViewController.selfName()) as? MyWishlistViewController {
								self.navigationController?.pushViewController(WishListVc, animated: true)
							}
						case .CustomerService:
							if let contactUsVc = self.storyboard?.instantiateViewController(withIdentifier: ContactNewViewController.selfName()) as? ContactNewViewController{
								self.navigationController?.pushViewController(contactUsVc, animated: true)
							}
						case .RateUs:
							self.handelRateApp(completion: { (success) in
								print("Successfully rated the App")
							})
							
						case .ShareApp:
							self.shareAPP()
						default:
							break
						}
					}
				}
			} else {
				if let storyBoardId = notificationObject[Constants.keyLogin] as? NewUser {
					switch storyBoardId {
					case .Login:
						let loginVc = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
						let menuNavController = UINavigationController(rootViewController: loginVc!)
						self.present(menuNavController, animated:true, completion: nil)
						
					case .Register:
						let registerVc = self.storyboard?.instantiateViewController(withIdentifier: "RegistrationViewController") as? RegistrationViewController
						registerVc?.screenType = .home
						let menuNavController = UINavigationController(rootViewController: registerVc!)
						self.present(menuNavController, animated:true, completion: nil)
					case .RateUs:
						self.handelRateApp(completion: { (success) in
							print("Successfully rated the App")
						})
						
					case .ShareApp:
						self.shareAPP()
					default:
						break
					}
				}
			}
		}
	}
	
	func handleLoginSuccess() {
		let _ = self.navigationController?.popToRootViewController(animated: true)
	}
	
	func signupSuccess() {
		let loginVc = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
		let menuNavController = UINavigationController(rootViewController: loginVc!)
		self.present(menuNavController, animated:true, completion: nil)
	}
	
	func voiceSearchButtonTapped() {
		
		self.showSearchResults()
		
		/* self.navigationController?.tabBarController?.tabBar.isHidden = true
		if let searchVoiceVc = self.storyboard?.instantiateViewController(withIdentifier: VoiceSearchWindowViewController.selfName()) as? VoiceSearchWindowViewController {
		searchVoiceVc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
		searchVoiceVc.delegate = self
		self.present(searchVoiceVc, animated: true, completion: nil)
		} */
		
		/* if audioEngine.isRunning {
		audioEngine.stop()
		recognitionRequest?.endAudio()
		} else {
		startRecording()
		} */
	}
	
	func handleCartProductChanges() {
		
		let cartCount = MyCart.getAllMyCartlist()
		if cartCount?.count == 0 {
			self.tabBarController?.tabBar.items?[3].badgeValue = nil
		} else {
			self.tabBarController?.tabBar.items?[3].badgeValue = cartCount?.count.description
		}
	}
	
	func removeNavigationBarImage() {
		self.navigationController?.navigationBar.setBackgroundImage(nil, for: .top, barMetrics: .default)
	}
	
	func handleMyWishlistChanges() {
		let wishListCount = WishLists.getAllWishlists()
		if wishListCount?.count == 0 {
			self.tabBarController?.tabBar.items?[1].badgeValue = nil
		} else {
			self.tabBarController?.tabBar.items?[1].badgeValue = wishListCount?.count.description
		}
	}
	
	func handleMyWishlistAdd() {
		self.handleMyWishlistChanges()
	}
	
	func handleCartAdd() {
		self.handleCartProductChanges()
	}
	
	func showIndicator() {
		ProgressIndicatorController.showLoading()
	}
	
	func removeIndicator() {
		ProgressIndicatorController.dismissProgressView()
	}
	
	func showProductDetailPage(notification: Notification) {
		if let userInfo = notification.object as? [String: AnyObject] {
			if let productData = userInfo["productData"] as? ProductData {
				if let productVc = self.storyboard?.instantiateViewController(withIdentifier: ProductDetailViewController.selfName()) as? ProductDetailViewController {
					productVc.currentProduct = productData
					
					self.navigationController?.pushViewController(productVc, animated: true)
				}
			}
		}
	}
	
	func downloadProductDetail(notification: Notification) {
		if let userInfo = notification.object as? [String: AnyObject] {
			if let productId = userInfo["product_id"] as? String {
				var custGrpId: String = ""
				
				if let customerGrpId = UserDefaultManager.sharedManager().customerGroupId {
					custGrpId = customerGrpId
				}
				let syncFormat = "&product_id=\(productId)&customer_group_id=\(custGrpId)"
				SyncManager.syncOperation(operationType: .getProductDetail, info: syncFormat) { (response, error) in
					if error == nil {
						if let response = response as? [[String: AnyObject]] {
							if let productInfo = response.first {
								
								if let productVc = self.storyboard?.instantiateViewController(withIdentifier: ProductDetailViewController.selfName()) as? ProductDetailViewController {
									productVc.currentProductInfo = productInfo
									self.navigationController?.pushViewController(productVc, animated: true)
								}
							}
						}
					}
				}
			}
		}
	}
	
	func reloadUI(notification: Notification) {
		if let object = notification.object as? [String: AnyObject] {
			if let appState = object["App_State"] as? AppMode {
				if appState == .online {
					self.initialDownload()
					self.productsTableView.reloadData()
				} else {
					self.productsTableView.reloadData()
				}
			}
		}
	}
	
	
	func reachabilityChanged(notification: Notification) {
		if AppManager.getLoggedInUserType() == .salesExecutive {
			if let networkReachability = notification.object as? Reachability {
				if networkReachability.isReachable() {
					print("Network is Reachable")
					let title = NSLocalizedString("Alzahrani", comment: "")
					let online_message = NSLocalizedString("SWITCH_ONLINE_MESSAGE", comment: "")
					
					let alertController = UIAlertController(title: title, message: online_message, preferredStyle: .alert)
					
					let okAction = UIAlertAction(title: Constants.alertAction, style: .default, handler: { (UIAlertAction) in
						if AppManager.getLoggedInUserType() == .salesExecutive {
							UploadTaskHandler.sharedInstance.placeOfflineOrders()
							UserDefaultManager.sharedManager().currentAppMode = "Online"
							self.initialDownload()
							self.productsTableView.reloadData()
						}
					})
					
					let cancelAction = UIAlertAction(title: Constants.cancelAction, style: .default, handler: nil)
					
					alertController.addAction(okAction)
					alertController.addAction(cancelAction)
					
					self.present(alertController, animated: true, completion: nil)
				} else {
					let title = NSLocalizedString("Alzahrani", comment: "")
					let offline_message = NSLocalizedString("SWITCH_OFFLINE_MESSAGE", comment: "")
					
					if AppManager.isUserLoggedIn {
						let alertController = UIAlertController(title: title, message: offline_message, preferredStyle: .alert)
						
						let okAction = UIAlertAction(title: Constants.alertAction, style: .default, handler: { (UIAlertAction) in
							if AppManager.getLoggedInUserType() == .salesExecutive {
								if AppManager.isProductsDownloaded {
									UserDefaultManager.sharedManager().currentAppMode = "Offline"
									self.productsTableView.reloadData()
								} else {
									ALAlerts.showToast(message: NSLocalizedString("DOWNLOAD_TO_ENABLE", comment: ""))
								}
							}
						})
						
						let cancelAction = UIAlertAction(title: Constants.cancelAction, style: .default, handler: nil)
						
						alertController.addAction(okAction)
						alertController.addAction(cancelAction)
						
						self.present(alertController, animated: true, completion: nil)
					}
				}
			}
		}
	}
}


extension ProductsHomeViewController: UISearchResultsUpdating {
	
	func updateSearchResults(for searchController: UISearchController) {
		
	}
}

//MARK:- CellButtonActionsDelegate
extension ProductsHomeViewController: CellButtonActionsDelegate {
	
	func didTapShareButton(withProduInfo info: Product?, withOnlineProduct onlineProd: [String: AnyObject]?) {
		
		if AppManager.currentApplicationMode() == .online {
			var produURL = ""
			let imageURL = onlineProd?["image"]
			let productName = onlineProd?["name"]
			let description = onlineProd?["description"]
			var productImageData: UIImage?
			let text = "Checkout what I found on Alzahrani"
			if let productId = onlineProd?["product_id"] as? String {
				let url = "https://alzahrani-online.com/index.php?route=product/product&product_id=\(productId)"
				produURL = url
			}
			let prorperURL = imageURL?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
			SyncManager.syncOperation(operationType: .imageDownloadOperation, info: prorperURL,
			                          completionHandler: { (imageData, error) in
												if error == nil {
													DispatchQueue.main.async {
														productImageData = UIImage(data: imageData as! Data)!
														// set up activity view controller
														let textToShare = [text, productName ?? "", description ?? "", productImageData ?? UIImage(), " ", produURL] as [Any]
														let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
														activityViewController.popoverPresentationController?.sourceView = self.view
														
														self.present(activityViewController, animated: true, completion: nil)
														
														activityViewController.completionWithItemsHandler = {(activityType: UIActivityType?, completed: Bool, returnedItems:[Any]?, error: Error?) in
															
															print("Selected Activity is \(activityType)")
														}
													}
												}
			})
		} else {
			
			var produURL = ""
			let text = "Checkout what I found on Alzahrani"
			if let productId = info?.productId {
				let url = "https://alzahrani-online.com/index.php?route=product/product&product_id=\(productId)"
				produURL = url
			}
			if let productName = info?.productName, let productDescription = info?.productDescription {
				let productImage = UIImage(data: (info?.imageData)! as Data)
				
				// set up activity view controller
				let textToShare = [text, produURL, productName, productDescription, productImage ?? UIImage()] as [Any]
				let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
				activityViewController.popoverPresentationController?.sourceView = self.view
				
				self.present(activityViewController, animated: true, completion: nil)
			}
		}
	}
	
	func didTapCartProductButton() {
		if AppManager.isUserLoggedIn == false {
			let loginAlert = NSLocalizedString("LOGIN_ALERT_PROMPT", comment: "")
			self.showAlertWith(warningMsg: loginAlert)
		} else {
			let cartCount = MyCart.getAllMyCartlist()
			if cartCount?.count == 0 {
				self.tabBarController?.tabBar.items?[3].badgeValue = ""
			} else {
				self.tabBarController?.tabBar.items?[3].badgeValue = cartCount?.count.description
			}
		}
	}
}

extension ProductsHomeViewController: TSCellButtonActionsDelegate {
	
	func didTapTSShareButton(withProduInfo info: TopSelling?, withOnlineProduct onlineProd: [String: AnyObject]?) {
		
		if AppManager.currentApplicationMode() == .online {
			
			let imageURL = onlineProd?["image"]
			let productName = onlineProd?["name"]
			let description = onlineProd?["description"]
			var productImageData: UIImage?
			let prorperURL = imageURL?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
			SyncManager.syncOperation(operationType: .imageDownloadOperation, info: prorperURL,
			                          completionHandler: { (imageData, error) in
												if error == nil {
													DispatchQueue.main.async {
														productImageData = UIImage(data: imageData as! Data)!
														// set up activity view controller
														let textToShare = [productName as? String ?? "", description as? String ?? "", productImageData ?? UIImage()] as [Any]
														let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
														activityViewController.popoverPresentationController?.sourceView = self.view
														
														self.present(activityViewController, animated: true, completion: nil)
													}
												}
			})
		} else {
			
			var productImageData: UIImage?
			if let productName = info?.name, let productDescription = info?.desc, let productImage = info?.productImage {
				let prorperURL = productImage.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
				SyncManager.syncOperation(operationType: .imageDownloadOperation, info: prorperURL,
				                          completionHandler: { (imageData, error) in
													if error == nil {
														DispatchQueue.main.async {
															productImageData = UIImage(data: imageData as! Data)!
															// set up activity view controller
															let textToShare = [productName, productDescription, productImageData ?? UIImage()] as [Any]
															let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
															activityViewController.popoverPresentationController?.sourceView = self.view
															
															self.present(activityViewController, animated: true, completion: nil)
														}
													}
				})
			}
		}
	}
	
	func didTapTSCartProductButton() {
		if AppManager.isUserLoggedIn == false {
			self.showAlertWith(warningMsg: "Please Login to Continue")
		} else {
			let cartCount = MyCart.getAllMyCartlist()
			if cartCount?.count == 0 {
				self.tabBarController?.tabBar.items?[3].badgeValue = ""
			} else {
				self.tabBarController?.tabBar.items?[3].badgeValue = cartCount?.count.description
			}
		}
	}
}


extension ProductsHomeViewController {
	func downloadProducts(indexValue:Int)->([[String:AnyObject]])
	{
		var allproductList = [[String: AnyObject]]()
		var productList=[[String: AnyObject]]()
		
		if(self.productListInfo.count>0)
		{
			
			
			
			let productList=self.productListInfo[indexValue]
			
			let product1=productList["products"] as AnyObject
			
			
			if (product1.isEqual(""))
			{
				print("Prime Focus val: \(product1)")
			}
			else
			{
				if let productsList = productList["products"] as? [[String : AnyObject]] {
					allproductList = productsList
				}
			}
		}
		if(allproductList.count>0)
		{
			
			for product in allproductList
			{
				let productId=product["product_id"] as? Bool
				if(productId==false)
				{
					print("product id is false")
				}
				else
				{
					productList.append(product)
				}
			}
		}
		return productList;
		
	}
	
	
	func downloadProductBasedOnId(productId:String)
	{
		
		let pId=Int(productId)
		
		
		if NetworkManager.sharedReachability.isReachable() {
			if AppManager.isUserLoggedIn {
				//Fetch All From Web
				
				let userDefaults = UserDefaultManager.sharedManager()
				
				if  let customerGroupId = userDefaults.customerGroupId {
					let syncDataFormat = "&product_id=\(pId!)&customer_group_id=\(customerGroupId)"
					
					SyncManager.syncOperation(operationType: .getProductData, info: syncDataFormat, completionHandler: { (response, error) in
						if error == nil {
							self.productInfo = []
							if let responseData = response as? [[String: AnyObject]] {
								
								for product in responseData {
									if let productId = product["product_id"] as? Bool {
										if productId == false {
											print("Invalid Product")
										}
									} else {
										self.productInfo.append(product)
									}
								}
								
								DispatchQueue.main.async {
									self.myGroup.leave()
									
								}
							}
						}
						else
						{
							print("Response error: \(error)")
						}
					})
				}
			}
		}
		
		
		
	}
	func downloadProductFromBrandName(category_id:String,brandName:String)
	{
		
		let catId=Int(category_id)
		if NetworkManager.sharedReachability.isReachable() {
			if AppManager.isUserLoggedIn {
				//Fetch All From Web
				
				let userDefaults = UserDefaultManager.sharedManager()
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
				if let customerGroupId = userDefaults.customerGroupId, let languageId = languageId {
					let syncDataFormat = "&manufacture_name=\(brandName)&category_id=\(catId!)&customer_group_id=\(customerGroupId)&language_id=\(languageId)"
					
					SyncManager.syncOperation(operationType: .getProductsFromBrandNameData, info: syncDataFormat, completionHandler: { (response, error) in
						if error == nil {
							//print("new Response response: \(response)")
							if let responseData = response as? [[String: AnyObject]] {
								DispatchQueue.main.async {
									// print("new Response response1: \(responseData)")
									self.categoryInfo = responseData
									
									
									self.myGroup.leave()
									
								}
							}
						}
						else
						{
							print("Response error: \(error)")
						}
					})
				}
			}
		}
	}
	
	func downloadOfferZoneProduct(category_id:String) {
		let catId=Int(category_id)
		let userDefaults = UserDefaultManager.sharedManager()
		if let customerGroupId = userDefaults.customerGroupId {
			let syncDataFormat = "&category_id=\(catId!)&customer_group_id=\(customerGroupId)&availability=1"
			
			SyncManager.syncOperation(operationType: .getAllProducts, info: syncDataFormat) { (response, error) in
				if error == nil {
					self.offerZoneInfo = []
					print("Response response: \(response)")
					if let responseData = response as? [[String: AnyObject]] {
						
						for product in responseData {
							if let productId = product["product_id"] as? Bool {
								if productId == false {
									print("Invalid Product")
								}
							} else {
								self.offerZoneInfo.append(product)
							}
						}
						
						DispatchQueue.main.async {
							
							self.myGroup.leave()
							print("Response return")
							
						}
					}
				} else {
					print("Response error: \(error)")
				}
			}
		}
	}
	
	func downloadAllCategories(withSuccesshandler successHandler: DownloadCompletion? = nil) {
		print("downloadAllCategories Response2:")
		let appLanguageId = (AppManager.languageType() == .english) ? "1" : "2"
		ProgressIndicatorController.showLoading()
		SyncManager.syncOperation(operationType: .getProductsList, info: appLanguageId) { (response, error) in
			if error == nil {
				ProgressIndicatorController.dismissProgressView()
				print("Categories Response1: \(response)")
				successHandler?(true)
				if let responseData = response as? [[String: AnyObject]] {
					DispatchQueue.main.async {
						self.categoriesInfo = responseData
					}
				}
			} else {
				ProgressIndicatorController.dismissProgressView()
				successHandler?(false)
			}
		}
	}
	
	func downloadNewArrivals(withSuccesshandler successHandler: DownloadCompletion? = nil) {
		let custGrpId = (AppManager.isUserLoggedIn) ? UserDefaultManager.sharedManager().customerGroupId : "1"
		SyncManager.syncOperation(operationType: .getNewArrivalProducts, info: custGrpId) { (response, error) in
			
			if error == nil {
				successHandler?(true)
				
				print("New Arrival Response: \(response)")
				
				if let newArrivalsInfo = response as? [[String: AnyObject]] {
					DispatchQueue.main.async {
						self.newArrivalsInfo = newArrivalsInfo
					}
				} else {
					
				}
			} else {
				ProgressIndicatorController.dismissProgressView()
				successHandler?(false)
			}
		}
	}
	
	
	func downloadTopSelliings(withSuccesshandler successHandler: DownloadCompletion? = nil) {
		let custGrpId = (AppManager.isUserLoggedIn) ? UserDefaultManager.sharedManager().customerGroupId : "1"
		SyncManager.syncOperation(operationType: .getTopSetllingProducts, info: custGrpId) { (response, error) in
			
			if error == nil {
				ProgressIndicatorController.dismissProgressView()
				successHandler?(true)
				
				print("New Arrival Response: \(response)")
				
				if let newArrivalsInfo = response as? [[String: AnyObject]] {
					DispatchQueue.main.async {
						self.topSelllingInfo = newArrivalsInfo
					}
				} else {
					
				}
			} else {
				ProgressIndicatorController.dismissProgressView()
				successHandler?(false)
			}
		}
	}
}

extension ProductsHomeViewController: SearchCompletionDelegate {
	
	func didTapDoneButton(withResultText text: String) {
		self.navigationController?.tabBarController?.tabBar.isHidden = false
		self.voiceSearchResult = text
		self.searchByVoiceText = text
	}
	
	func exitFormVoiceSearch() {
		self.navigationController?.tabBarController?.tabBar.isHidden = false
	}
}
