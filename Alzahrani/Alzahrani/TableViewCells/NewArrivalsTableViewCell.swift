	//
	//  NewArrivalsTableViewCell.swift
	//  Alzahrani
	//
	//  Created by Hardwin on 04/05/17.
	//  Copyright © 2017 Ramprasad A. All rights reserved.
	//
	
	import UIKit
	import CoreData
	import AlamofireImage
	
	protocol CellButtonActionsDelegate: NSObjectProtocol {
		func didTapShareButton(withProduInfo info: Product?, withOnlineProduct onlineProd: [String: AnyObject]?)
		func didTapCartProductButton()
	}
	
	typealias ImageDownloadHandler = ((_ success: Bool, _ response: Data?) -> Void)
	typealias NewArrivalTapCallback = ((_ success: Bool, _ withProduct: String?, _ productData: ProductData?, _ productInfo: [String: AnyObject]?) -> Void)
	
	class NewArrivalsTableViewCell: UITableViewCell {
		
		//MARK:- IB-Outlets:
		@IBOutlet weak var newArrivalsCollectionView: UICollectionView!
		
		//MARK:- Properties:-
		weak var delegate: CellButtonActionsDelegate?
		var cellTappedHandler: NewArrivalTapCallback?
		var newArrivalsList = [NewArrival]()
		var newArrivalImageData = [BannerImage]()
		var newArrivalsInfo = [[String: AnyObject]]()
		var productDataSource = [Product]()
		// var newArrivals = [[String: AnyObject]]()
		
		//MARK:- Life Cycle:-
		override func awakeFromNib() {
			self.contentView.backgroundColor = UIColor(rgba: "EBEBF1")
			super.awakeFromNib()
			self.addNotificationObservers()
			self.setupCollectionView()
			
			//           // self.handleOnlineModeProductDownload()
		}
		
		override func setSelected(_ selected: Bool, animated: Bool) {
			super.setSelected(selected, animated: animated)
		}
		
		//MARK:- Default Initilizers:-
		override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
			super.init(style: style, reuseIdentifier: reuseIdentifier)
		}
		
		required init?(coder aDecoder: NSCoder) {
			super.init(coder: aDecoder)
		}
	}
	
	//MARK:- Helper Methods:
	extension NewArrivalsTableViewCell {
		
		func addNotificationObservers() {
			NotificationCenter.default.addObserver(self, selector: #selector(NewArrivalsTableViewCell.reloadUI), name: Notification.Name("NewArrivalDownloadSuccessNotification"), object: nil)
			NotificationCenter.default.addObserver(self, selector: #selector(NewArrivalsTableViewCell.handleCartProductRemove), name: Notification.Name("MyCartUpdateNotification"), object: nil)
			NotificationCenter.default.addObserver(self, selector: #selector(NewArrivalsTableViewCell.handleMyWishlistRemove), name: Notification.Name("WishListUpdateNotification"), object: nil)
			NotificationCenter.default.addObserver(self, selector: #selector(NewArrivalsTableViewCell.handleWishListAdd), name: Notification.Name("WishListAddNotification"), object: nil)
			NotificationCenter.default.addObserver(self, selector: #selector(NewArrivalsTableViewCell.handleCartAddNotification), name: Notification.Name("CartAddNotification"), object: nil)
			NotificationCenter.default.addObserver(self, selector: #selector(NewArrivalsTableViewCell.updateProductCartStatus), name: Notification.Name("UpdateProductCartStatus"), object: nil)
		}
		
		func reloadUI() {
			if self.newArrivalsList.count == 0 {
				self.getAllNewArrivalsData()
			}
			self.newArrivalsCollectionView.reloadData()
		}
		
		func handleCartProductRemove(notification: Notification) {
			if let object = notification.object as? [String: AnyObject] {
				if let cartObjectId = object["removedProduct"] as? String {
					
					if AppManager.currentApplicationMode() == .online {
						for (index, product) in newArrivalsInfo.enumerated() {
							if let productId = product["product_id"] as? String {
								if productId == cartObjectId {
									let indexPath = IndexPath(row: index, section: 0)
									let cell = self.newArrivalsCollectionView.cellForItem(at: indexPath)
									
									if let selectedCartImage = UIImage(named: "cart_prod_icon") {
										(cell as? NewArrivalsCollectionViewCell)?.cartButton.setImage(selectedCartImage, for: .normal)
										(cell as? NewArrivalsCollectionViewCell)?.cartButton.setImage(selectedCartImage, for: .highlighted)
									}
								}
							}
						}
					} else {
						if let newArrivalObject = NewArrival.getNewArrivalProductWith(prodId: cartObjectId) {
							newArrivalObject.isInCart = false
							
							do {
								try newArrivalObject.managedObjectContext?.save()
							} catch {
								print("Error: New Arrival Update error")
							}
							self.newArrivalsCollectionView.reloadData()
						}
					}
				}
			}
		}
		
		func updateProductCartStatus() {
			
			for (index, _) in self.newArrivalsInfo.enumerated() {
				let indexPath = IndexPath(row: index, section: 0)
				if let cell = self.newArrivalsCollectionView.cellForItem(at: indexPath) {
					if let selectedCartImage = UIImage(named: "cart_prod_icon") {
						(cell as? NewArrivalsCollectionViewCell)?.cartButton.setImage(selectedCartImage, for: .normal)
						(cell as? NewArrivalsCollectionViewCell)?.cartButton.setImage(selectedCartImage, for: .highlighted)
					}
				}
			}
		}
		
		func handleMyWishlistRemove(notification: Notification) {
			if let object = notification.object as? [String: AnyObject] {
				if let wishListObj = object["removedProduct"] as? String {
					
					if AppManager.currentApplicationMode() == .online {
						for (index, product) in newArrivalsInfo.enumerated() {
							if let productId = product["product_id"] as? String {
								if productId == wishListObj {
									let indexPath = IndexPath(row: index, section: 0)
									let cell = self.newArrivalsCollectionView.cellForItem(at: indexPath)
									
									if let heartRedImage = UIImage(named: "wishlist_prod_icon") {
										(cell as? NewArrivalsCollectionViewCell)?.wishListButton.setImage(heartRedImage, for: .normal)
										(cell as? NewArrivalsCollectionViewCell)?.wishListButton.setImage(heartRedImage, for: .highlighted)
									}
								}
							}
						}
					} else {
						if let newArrivalObject = NewArrival.getNewArrivalProductWith(prodId: wishListObj) {
							newArrivalObject.isInCart = false
							
							do {
								try newArrivalObject.managedObjectContext?.save()
							} catch {
								print("Error: New Arrival Update error")
							}
							self.newArrivalsCollectionView.reloadData()
						}
					}
				}
			}
		}
		
		func handleWishListAdd(notification: Notification) {
			if let object = notification.object as? [String: AnyObject] {
				if let wishListObj = object["AddWishlistProd"] as? String {
					
					if AppManager.currentApplicationMode() == .online {
						for (index, product) in newArrivalsInfo.enumerated() {
							if let productId = product["product_id"] as? String {
								if productId == wishListObj {
									let indexPath = IndexPath(row: index, section: 0)
									let cell = self.newArrivalsCollectionView.cellForItem(at: indexPath)
									
									if let heartRedImage = UIImage(named: "wishList_red") {
										(cell as? NewArrivalsCollectionViewCell)?.wishListButton.setImage(heartRedImage, for: .normal)
										(cell as? NewArrivalsCollectionViewCell)?.wishListButton.setImage(heartRedImage, for: .highlighted)
									}
								}
							}
						}
					} else {
						
					}
				}
			}
		}
		
		func handleCartAddNotification(notification: Notification) {
			if let object = notification.object as? [String: AnyObject] {
				if let wishListObj = object["AddCartProd"] as? String {
					
					if AppManager.currentApplicationMode() == .online {
						for (index, product) in newArrivalsInfo.enumerated() {
							if let productId = product["product_id"] {
								if productId as! String == wishListObj {
									let indexPath = IndexPath(row: index, section: 0)
									let cell = self.newArrivalsCollectionView.cellForItem(at: indexPath)
									
									if let selectedCartImage = UIImage(named: "cart_sel_icon") {
										(cell as? NewArrivalsCollectionViewCell)?.cartButton.setImage(selectedCartImage, for: .normal)
										(cell as? NewArrivalsCollectionViewCell)?.cartButton.setImage(selectedCartImage, for: .highlighted)
									}
								}
							}
						}
					} else {
						
					}
				}
			}
		}
		
		func setupCollectionView() {
			let nib = UINib(nibName: "NewArrivalsCollectionViewCell", bundle: nil)
			self.newArrivalsCollectionView.register(nib, forCellWithReuseIdentifier: "NewArrivalsCollectionViewCell")
			self.newArrivalsCollectionView.backgroundColor = UIColor.clear
			self.newArrivalsCollectionView.dataSource = self
			self.newArrivalsCollectionView.delegate = self
		}
		
		func getAllNewArrivalsData() {
			self.newArrivalsList = NewArrival.getAllNewArrivals()!
		}
		
		/*func handleOnlineModeProductDownload() {
		if AppManager.currentApplicationMode() == .offline {
		//self.getAllNewArrivalsData()
		} else {
		self.downloadNewArrivals(withSuccesshandler: { (success) in
		if success {
		DispatchQueue.main.async {
		self.newArrivalsCollectionView.reloadData()
		}
		}
		})
		}
		}*/
		
		/* func downloadNewArrivals(withSuccesshandler successHandler: DownloadCompletion? = nil) {
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
		successHandler?(false)
		}
		}
		}*/
		
		func handleWishListData(withProduInfo info: Product?, withCellInfo cell: NewArrivalsCollectionViewCell, withOnlineProd product: [String: AnyObject]? = nil) {
			
			var wishListInfo = [String: AnyObject]()
			if AppManager.currentApplicationMode() == .online {
				if let wishlistProdId = product?["product_id"] {
					if self.checkProductIsLiked(withProdId: wishlistProdId.description) {
						if let heartRedImage = UIImage(named: "wishList_red") {
							cell.wishListButton.setImage(heartRedImage, for: .normal)
							cell.wishListButton.setImage(heartRedImage, for: .highlighted)
							
							NotificationCenter.default.post(name: Notification.Name("WishListUpdateNotification"), object: nil)
						}
					} else {
						if let heartRedImage = UIImage(named: "wishlist_prod_icon") {
							cell.wishListButton.setImage(heartRedImage, for: .normal)
							cell.wishListButton.setImage(heartRedImage, for: .highlighted)
							
							NotificationCenter.default.post(name: Notification.Name("WishListUpdateNotification"), object: nil)
						}
					}
				}
			} else {
				if let id = info?.productId, let name = info?.productName, let image = info?.image
					, let price = info?.price {
					wishListInfo["name"] = name as AnyObject?
					wishListInfo["product_id"] = id as AnyObject?
					wishListInfo["image"] = image as AnyObject?
					wishListInfo["price"] = price as AnyObject?
					
					//wishlist_prod_icon
					if !(self.checkProductIsLiked(withProdId: id)) {
						let _ = WishLists.addProductToWishList(data: wishListInfo)
						if let heartRedImage = UIImage(named: "wishList_red") {
							cell.wishListButton.setImage(heartRedImage, for: .normal)
							cell.wishListButton.setImage(heartRedImage, for: .highlighted)
							
							NotificationCenter.default.post(name: Notification.Name("WishListUpdateNotification"), object: nil)
							
							ALAlerts.showToast(message: NSLocalizedString("ITEM_ADDED_TO_WISHLIST", comment: ""))
						}
					} else {
						let _ = WishLists.removeProduct(withId: id)
						if let heartRedImage = UIImage(named: "wishlist_prod_icon") {
							cell.wishListButton.setImage(heartRedImage, for: .normal)
							cell.wishListButton.setImage(heartRedImage, for: .highlighted)
							
							NotificationCenter.default.post(name: Notification.Name("WishListUpdateNotification"), object: nil)
							ALAlerts.showToast(message: NSLocalizedString("ITEM_REMOVED_FROM_WISHLIST", comment: ""))
						}
					}
				}
			}
		}
		
		func handleCartData(withProduInfo info: Product?, withCellInfo cell: NewArrivalsCollectionViewCell, withOnlineProd product: [String: AnyObject]? = nil) {
			
			if AppManager.currentApplicationMode() == .online {
				//                self.delegate?.didTapCartProductButton()
				if let cartProdId = product?["product_id"] {
					if self.checkProducIsInCart(withProdId: cartProdId.description) {
						if let normalCartImage = UIImage(named: "cart_sel_icon") {
							cell.cartButton.setImage(normalCartImage, for: .normal)
							cell.cartButton.setImage(normalCartImage, for: .highlighted)
							
							NotificationCenter.default.post(name: Notification.Name("MyCartUpdateNotification"), object: nil)
						}
					} else {
						if let selectedCartImage = UIImage(named: "cart_prod_icon") {
							cell.cartButton.setImage(selectedCartImage, for: .normal)
							cell.cartButton.setImage(selectedCartImage, for: .highlighted)
							
							NotificationCenter.default.post(name: Notification.Name("MyCartUpdateNotification"), object: nil)
						}
					}
				}
			} else {
				//Offline scenario
				var myCartInfo = [String: AnyObject]()
				if AppManager.isUserLoggedIn {
					
					if let cartProd = info {
						cartProd.isInCart = !cartProd.isInCart
						do {
							try cartProd.managedObjectContext?.save()
						} catch {
							print("Product not added to Cart")
						}
					}
					
					if let id = info?.productId, let _ = info?.image, let image = info?.image, let price = info?.price {
						
						myCartInfo["name"] = info?.productName as AnyObject?
						myCartInfo["product_id"] = id as AnyObject?
						myCartInfo["image"] = image as AnyObject?
						myCartInfo["price"] = price as AnyObject?
						
						//wishlist_prod_icon
						if MyCart.getProductWith(productId: id) == nil {
							let _ = MyCart.addProductToMyCartList(data: myCartInfo)
							if let normalCartImage = UIImage(named: "cart_sel_icon") {
								cell.cartButton.setImage(normalCartImage, for: .normal)
								cell.cartButton.setImage(normalCartImage, for: .highlighted)
								
								NotificationCenter.default.post(name: Notification.Name("MyCartUpdateNotification"), object: nil)
							}
						} else {
							let _ = MyCart.removeProduct(withId: id)
							if AppManager.isUserLoggedIn {
								UploadTaskHandler.sharedInstance.deleteMyCartData(withProductId: id, "")
							}
							if let selectedCartImage = UIImage(named: "cart_prod_icon") {
								cell.cartButton.setImage(selectedCartImage, for: .normal)
								cell.cartButton.setImage(selectedCartImage, for: .highlighted)
								
								NotificationCenter.default.post(name: Notification.Name("MyCartUpdateNotification"), object: nil)
							}
						}
					}
				} else {
				}
			}
		}
		
		func checkProducIsInCart(withProdId id: String) -> Bool {
			if let _ = MyCart.getProductWith(productId: id) {
				return true
			} else {
				return false
			}
		}
		
		func checkProductIsLiked(withProdId id: String) -> Bool {
			if let _ = WishLists.getProductWith(productId: id) {
				return true
			} else {
				return false
			}
		}
		
		func getProductData(atIndex indexPath: IndexPath) -> ProductData {
			let product = self.newArrivalsInfo[(indexPath.row)]
			let isInCart = self.checkProducIsInCart(withProdId: product["product_id"] as! String)
			let isLiked = self.checkProductIsLiked(withProdId: product["product_id"] as! String)
			
			let productData = ProductData(withName: product["name"] as! String, withProductId: product["product_id"] as! String, andDescription: product["description"] as! String, product["sku"] as! String, product["price"] as! String, prodImage: product["image"] as! String, isInCart, isLiked, specialPrice: product["special"] as? String ?? "", availability: product["quantity"] as! String, "","")
			
			return productData
		}
		
		func updateWishlistStatus(withProductId id: String, atCell cell: NewArrivalsCollectionViewCell) {
			if self.checkProductIsLiked(withProdId: id ) {
				if let heartRedImage = UIImage(named: "wishList_red") {
					cell.wishListButton.setImage(heartRedImage, for: .normal)
					cell.wishListButton.setImage(heartRedImage, for: .highlighted)
					
					NotificationCenter.default.post(name: Notification.Name("WishListUpdateNotification"), object: nil)
				}
			} else {
				if let heartRedImage = UIImage(named: "wishlist_prod_icon") {
					cell.wishListButton.setImage(heartRedImage, for: .normal)
					cell.wishListButton.setImage(heartRedImage, for: .highlighted)
					
					NotificationCenter.default.post(name: Notification.Name("WishListUpdateNotification"), object: nil)
				}
			}
		}
		
		func setDataSource(withData data: [[String: AnyObject]]) {
			self.newArrivalsInfo = data
		}
	}
	
	//MARK:- UICollectionViewDataSource:
	extension NewArrivalsTableViewCell: UICollectionViewDataSource {
		
		func numberOfSections(in collectionView: UICollectionView) -> Int {
			self.newArrivalsCollectionView.collectionViewLayout.invalidateLayout()
			return 1
		}
		
		func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
			
			if AppManager.currentApplicationMode() == .online {
				return self.newArrivalsInfo.count
			} else {
				if self.productDataSource.count > 25 {
					return 25
				} else {
					return self.productDataSource.count
				}
			}
		}
		
		func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewArrivalsCollectionViewCell", for: indexPath) as? NewArrivalsCollectionViewCell
			cell?.cellActionHandlerDelegate = self
			cell?.goToProductDetailPageBtn.tag = indexPath.row
			cell?.goToProductDetailPageBtn.addTarget(self, action: #selector(self.goToProductDetailPageTapped(sender:)), for: .touchUpInside)
			
			let userDefaults = UserDefaultManager.sharedManager()
			let customerGroupId = userDefaults.customerGroupId
			
			if AppManager.currentApplicationMode() == .online {
				let newArrivalProd = self.newArrivalsInfo[indexPath.row]
				
				self.handleCartData(withProduInfo: nil, withCellInfo: cell!, withOnlineProd: newArrivalProd)
				let nameKey = (AppManager.languageType() == .english) ? "name" : "name"
				if let produName = newArrivalProd[nameKey] as? String, let prodPrice = newArrivalProd["price"] as? String, let image = newArrivalProd["image"] {
					cell?.productNameLabel.text = produName
					
					let prorperURL = image.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
					let imageURLStr = URLBuilder.getImageDownloadBaseURL() + prorperURL!
					
					UploadTaskHandler.sharedInstance.setImage(onImageView: (cell?.productImageView)!, withImageUrl: imageURLStr, placeHolderImage: nil)
					
					if let quantity = newArrivalProd["quantity"] as? String {
						let languageId = LanguageType(rawValue: UserDefaultManager.sharedManager().selectedLanguageId!)
						if let qty = Int(quantity) {
							if (qty >= 1 || customerGroupId == "15" || customerGroupId == "16") {
								//if(qty >= 1){
								cell?.outOfStockImageView.isHidden = true
								cell?.outOfStockArabicImageView.isHidden = true
								cell?.cartButton.isEnabled = true
								
							} else {
								
								if languageId == .english {
									
									cell?.outOfStockImageView.isHidden = false
									cell?.outOfStockArabicImageView.isHidden = true
									cell?.cartButton.isEnabled = false
									
								} else {
									cell?.outOfStockImageView.isHidden = true
									cell?.outOfStockArabicImageView.isHidden = false
									cell?.cartButton.isEnabled = false
								}
							}
						}
					}
					
					if let _ = MyCart.getProductWith(productId: newArrivalProd["product_id"] as! String) {
						if let normalCartImage = UIImage(named: "cart_sel_icon") {
							cell?.cartButton.setImage(normalCartImage, for: .normal)
							cell?.cartButton.setImage(normalCartImage, for: .highlighted)
						}
					} else {
						if let selectedCartImage = UIImage(named: "cart_prod_icon") {
							cell?.cartButton.setImage(selectedCartImage, for: .normal)
							cell?.cartButton.setImage(selectedCartImage, for: .highlighted)
						}
					}
					
					if let _ = WishLists.getProductWith(productId: newArrivalProd["product_id"] as! String) {
						if let heartRedImage = UIImage(named: "wishList_red") {
							cell?.wishListButton.setImage(heartRedImage, for: .normal)
							cell?.wishListButton.setImage(heartRedImage, for: .highlighted)
						}
					} else {
						if let heartRedImage = UIImage(named: "wishlist_prod_icon") {
							cell?.wishListButton.setImage(heartRedImage, for: .normal)
							cell?.wishListButton.setImage(heartRedImage, for: .highlighted)
						}
					}
					
					if let price = Double(prodPrice) {
						let roundedPrice = String(format: "%.2f", price)
						cell?.productOfferLabel.text = roundedPrice + " " + "SAR"
					}
					
					//Set Product Offers Price:
					if let specialPrice = newArrivalProd["special"] as? String {
						
						if let price = Double(newArrivalProd["price"] as? String ?? "") {
							let roundedPrice = String(format: "%.2f", price)
							let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: roundedPrice + " " + "SAR")
							attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))
							attributeString.addAttribute(NSStrikethroughColorAttributeName, value: UIColor(red:164/255,green:41/255,blue:63/255,alpha:1), range: NSMakeRange(0, attributeString.length))
							cell?.productPriceLabel.attributedText =  attributeString
						}
						
						if let price = Double(specialPrice) {
							let roundedPrice = String(format: "%.2f", price)
							cell?.productOfferLabel.text = roundedPrice + " " + "SAR"
						}
					} else {
						cell?.productPriceLabel.text = ""
						if let price = Double(newArrivalProd["price"] as? String ?? "") {
							let roundedPrice = String(format: "%.2f", price)
							cell?.productOfferLabel.text = roundedPrice + " " + "SAR"
						}
					}
				}
				
				if let specialPrice = newArrivalProd["special"] as? String, let price = newArrivalProd["price"] as? String {
					cell?.discountProductPrice.isHidden = false
					if let actualPrice = Float(price), let specialPrice = Float(specialPrice) {
						let difference = actualPrice - specialPrice
						let percentageDiscount = ((difference / actualPrice) * 100)
						let finalValue = Int(round(percentageDiscount))
						cell?.discountProductPrice.text = "- " + finalValue.description + "%"
					}
				} else {
					cell?.discountProductPrice.isHidden = true
				}
				
				return cell!
			} else {
				let newArrivalProduct = self.productDataSource[indexPath.row]
				let userSelectedLanguage = UserDefaultManager.sharedManager().selectedLanguageId
				if let languageType = LanguageType(rawValue: userSelectedLanguage!) {
					switch languageType {
					case .arabic:
						cell?.productNameLabel.text = newArrivalProduct.productName
					case .english:
						cell?.productNameLabel.text = newArrivalProduct.productName
					}
				}
				
				if let specialPrice = newArrivalProduct.specialPrice {
					
					let price = Double(newArrivalProduct.price)
					let roundedPrice = String(format: "%.2f", price)
					let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: roundedPrice + " " + "SAR")
					attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))
					attributeString.addAttribute(NSStrikethroughColorAttributeName, value: UIColor(red:164/255,green:41/255,blue:63/255,alpha:1), range: NSMakeRange(0, attributeString.length))
					cell?.productPriceLabel.attributedText =  attributeString
					
					if let price = Double(specialPrice) {
						let roundedPrice = String(format: "%.2f", price)
						cell?.productOfferLabel.text = roundedPrice + " " + "SAR"
					}
					
					cell?.discountProductPrice.isHidden = false
					let actualPrice = Float(price)
					let specialPrice = Float(specialPrice)
					let difference = actualPrice - specialPrice!
					let percentageDiscount = ((difference / actualPrice) * 100)
					let finalValue = Int(percentageDiscount)
					cell?.discountProductPrice.text = "- " + finalValue.description + "%"
					
				} else {
					cell?.discountProductPrice.isHidden = true
					cell?.productPriceLabel.text = ""
					let price = Double(newArrivalProduct.price)
					let roundedPrice = String(format: "%.2f", price)
					cell?.productOfferLabel.text = roundedPrice + " " + "SAR"
				}
				
				
				if let _ = MyCart.getProductWith(productId: newArrivalProduct.productId!) {
					if let normalCartImage = UIImage(named: "cart_sel_icon") {
						cell?.cartButton.setImage(normalCartImage, for: .normal)
						cell?.cartButton.setImage(normalCartImage, for: .highlighted)
					}
				} else {
					if let selectedCartImage = UIImage(named: "cart_prod_icon") {
						cell?.cartButton.setImage(selectedCartImage, for: .normal)
						cell?.cartButton.setImage(selectedCartImage, for: .highlighted)
					}
				}
				
				if let _ = WishLists.getProductWith(productId: newArrivalProduct.productId!) {
					if let heartRedImage = UIImage(named: "wishList_red") {
						cell?.wishListButton.setImage(heartRedImage, for: .normal)
						cell?.wishListButton.setImage(heartRedImage, for: .highlighted)
					}
				} else {
					if let heartRedImage = UIImage(named: "wishlist_prod_icon") {
						cell?.wishListButton.setImage(heartRedImage, for: .normal)
						cell?.wishListButton.setImage(heartRedImage, for: .highlighted)
					}
				}
				
				if let imageData = newArrivalProduct.imageData {
					if let image = UIImage(data: imageData as Data) {
						cell?.productImageView.image = image
					}
				} else {
					cell?.productImageView.image = #imageLiteral(resourceName: "placeHolderImage")
				}
				
				if let offerPrice = newArrivalProduct.specialPrice {
					if offerPrice != "" {
						cell?.discountProductPrice.isHidden = false
						let actualPrice = Float(newArrivalProduct.price)
						let specialPrice = Float(newArrivalProduct.specialPrice!)
						let difference = actualPrice - specialPrice!
						let percentageDiscount = ((difference / actualPrice) * 100)
						let finalValue = Int(percentageDiscount)
						cell?.discountProductPrice.text = "- " + finalValue.description
					} else {
						cell?.discountProductPrice.isHidden = true
					}
				}
				
				let quantity = newArrivalProduct.availability
				let languageId = LanguageType(rawValue: UserDefaultManager.sharedManager().selectedLanguageId!)
				let qty = Int(quantity)

				if (qty >= 1 || customerGroupId == "15" || customerGroupId == "16") {
					cell?.outOfStockImageView.isHidden = true
					cell?.outOfStockArabicImageView.isHidden = true
					cell?.cartButton.isEnabled = true
				} else {
					
					if languageId == .english {
						cell?.outOfStockImageView.isHidden = false
						cell?.outOfStockArabicImageView.isHidden = true
						cell?.cartButton.isEnabled = false
					} else {
						cell?.outOfStockImageView.isHidden = true
						cell?.outOfStockArabicImageView.isHidden = false
						cell?.cartButton.isEnabled = false
					}
				}
				
				return cell!
			}
		}
		
		//MARK: Go to product detail page
		func goToProductDetailPageTapped(sender : UIButton){
			
			let indexPath = IndexPath(item: sender.tag, section: 0)
			
			if let cell = self.newArrivalsCollectionView.cellForItem(at: indexPath) {
				if AppManager.currentApplicationMode() == .online {
					let newArrivalProduct = self.newArrivalsInfo[indexPath.row]
					
					if let _ = newArrivalProduct["product_id"] as? String {
						self.cellTappedHandler?(true, nil, self.getProductData(atIndex: indexPath), self.newArrivalsInfo[indexPath.row])
					}
				} else {
					if ((cell as? NewArrivalsCollectionViewCell)?.isValidTouch)! {
						let newArrivalProduct = self.productDataSource[indexPath.row]
						self.cellTappedHandler?(true, newArrivalProduct.productId, nil, nil)
					}
				}
			}
		}
	}
	
	
	
	
	//MARK:- UICollectionViewDelegate:
	extension NewArrivalsTableViewCell: UICollectionViewDelegate {
		
		
		func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
			if let cell = self.newArrivalsCollectionView.cellForItem(at: indexPath) {
				if AppManager.currentApplicationMode() == .online {
					let newArrivalProduct = self.newArrivalsInfo[indexPath.row]
					if let _ = newArrivalProduct["product_id"] as? String {
						if ((cell as? NewArrivalsCollectionViewCell)?.isValidTouch)! {
							self.cellTappedHandler?(true, nil, self.getProductData(atIndex: indexPath), self.newArrivalsInfo[indexPath.row])
						}
					}
				} else {
					if ((cell as? NewArrivalsCollectionViewCell)?.isValidTouch)! {
						let newArrivalProduct = self.productDataSource[indexPath.row]
						self.cellTappedHandler?(true, newArrivalProduct.productId, nil, nil)
					}
				}
			}
		}
	}
	
	//MARK:- UICollectionViewDelegateFlowLayout:
	extension NewArrivalsTableViewCell: UICollectionViewDelegateFlowLayout {
		
		func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
			if UIDevice.current.userInterfaceIdiom == .pad {
				return CGSize(width: self.frame.size.width * 0.3, height: self.frame.size.height)
			} else {
				return CGSize(width: self.frame.size.width * 0.4, height: self.frame.size.height)
			}
		}
	}
	
	extension NewArrivalsTableViewCell: CellButtonActionProtocol {
		
		func didTapShareButton(atCell cell: NewArrivalsCollectionViewCell) {
			if AppManager.currentApplicationMode() == .online {
				if let indexPath = self.newArrivalsCollectionView.indexPath(for: cell) {
					let shareProduct = self.newArrivalsInfo[indexPath.row]
					//print("Sharing \(shareProduct.name)")
					self.delegate?.didTapShareButton(withProduInfo: nil, withOnlineProduct: shareProduct)
				}
			} else {
				if let indexPath = self.newArrivalsCollectionView.indexPath(for: cell) {
					let shareProduct = self.productDataSource[indexPath.row]
					print("Sharing \(shareProduct.productName)")
					self.delegate?.didTapShareButton(withProduInfo: shareProduct, withOnlineProduct: nil)
				}
			}
		}
		
		func didTapCartButton(atCell cell: NewArrivalsCollectionViewCell) {
			if AppManager.isUserLoggedIn {
				var cartListInfo = [String: AnyObject]()
				if AppManager.currentApplicationMode() == .online {
					if let indexPath = self.newArrivalsCollectionView.indexPath(for: cell) {
						let cartProd = self.newArrivalsInfo[indexPath.row]
						if let cartProdName = cartProd["name"] as? String, let prodId = cartProd["product_id"] {
							cartListInfo["name"] = cartProdName as AnyObject?
							cartListInfo["product_id"] = prodId as AnyObject?
							if ((AppManager.isUserLoggedIn) && (!self.checkProducIsInCart(withProdId: prodId as! String))) {
								UploadTaskHandler.sharedInstance.uploadIndividualMyCartData(withProductId: prodId as? String, withHandler: { (success, cartId) in
									
									if success {
										cartListInfo["cart_id"] = cartId as AnyObject?
										let _ = MyCart.addProductToMyCartList(data: cartListInfo)
										self.handleCartData(withProduInfo: nil, withCellInfo: cell, withOnlineProd: cartListInfo)
										ALAlerts.showToast(message: NSLocalizedString("ITEM_ADDED_TO_CART", comment: ""))
										cell.cartButton.isEnabled = true
									} else {
										ALAlerts.showToast(message: NSLocalizedString("ITEM_NOT_ADDED_TO_CART", comment: ""))
										cell.cartButton.isEnabled = true
									}
								})
							} else {
								self.delegate?.didTapCartProductButton()
								if let cartProduct = MyCart.getProductWith(productId: prodId as! String) {
									if let cartId = cartProduct.cartId {
										UploadTaskHandler.sharedInstance.deleteMyCartData(withProductId: prodId as? String, cartId, withHandler: { (success) in
											if success {
												if let cartProdId = cartProduct.productId {
													let _ = MyCart.removeProduct(withId: cartProdId)
												}
												ALAlerts.showToast(message: NSLocalizedString("ITEM_REMOVED_FROM_CART", comment: ""))
												self.handleCartData(withProduInfo: nil, withCellInfo: cell, withOnlineProd: cartListInfo)
											}
											cell.cartButton.isEnabled = true
											
										})
									} else {
										cell.cartButton.isEnabled = true
									}
								}
							}
						}
					}
				} else {
					if let indexPath = self.newArrivalsCollectionView.indexPath(for: cell) {
						let cartProd = self.productDataSource[indexPath.row]
						cartListInfo["name"] = cartProd.productName as AnyObject?
						cartListInfo["product_id"] = cartProd.productId as AnyObject?
						cartListInfo["total"] = cartProd.price as AnyObject?
						cartListInfo["price"] = cartProd.price as AnyObject?
						cartListInfo["quantity"] = 1 as AnyObject?
						if !checkProducIsInCart(withProdId: cartProd.productId!) {
							
							print("Product is not in Cart")
							self.addProductToCart(withProductDetails: cartListInfo, atCell: cell)
							//cartProd.isInCart = true
						} else {
							self.removeProductFromCart(withProductDetails: cartProd, atCell: cell)
							//cartProd.isInCart = false
						}
						cell.cartButton.isEnabled = true
						do {
							try cartProd.managedObjectContext?.save()
							cartProd.managedObjectContext?.mr_saveToPersistentStoreAndWait()
						} catch let error {
							print("Error Saving Cart Object \(error.localizedDescription)")
						}
					}
				}
			} else {
				cell.cartButton.isEnabled = true
				self.delegate?.didTapCartProductButton()
			}
		}
		
		func didTapWishlistButton(atCell cell: NewArrivalsCollectionViewCell) {
			if AppManager.isUserLoggedIn {
				var wishListInfo = [String: AnyObject]()
				if AppManager.currentApplicationMode() == .online {
					if let indexPath = self.newArrivalsCollectionView.indexPath(for: cell) {
						let cartProd = self.newArrivalsInfo[indexPath.row]
						if let cartProdName = cartProd["name"] as? String, let prodId = cartProd["product_id"] {
							wishListInfo["name"] = cartProdName as AnyObject?
							wishListInfo["product_id"] = prodId as AnyObject?
							if ((AppManager.isUserLoggedIn) && (!self.checkProductIsLiked(withProdId: prodId as! String))) {
								UploadTaskHandler.sharedInstance.uploadIndividualWishList(withProductId: prodId as? String, withHandler: { (success) in
									if success {
										let _ = WishLists.addProductToWishList(data: wishListInfo)
										self.handleWishListData(withProduInfo: nil, withCellInfo: cell, withOnlineProd: wishListInfo)
										ALAlerts.showToast(message: NSLocalizedString("ITEM_ADDED_TO_WISHLIST", comment: ""))
										cell.wishListButton.isEnabled = true
										
									} else {
										ALAlerts.showToast(message: NSLocalizedString("ITEM_NOT_ADDED_TO_WISHLIST", comment: ""))
										cell.wishListButton.isEnabled = true
									}
								})
							} else {
								if let wishListProd = WishLists.getProductWith(productId: prodId as! String) {
									
									if let cartProdId = wishListProd.productId {
										
										UploadTaskHandler.sharedInstance.deleteWishListData(withProductId: cartProdId, withHandler: { (success) in
											if success {
												let _ = WishLists.removeProduct(withId: cartProdId)
												ALAlerts.showToast(message: NSLocalizedString("ITEM_REMOVED_FROM_WISHLIST", comment: ""))
												self.handleWishListData(withProduInfo: nil, withCellInfo: cell, withOnlineProd: wishListInfo)
												cell.wishListButton.isEnabled = true
											}
										})
									} else {
										cell.wishListButton.isEnabled = true
									}
								}
							}
						}
					}
				} else {
					if let indexPath = self.newArrivalsCollectionView.indexPath(for: cell) {
						let wishListProduct = self.productDataSource[indexPath.row]
						self.handleWishListData(withProduInfo: wishListProduct, withCellInfo: cell)
						cell.wishListButton.isEnabled = true
					}
				}
			} else {
				cell.wishListButton.isEnabled = true
				self.delegate?.didTapCartProductButton()
			}
		}
	}
	
	//MARK:- Cart Helper Methods:
	extension NewArrivalsTableViewCell {
		
		func addProductToCart(withProductDetails productInfo: [String: AnyObject], atCell cell: NewArrivalsCollectionViewCell) {
			
			let _ = MyCart.addProductToMyCartList(data: productInfo)
			if let normalCartImage = UIImage(named: "cart_sel_icon") {
				cell.cartButton.setImage(normalCartImage, for: .normal)
				cell.cartButton.setImage(normalCartImage, for: .highlighted)
				
				NotificationCenter.default.post(name: Notification.Name("MyCartUpdateNotification"), object: nil)
				
				ALAlerts.showToast(message: NSLocalizedString("ITEM_ADDED_TO_CART", comment: ""))
			}
		}
		
		func removeProductFromCart(withProductDetails productInfo: Product, atCell cell: NewArrivalsCollectionViewCell) {
			if let productId = productInfo.productId {
				let _ = MyCart.removeProduct(withId: productId)
				
				if let selectedCartImage = UIImage(named: "cart_prod_icon") {
					cell.cartButton.setImage(selectedCartImage, for: .normal)
					cell.cartButton.setImage(selectedCartImage, for: .highlighted)
					
					NotificationCenter.default.post(name: Notification.Name("MyCartUpdateNotification"), object: nil)
					
					ALAlerts.showToast(message: NSLocalizedString("ITEM_REMOVED_FROM_CART", comment: ""))
				}
			}
		}
	}
