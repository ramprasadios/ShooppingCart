	//
	//  UploadTaskHandler.swift
	//  Alzahrani
	//
	//  Created by Hardwin on 10/06/17.
	//  Copyright © 2017 Ramprasad A. All rights reserved.
	//
	
	import Foundation
	import MagicalRecord
	import Alamofire
	
	typealias SuccessHandler = ((_ success: Bool) -> Void)
	typealias CartUploadSuccessHandler = ((_ success: Bool, _ id: String) -> Void)
	
	struct AddressInfo {
		let address: [String: AnyObject]?
		let addressType: AddressType?
		
		init(withAddress address: [String: AnyObject], addressType type: AddressType) {
			self.address = address
			self.addressType = type
		}
	}
	
	class UploadTaskHandler: NSObject {
		
		class var sharedInstance: UploadTaskHandler {
			struct Static {
				static let instance = UploadTaskHandler()
			}
			return Static.instance
		}
		
		let customerGroupId: String = UserDefaultManager.sharedManager().customerGroupId ?? ""
		var newAddressInfo = [AddressInfo]()
	}
	
	//MARK:- Wish List Sync Task
	extension UploadTaskHandler {
		
		func checkAndUploadAllWishListsData() {
			
			if let wishLists = WishLists.getAllWishlists(), wishLists.count > 0 {
				for wishListObj in wishLists {
					if let productId = wishListObj.productId, let userId = UserDefaultManager.sharedManager().loginUserId {
						let syncFormat = "customer_id=\(userId)&product_id=\(productId)"
						self.syncWishListData(withData: syncFormat)
					}
				}
			}
		}
		
		func uploadIndividualWishList(withProductId id: String?, withHandler successHandler: SuccessHandler? = nil) {
			if let productId = id, let userId = UserDefaultManager.sharedManager().loginUserId {
				let syncFormat = "customer_id=\(userId)&product_id=\(productId)"
				self.syncWishListData(withData: syncFormat, withHandler: { (success) in
					if success {
						successHandler?(true)
					} else {
						successHandler?(false)
					}
				})
			}
		}
		
		func syncWishListData(withData data: String, withHandler successHandler: SuccessHandler? = nil) {
			SyncManager.syncOperation(operationType: .uploadWishListData, info: data) { (response, error) in
				if response != nil {
					successHandler?(true)
				} else {
					successHandler?(false)
				}
			}
		}
		
		func deleteWishListData(withProductId id: String?, withHandler successHandler: SuccessHandler? = nil) {
			if let productId = id, let userId = UserDefaultManager.sharedManager().loginUserId {
				let syncFormat = "customer_id=\(userId)&product_id=\(productId)"
				self.syncWishlistDelete(withData: syncFormat, withHandler: { (success) in
					if success {
						successHandler?(true)
					} else {
						successHandler?(false)
					}
				})
			}
		}
		
		func syncWishlistDelete(withData data: String, withHandler successHandler: SuccessHandler? = nil) {
			SyncManager.syncOperation(operationType: .deleteWishListData, info: data) { (response, error) in
				if error == nil {
					successHandler?(true)
				} else {
					successHandler?(false)
				}
			}
		}
	}
	
	//MARK:- MyCart List sync task
	extension UploadTaskHandler {
		
		func checkAndUploadAllMyCartData(withQuantity qty: Int) {
			
			if let myCartList = MyCart.getAllMyCartlist(), myCartList.count > 0 {
				for myCartObj in myCartList {
					if let productId = myCartObj.productId, let userId = UserDefaultManager.sharedManager().loginUserId {
						let syncFormat = "customer_id=\(userId)&product_id=\(productId)&customer_group_id=\(customerGroupId)&quantity=\(qty)"
						self.syncMyCartData(withData: syncFormat)
					}
				}
			}
		}
		
		func uploadIndividualMyCartData(withProductId id: String?, withQuantity qty: String? = "1", withSubtractQty subQty: String? = "1", withHandler successHandler: CartUploadSuccessHandler? = nil) {
			print("Testing prime");
			if let productId = id, let userId = UserDefaultManager.sharedManager().loginUserId, let quantity = qty {
				let languageId = (AppManager.languageType() == .arabic) ? "2" : "1"
				let syncFormat = "customer_id=\(userId)&product_id=\(productId)&customer_group_id=\(customerGroupId)&quantity=\(quantity)&language_id=\(languageId)"
				self.syncMyCartData(withData: syncFormat, withHandler: { (success, id) in
					if success {
						successHandler?(true, id)
					} else {
						successHandler?(false, id)
					}
				})
			}
		}
		
		
		func syncMyCartData(withData data: String, withHandler successHandler: CartUploadSuccessHandler? = nil) {
			SyncManager.syncOperation(operationType: .uploadMyCartListData, info: data) { (response, error) in
				print("testing 1:\(data)")
				print("testing 2:\(response)")
				if error == nil {
					print("testing 3")
					//                    self.downloadAddedCartData()
					if let responseData = response as? [[String: AnyObject]] {
						if let cartIdData = responseData.last {
							print("testing 4 \(cartIdData)")
							if let cartIdInfo = cartIdData["cart_id"] as? [[String: AnyObject]] {
								if let cartIdObject = cartIdInfo.first {
									if let cartId = cartIdObject["cart_id"] as? String {
										print("testing 5 \(cartId)")
										
										successHandler?(true, cartId)
									}
								}
							}
						}
					} else {
						
						successHandler?(true, "")
					}
				} else {
					
					successHandler?(false, "")
				}
			}
		}
		
		func deleteMyCartData(withProductId id: String?, _ cartId: String?, withHandler successHandler: SuccessHandler? = nil) {
			var languageId: String?
			if let langId = LanguageType(rawValue: UserDefaultManager.sharedManager().selectedLanguageId!) {
				switch langId {
				case .english:
					languageId = "1"
				case .arabic:
					languageId = "2"
				}
			}
			if let cartIdString = cartId, let languageIdStrig = languageId {
				if let productId = id, let userId = UserDefaultManager.sharedManager().loginUserId {
					//self.downloadAddedCartData()
					let syncFormat = "cart_id=\(cartIdString)&customer_id=\(userId)&product_id=\(productId)&language_id=\(languageIdStrig)"
					self.syncMyCartListDelete(withData: syncFormat, withHandler: { (success) in
						if success {
							successHandler?(true)
						}
					})
				}
			}
		}
		
		func syncMyCartListDelete(withData data: String, withHandler successHandler: SuccessHandler? = nil) {
			SyncManager.syncOperation(operationType: .deleteCartProduct, info: data) { (response, error) in
				if error == nil {
					successHandler?(true)
				}
			}
		}
		
		func downloadAddedCartData() {
			
			MyCart.removeAllMyCartListData()
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
					}
				})
			}
		}
	}
	
	extension UploadTaskHandler {
		
		func setImage(onImageView image:UIImageView,withImageUrl imageUrl:String?,placeHolderImage: UIImage?) {
			
			if let imgurl = imageUrl{
				
				image.kf.indicatorType = IndicatorType.activity
				image.kf.setImage(with: URL(string: imgurl), placeholder: placeHolderImage, options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, url) in
					
					if error != nil {
						print("Error setting Image \(error)")
					}
				})
			}
			else {
				image.image = placeHolderImage
			}
			
		}
	}
	
	extension UploadTaskHandler {
		
		func placeOfflineOrders() {
			let myGroup = DispatchGroup()
			if let offlineOrders = Orders.getAllOrdersData() {
				for order in offlineOrders {
					myGroup.enter()
					let productsArray = order.offlineProduct?.allObjects
					self.addAllProductsToCart(withProductsArray: productsArray as [AnyObject]?, withSuccessHandler: { (success) in
						if success {
							if let orderParam = order.offlineOrder {
								SyncManager.syncOperation(operationType: .placeOrder, info: orderParam, completionHandler: { (response, error) in
									
									if error == nil {
										print("Response : \(response)")
										if let response = response as? [String: AnyObject] {
											if let successMessage = response["success"] as? String {
												print("Order Placed Status : \(successMessage)")
												
												MagicalRecord.save({ (context) in
													let localContext = order.mr_(in: context)
													localContext?.mr_deleteEntity()
												})
											}
										}
									} else {
										print("Error: \(error)")
									}
								})
							}
						}
					})
				}
			}
		}
		
		func addAllProductsToCart(withProductsArray products: [AnyObject]? , withSuccessHandler successHandler: SuccessHandler? = nil) {
			let myGroup = DispatchGroup()
			if let productsData = products as? [OfflineProducts] {
				
				for offlineProduct in productsData {
					myGroup.enter()
					if let product = Product.getProductWith(productId: offlineProduct.productId!) {
                   self.uploadIndividualMyCartData(withProductId: product.productId, withQuantity: offlineProduct.quantity, withHandler: { (success, cartId) in
							if success {
								 print("Cart Id: \(cartId)")
							}
						})
						myGroup.leave()
					}
				}
				myGroup.notify(queue: .main, execute: {
					successHandler?(true)
				})
			}
		}
	}
	
	
	
	
