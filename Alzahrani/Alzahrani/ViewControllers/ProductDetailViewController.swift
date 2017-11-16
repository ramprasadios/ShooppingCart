//
//  ProductDetailViewController.swift
//  Alzahrani
//
//  Created by Ashok Kumar on 09/05/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

struct ProductSpecification {
	let title: String?
	let details: String?
	
	init(withTitle titleStr: String, andDetails detailsStr: String) {
		self.title = titleStr
		self.details = detailsStr
	}
}

struct CartQuantity {
	static let minimumQuantity = 1
	static var currentQuantity = 1
}

struct ProductData {
	let productName: String?
	let productDescription: String?
	let productCode: String?
	let price: String?
	let productImage: String?
	let isInCart: Bool?
	let isProductLiked: Bool?
	let productId: String?
	let productSpecialPrice: String?
	let availability: String?
	let arName: String?
	let arDescription: String?
	
	init(withName name: String?, withProductId id: String?, andDescription desc: String?, _ productCode: String?, _ price: String?, prodImage image: String?, _ isInCart: Bool?, _ isProductLiked: Bool?, specialPrice sPrice: String? = "0", availability: String?, _ arName: String?, _ arDescription: String?) {
		self.productName = name
		self.productDescription = desc
		self.productCode = productCode
		self.price = price
		self.productImage = image
		self.isInCart = isInCart
		self.isProductLiked = isProductLiked
		self.productId = id
		self.productSpecialPrice = sPrice
		self.availability = availability
		self.arDescription = arDescription
		self.arName = arName
	}
}

class ProductDetailViewController: UIViewController {
	var currentProduct: ProductData?
	var currentProdId: String?
	var categoryId: String?
	var fromScreenType: FromScreenType = .home
	
	
	@IBOutlet weak var pageControl: UIPageControl!
	@IBOutlet weak var multipleImageCollectionView: UICollectionView!
	@IBOutlet weak var specificationsLabel: UILabel!
	@IBOutlet weak var star5ImageView: UIImageView!
	@IBOutlet weak var star1ImageView: UIImageView!
	
	@IBOutlet weak var start2ImageView: UIImageView!
	
	@IBOutlet weak var star4ImageView: UIImageView!
	@IBOutlet weak var star3ImageView: UIImageView!
	@IBOutlet weak var outOfStockEngImageView: UIImageView!
	
	@IBOutlet weak var outOfStockArabicImageView: UIImageView!
	@IBOutlet weak var soldQuantity: UILabel!
	@IBOutlet weak var reviewsButton: UIButton!
	
	@IBOutlet weak var viewMoreButton: UIButton!
	@IBOutlet weak var containerViewHeightContraint: NSLayoutConstraint!
	@IBOutlet weak var productSpecificationTableView: UITableView!
	@IBOutlet weak var quantityTextFiled: UITextField!
	@IBOutlet var starsImageView: [UIImageView]!
	@IBOutlet weak var coupanCodeTextField: UITextField!
	@IBOutlet weak var soldCountLabel: UILabel!
	@IBOutlet weak var availabilityLabel: UILabel!
	
	@IBOutlet weak var productDescription: UILabel!
	@IBOutlet weak var offerPercentageLabel: UILabel!
	@IBOutlet weak var productOriginalPriceLabel: UILabel!
	@IBOutlet weak var productPriceLabel: UILabel!
	@IBOutlet weak var productTitleLabel: UILabel!
	@IBOutlet weak var productImagesView: ImageScrollView!
	@IBOutlet weak var plusButton: UIButton!
	@IBOutlet weak var substractButton: UIButton!
	@IBOutlet weak var productImageView: UIImageView!
	@IBOutlet weak var productCode: UILabel!
	
	@IBOutlet weak var myCartButton: UIButton!
	@IBOutlet weak var myWishListButton: UIButton!
	
	@IBOutlet weak var brandNameTitleLabel: UILabel!
	@IBOutlet weak var brandNameLabel: UILabel!
	
	var actualContainerViewHeight: CGFloat = 0.0
	var currentProductId: String = ""
	var noSpecificationViewHeigt: CGFloat = 600.0
	var specificationsData = [ProductSpecification]()
	var currentProductInfo = [String: AnyObject]()
	var currentProductRating: String = ""
	var productImages = [String]()
	fileprivate let imageTag = 123456
	var fullScreenImageView: UIImageView!
	var closeLabel: UILabel!
	var productInfo: Product?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		//setupView()
		self.offlineProductData()
		self.getProductDetails()
		self.handleUIElementsLanguage()
		self.setNavBarTitle()
		self.actualContainerViewHeight = containerViewHeightContraint.constant
		self.downloadProductSpecifications()
		self.setProductDetail()
		self.registerCellNibs()
		self.setupCollectionView()
		self.myCartButton.setTitle(NSLocalizedString("ADD TO CART", comment: ""), for: .normal)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.setNavigationBarImage()
		self.setInitalProductInfo()
		self.handleWishListData()
		handleCartData()
		self.removeNavigationBarImage()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	@IBAction func decrementQuantity(_ sender: Any) {
		if  CartQuantity.currentQuantity >= CartQuantity.minimumQuantity {
			CartQuantity.currentQuantity -= 1
			quantityTextFiled.text =  "\(CartQuantity.currentQuantity)"
		}
	}
	
	@IBAction func reviewsButtonTapped(_ sender: Any) {
		
		if AppManager.currentApplicationMode() == .online {
			self.navigationController?.tabBarController?.tabBar.isHidden = true
			let reviewVC = self.storyboard?.instantiateViewController(withIdentifier: "ReviewViewController") as! ReviewViewController
			reviewVC.reviewDelegate = self
			if AppManager.currentApplicationMode() == .online {
				if let productId = self.currentProductInfo["product_id"] as? String {
					reviewVC.produtID = productId
					reviewVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
					self.present(reviewVC, animated: true, completion: nil)
				}
			} else {
				if let productId = (self.productInfo?.productId) {
					reviewVC.produtID = productId
					reviewVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
					self.present(reviewVC, animated: true, completion: nil)
				}
			}
		} else {
			 ALAlerts.showToast(message: NSLocalizedString("Available only in online mode", comment: ""))
		}
	}
	
	@IBAction func incrementQuantity(_ sender: Any) {
		CartQuantity.currentQuantity += 1
		quantityTextFiled.text =  "\( CartQuantity.currentQuantity)"
	}
	
	
	@IBAction func addToCartButtonTapped(_ sender: Any) {
		myCartButton.isEnabled = false
		var cartlistInfo = [String: AnyObject]()
		var produQty = 0
		let userDefaults = UserDefaultManager.sharedManager()
		let customerGroupId = userDefaults.customerGroupId
		
		let cust_grop_id1 = NSLocalizedString("Customer_Group_Id1", comment: "")
		let cust_grop_id2 = NSLocalizedString("Customer_Group_Id2", comment: "")
		
		if AppManager.currentApplicationMode() == .online {
			if let productAvailability = Int((self.currentProductInfo["quantity"] as! String)) {
				produQty = productAvailability
			}
		} else {
			if let product = Product.getProductWith(productId: self.currentProdId!) {
				let productAvailability = Int(product.availability)
			   produQty = productAvailability
			}
		}
		
		if AppManager.currentApplicationMode() == .online {
			print("uploadIndividualMyCartData");
			if (produQty > 0 || customerGroupId==cust_grop_id1||customerGroupId==cust_grop_id2){
				
				if let name = self.currentProductInfo["name"] as? String, let productId = self.currentProductInfo["product_id"] as? String {
					print("prime name--:\(name)");
					cartlistInfo["name"] = name as AnyObject?
					cartlistInfo["product_id"] = productId as AnyObject?
					
					if ((AppManager.isUserLoggedIn) && (!self.checkProducIsInCart(withProdId: productId))) {
						UploadTaskHandler.sharedInstance.uploadIndividualMyCartData(withProductId: productId, withHandler: { (success, cartId) in
							if success {
								print("cartId==\(cartId)");
								
								cartlistInfo["cart_id"] = cartId as AnyObject?
								let _ = MyCart.addProductToMyCartList(data: cartlistInfo)
								self.handleCartData()
							}
							self.myCartButton.isEnabled = true
						})
						//self.handleCartData()
					} else {
						let cartProduct = MyCart.getProductWith(productId: productId)
						if let cartId = cartProduct?.cartId {
							UploadTaskHandler.sharedInstance.deleteMyCartData(withProductId: productId, cartId, withHandler: { (success) in
								if success {
									if let cartProdId = cartProduct?.productId {
										let _ = MyCart.removeProduct(withId: cartProdId)
									}
									ALAlerts.showToast(message: NSLocalizedString("ITEM_REMOVED_FROM_CART", comment: ""))
									self.handleCartData()
									
								} else {
									ALAlerts.showToast(message: NSLocalizedString("ITEM_NOT_REMOVED_FROM_CART", comment: ""))
								}
								self.myCartButton.isEnabled = true
							})
						} else {
							self.myCartButton.isEnabled = true
						}
						
						var cartObjInfo = [String: AnyObject]()
						cartObjInfo["removedProduct"] = cartProduct?.productId as AnyObject?
						
						NotificationCenter.default.post(name: Notification.Name("MyCartUpdateNotification"), object: cartObjInfo)
						
					}
				}
			}
		} else {
			
			var cartListInfo = [String: AnyObject]()
			if AppManager.isUserLoggedIn {
				if let cartProd = self.productInfo {
					cartListInfo["name"] = cartProd.productName as AnyObject?
					cartListInfo["product_id"] = cartProd.productId as AnyObject?
					cartListInfo["quantity"] = 1 as AnyObject?
					cartListInfo["total"] = cartProd.price as AnyObject?
					cartListInfo["price"] = cartProd.price as AnyObject?
					if AppManager.isUserLoggedIn && (!self.checkProducIsInCart(withProdId: (productInfo?.productId)!)) {
						let _ = MyCart.addProductToMyCartList(data: cartListInfo)
						ALAlerts.showToast(message: NSLocalizedString("ITEM_ADDED_TO_CART", comment: ""))
						self.myCartButton.isEnabled = true
					} else {
						if let cartProdId = cartProd.productId {
							let _ = MyCart.removeProduct(withId: cartProdId)
							self.myCartButton.isEnabled = true
						}
					}
					self.handleCartData()
				}
			} else {
				self.showAlertWith(warningMsg: "Please, Login to Continue")
			}
		}
	}
	
	@IBAction func addToWishListButtonTapped(_ sender: Any) {
		var wishListInfo = [String: AnyObject]()
		if AppManager.currentApplicationMode() == .online {
			if let name = self.currentProductInfo["name"] as? String, let productId = self.currentProductInfo["product_id"] as? String {
				wishListInfo["name"] = name as AnyObject?
				wishListInfo["product_id"] = productId as AnyObject?
				if ((AppManager.isUserLoggedIn) && (!self.checkProductIsLiked(withProdId: productId))) {
					
					UploadTaskHandler.sharedInstance.uploadIndividualWishList(withProductId: productId, withHandler: { (success) in
						if success {
							let _ = WishLists.addProductToWishList(data: wishListInfo)
							self.handleWishListData()
							ALAlerts.showToast(message: NSLocalizedString("ITEM_ADDED_TO_WISHLIST", comment: ""))
							self.myWishListButton.isEnabled = true
							
						} else {
							ALAlerts.showToast(message: NSLocalizedString("ITEM_NOT_ADDED_TO_WISHLIST", comment: ""))
							self.myWishListButton.isEnabled = true
						}
					})
					
				} else {
					if let wishListProd = WishLists.getProductWith(productId: productId) {
						
						if let cartProdId = wishListProd.productId {
							let _ = WishLists.removeProduct(withId: cartProdId)
							
							UploadTaskHandler.sharedInstance.deleteWishListData(withProductId: cartProdId, withHandler: { (success) in
								if success {
									let _ = WishLists.removeProduct(withId: cartProdId)
									ALAlerts.showToast(message: NSLocalizedString("ITEM_REMOVED_FROM_WISHLIST", comment: ""))
									self.handleWishListData()
									self.myWishListButton.isEnabled = true
									
									var wishListObjInfo = [String: AnyObject]()
									
									wishListObjInfo["removedProduct"] = productId as AnyObject?
									NotificationCenter.default.post(name: Notification.Name("WishListUpdateNotification"), object: wishListObjInfo)
								}
							})
						}
					}
				}
			}
		} else {
			let wishListProduct = self.productInfo
			print("Adding \(wishListProduct?.productName) to wishlist")
			if let productId = wishListProduct?.productId {
				if !self.checkProductIsLiked(withProdId: productId) {
					self.addProductToWishlist(withProductInfo: wishListProduct!)
					ALAlerts.showToast(message: NSLocalizedString("ITEM_ADDED_TO_WISHLIST", comment: ""))
				} else {
					self.removeProductFromWishlist(withProductInfo: wishListProduct!)
					ALAlerts.showToast(message: NSLocalizedString("ITEM_REMOVED_FROM_WISHLIST", comment: ""))
				}
			}
		}
	}
	
	@IBAction func shareButtonTapped(_ sender: Any) {
		self.handleProductSharing()
	}
	
	@IBAction func viewMoreButtonTapped(_ sender: Any) {
		if let productSpecVc = self.storyboard?.instantiateViewController(withIdentifier: ProductSpecifactionsViewController.selfName()) as? ProductSpecifactionsViewController {
			productSpecVc.specificationInfo = self.specificationsData
			
			self.navigationController?.pushViewController(productSpecVc, animated: true)
		}
	}
	
	func showDetailedProductSpecification() {
		if let productSpecVc = self.storyboard?.instantiateViewController(withIdentifier: ProductSpecifactionsViewController.selfName()) as? ProductSpecifactionsViewController {
			productSpecVc.specificationInfo = self.specificationsData
			
			self.navigationController?.pushViewController(productSpecVc, animated: true)
		}
	}
}

//MARK:- Helper Methods
extension ProductDetailViewController {
	
	func setupView()
	{
		plusButton.layer.borderColor = UIColor.gray.cgColor
		substractButton.layer.borderColor = UIColor.gray.cgColor
		plusButton.layer.cornerRadius = 2
		plusButton.layer.borderWidth = 1
		plusButton.layer.masksToBounds = true
		//
		substractButton.layer.cornerRadius = 2
		substractButton.layer.borderWidth = 1
		substractButton.layer.masksToBounds = true
		
		quantityTextFiled.delegate = self
		
		quantityTextFiled.text = "\(Quantity.currentQuantity)"
		//        if self.productDescription.contentSize.height <= 90
		//        {
		//            self.productDescription.frame.size.height = self.productDescription.contentSize.height
		//        }
	}
	
	func dismissNumberPad() {
		if quantityTextFiled.isFirstResponder
		{
			quantityTextFiled.resignFirstResponder()
		}
	}
	
	func setNavBarTitle() {
		if AppManager.currentApplicationMode() == .online {
			
			if AppManager.languageType() == .arabic {
				
				if self.fromScreenType == .home {
					if let productName = self.currentProductInfo["name"] as? String {
						self.title = productName
					}
				} else {
					if let productName = self.currentProductInfo["arname"] as? String {
						self.title = productName
					}
				}
			} else {
				if let productName = self.currentProductInfo["name"] as? String {
					self.title = productName
				}
			}
		} else {
			if self.fromScreenType == .home {
				if let productName = self.productInfo?.productName {
					self.title = productName
				} else {
					self.title = "Product Detail"
				}
			} else {
				
				if let productName = (AppManager.languageType() == .arabic) ? self.productInfo?.arName : self.productInfo?.productName{
					self.title = productName
				} else {
					self.title = "Product Detail"
				}
			}
		}
	}
	
	func setProductDetail() {
		let userDefaults = UserDefaultManager.sharedManager()
		let customerGroupId = userDefaults.customerGroupId
		
		let cust_grop_id1 = NSLocalizedString("Customer_Group_Id1", comment: "")
		let cust_grop_id2 = NSLocalizedString("Customer_Group_Id2", comment: "")
		
		if AppManager.currentApplicationMode() == .online {
			
			print("Prime currentProductInfo:\(self.currentProductInfo)")
			print("Prime currentProductInfo:\(self.currentProduct)")
			var availableQty = ""
			
			if let availabilityCount = self.currentProductInfo["quantity"] as? String {
				availableQty = availabilityCount
			}
			var productAvailability: Int = 0
			if let availableCount = Int(availableQty) {
				productAvailability = availableCount
			}
			if (productAvailability > 0||customerGroupId==cust_grop_id1||customerGroupId==cust_grop_id2 ) {
				//                self.availabilityLabel.text = productAvailability.description
				self.availabilityLabel.text = NSLocalizedString("Available", comment: "")
				self.availabilityLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
			} else {
				self.availabilityLabel.text = NSLocalizedString("Out of stock", comment: "")
				
				myCartButton.isEnabled = false
				myCartButton.alpha = 0.7
				
				self.availabilityLabel.textColor = UIColor.red
				self.availabilityLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
			}
			
			if let reviewsCount = currentProductInfo["reviews"] as? String {
				let reviewsStr = reviewsCount + " " + NSLocalizedString("REVIEWS", comment: "")
				self.reviewsButton.setTitle(reviewsStr, for: .normal)
				self.reviewsButton.setTitle(reviewsStr, for: .highlighted)
			} else {
				let reviewsStr = "0" + " " + NSLocalizedString("REVIEWS", comment: "")
				self.reviewsButton.setTitle(reviewsStr, for: .normal)
				self.reviewsButton.setTitle(reviewsStr, for: .highlighted)
			}
			
			if let soldQty = currentProductInfo["sold_quantity"] as? String {
				self.soldQuantity.text = soldQty + " " + NSLocalizedString("Product(s) Sold", comment: "")
			} else {
				self.soldQuantity.text = "0" + " " + "Product(s) Sold"
			}
			
			if let specialPrice = currentProductInfo["special"] as? String {
				if specialPrice != "" {
					
					if let price = Double(self.currentProductInfo["price"] as? String ?? "") {
						let roundedPrice = String(format: "%.2f", price)
						let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: roundedPrice + " " + "SAR")
						attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))
						attributeString.addAttribute(NSStrikethroughColorAttributeName, value: UIColor(red:164/255,green:41/255,blue:63/255,alpha:1), range: NSMakeRange(0, attributeString.length))
						self.productOriginalPriceLabel.attributedText = attributeString
					}
					
					if let price = Double(specialPrice) {
						let roundedPrice = String(format: "%.2f", price)
						self.productPriceLabel.text = roundedPrice + " " + "SAR"
					}
					//self.productPriceLabel.text = specialPrice
				} else {
					self.productOriginalPriceLabel.text = ""
					if let price = Double((self.currentProductInfo["price"] as? String ?? "")) {
						let roundedPrice = String(format: "%.2f", price)
						self.productPriceLabel.text = roundedPrice + " " + "SAR"
					}
					//                self.productPriceLabel.text = currentProduct?.price
				}
			} else {
				
				//offline case
				self.productOriginalPriceLabel.text = ""
				if let price = Double((self.currentProductInfo["price"] as? String ?? "")) {
					let roundedPrice = String(format: "%.2f", price)
					self.productPriceLabel.text = roundedPrice + " " + "SAR"
				}
			}
			
			if AppManager.languageType() == .arabic {
				
				if self.fromScreenType == .home {
					if let description = self.currentProductInfo["description"] as? String {
						let normalDescText = description.htmlToString
						self.productDescription.text = normalDescText
					}
					self.productTitleLabel.text = (self.currentProductInfo["name"] as? String ?? "")
				} else {
					if let description = self.currentProductInfo["ardescription"] as? String {
						let normalDescText = description.htmlToString
						self.productDescription.text = normalDescText
					}
					self.productTitleLabel.text = (self.currentProductInfo["arname"] as? String ?? "")
				}
				
				/* self.productDescription.text = (self.currentProductInfo["ardescription"] as? String ?? "")  */
				
				self.myCartButton.setTitle(NSLocalizedString("ADD TO CART", comment: ""), for: .normal)
			} else {
				if let description = self.currentProductInfo["description"] as? String {
					let normalDescText = description.htmlToString
					self.productDescription.text = normalDescText
				}
				/* self.productDescription.text = (self.currentProductInfo["description"] as? String ?? "")  */
				self.productTitleLabel.text = (self.currentProductInfo["name"] as? String ?? "")
			}
			self.productCode.text = (self.currentProductInfo["sku"] as? String ?? "")
			print("prime 1:\(self.currentProductInfo["image"])")
			//            self.downloadProductImage(withURL: (self.currentProductInfo["image"] as? String ?? ""))
			self.productImages.append(self.currentProductInfo["image"] as? String ?? "")
			self.calculateOfferPercentage()
			
			if let productRating = self.currentProductInfo["rating"] as? Int {
				self.setProductRating(withRatingCount: productRating.description)
			}
			
			if let brandName = self.currentProductInfo["manufacturer"] as? String {
				self.brandNameTitleLabel.text = NSLocalizedString("BRAND_NAME", comment: "")
				self.brandNameLabel.text = brandName
			}
			
		} else {
			self.brandNameTitleLabel.isHidden = true
			self.brandNameLabel.isHidden = true
			self.calculateOfferPercentage()
			if let productId = self.currentProdId {
				if let product = Product.getProductWith(productId: productId) {
					if product.availability > 0 || (AppManager.getLoggedInUserType() == .salesExecutive) {
						self.availabilityLabel.text = NSLocalizedString("Available", comment: "")
						self.availabilityLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
					} else {
						self.availabilityLabel.text = NSLocalizedString("Out of stock", comment: "")
//						if AppManager.languageType() == .english {
//							self.availabilityLabel.text = product.stockStatus
//						} else {
//							self.availabilityLabel.text = product.arStockStatus
//						}
						
						myCartButton.isEnabled = false
						myCartButton.alpha = 0.7
						
						self.availabilityLabel.textColor = UIColor.red
						self.availabilityLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
					}
					
					if let reviewsCount = product.reviews {
						let reviewsStr = reviewsCount + " " + NSLocalizedString("REVIEWS", comment: "")
						self.reviewsButton.setTitle(reviewsStr, for: .normal)
						self.reviewsButton.setTitle(reviewsStr, for: .highlighted)
					} else {
						let reviewsStr = "0" + " " + NSLocalizedString("REVIEWS", comment: "")
						self.reviewsButton.setTitle(reviewsStr, for: .normal)
						self.reviewsButton.setTitle(reviewsStr, for: .highlighted)
					}
					
					if let soldQty = product.soldQuantity {
						self.soldQuantity.text = soldQty + " " + NSLocalizedString("Product(s) Sold", comment: "")
					} else {
						self.soldQuantity.text = "0" + " " + NSLocalizedString("Product(s) Sold", comment: "")
					}
					
					if let specialPrice = product.specialPrice {
						if specialPrice != "" {
							
							let price = Double(product.price)
							let roundedPrice = String(format: "%.2f", price)
							let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: roundedPrice + " " + "SAR")
							attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))
							attributeString.addAttribute(NSStrikethroughColorAttributeName, value: UIColor(red:164/255,green:41/255,blue:63/255,alpha:1), range: NSMakeRange(0, attributeString.length))
							self.productOriginalPriceLabel.attributedText = attributeString
							
							if let price = Double(specialPrice) {
								let roundedPrice = String(format: "%.2f", price)
								self.productPriceLabel.text = roundedPrice + " " + "SAR"
							}
						} else {
							self.productOriginalPriceLabel.text = ""
							let price = product.price
							let roundedPrice = String(format: "%.2f", price)
							self.productPriceLabel.text = roundedPrice + " " + "SAR"
						}
					} else {
						self.productOriginalPriceLabel.text = ""
						let price = product.price
						let roundedPrice = String(format: "%.2f", price)
						self.productPriceLabel.text = roundedPrice + " " + "SAR"
					}
					
					if self.fromScreenType == .home {
						
						let normalDescText = product.productDescription
						self.productDescription.text = normalDescText?.htmlToString
						self.productTitleLabel.text = product.productName
						
					} else {
						if AppManager.languageType() == .arabic {
							self.productDescription.text = product.arDescription
							self.productTitleLabel.text = product.arName
						} else {
							self.productDescription.text = product.productDescription
							self.productTitleLabel.text = product.productName
						}
					}
					
					self.productCode.text = product.model
					print("prime 2:\(product.image)")
				}
			}
		}
	}
	
	func setProductRating(withRatingCount rating: String) {
		if rating == "1"{
			self.star1ImageView.image = UIImage(named:"star_icon_yellow")
		}
		if rating == "2"{
			self.star1ImageView.image = UIImage(named:"star_icon_yellow")
			self.start2ImageView.image = UIImage(named:"star_icon_yellow")
		}
		if rating == "3"{
			self.star1ImageView.image = UIImage(named:"star_icon_yellow")
			self.start2ImageView.image = UIImage(named:"star_icon_yellow")
			self.star3ImageView.image = UIImage(named:"star_icon_yellow")
		}
		if rating == "4"{
			self.star1ImageView.image = UIImage(named:"star_icon_yellow")
			self.start2ImageView.image = UIImage(named:"star_icon_yellow")
			self.star3ImageView.image = UIImage(named:"star_icon_yellow")
			self.star4ImageView.image = UIImage(named:"star_icon_yellow")
		}
		if rating == "5"{
			self.star1ImageView.image = UIImage(named:"star_icon_yellow")
			self.start2ImageView.image = UIImage(named:"star_icon_yellow")
			self.star3ImageView.image = UIImage(named:"star_icon_yellow")
			self.star4ImageView.image = UIImage(named:"star_icon_yellow")
			self.star5ImageView.image = UIImage(named:"star_icon_yellow")
		}
		
	}
	
	func calculateOfferPercentage() {
		
		if AppManager.currentApplicationMode() == .online {
			if let specialPrice = self.currentProductInfo["special"] as? String, let price = self.currentProductInfo["price"] as? String {
				self.offerPercentageLabel.isHidden = false
				if let actualPrice = Float(price), let specialPrice = Float(specialPrice) {
					let difference = actualPrice - specialPrice
					if difference > 0 {
						let percentageDiscount = ((difference / actualPrice) * 100)
						let finalValue = Int(round(percentageDiscount))
						self.offerPercentageLabel.text = "-" + finalValue.description + "%"
					}
				}
			} else {
				self.offerPercentageLabel.isHidden = true
			}
		} else {
			if let offerPrice = currentProduct?.productSpecialPrice {
				if offerPrice != "" {
					self.offerPercentageLabel.isHidden = false
					if let product = currentProduct {
						let actualPrice = Float(product.price!)
						let specialPrice = Float(product.productSpecialPrice!)
							let difference = actualPrice! - specialPrice!
							let percentageDiscount = ((difference / actualPrice!) * 100)
							let finalValue = Int(percentageDiscount)
							self.offerPercentageLabel.text = finalValue.description + "%" + " " + NSLocalizedString("Off", comment: "")
					}
				} else {
					self.offerPercentageLabel.isHidden = true
				}
			}
		}
	}
	
	func getProductDetails() {
		var productId: String = ""
		var custGrpId: String = ""
		if AppManager.currentApplicationMode() == .online {
			
			if let productIdStr = self.currentProductInfo["product_id"] as? String {
				productId = productIdStr
			}
		} else {
			productId = self.currentProdId!
		}
		if let customerGrpId = UserDefaultManager.sharedManager().customerGroupId {
			custGrpId = customerGrpId
		}
		let syncFormat = "&product_id=\(productId)&customer_group_id=\(custGrpId)"
		SyncManager.syncOperation(operationType: .getProductDetail, info: syncFormat) { (response, error) in
			if error == nil {
				if let response = response as? [[String: AnyObject]] {
					if let productInfo = response.first {
						if let productMultipleImage = productInfo["product_images"] as? [[String: AnyObject]] {
							for imageUrl in productMultipleImage {
								if let imageURLStr = imageUrl["image"] as? String {
									self.productImages.append(imageURLStr)
								}
							}
							if self.productImages.count > 1 {
								self.pageControl.isHidden = false
							} else {
								self.pageControl.isHidden = true
							}
							self.multipleImageCollectionView.reloadData()
						}
					}
				}
			}
		}
	}
	
	func offlineProductData() {
		if AppManager.currentApplicationMode() == .offline {
			if let product = Product.getProductWith(productId: self.currentProdId!) {
				self.productInfo = product
			}
		}
	}
	
	func downloadProductSpecifications() {
		if AppManager.currentApplicationMode() == .online {
			var languageId = ""
			if let languageType = AppManager.languageType() {
				switch languageType {
				case .arabic:
					languageId = "2"
				case .english:
					languageId = "1"
				}
			}
			var productId: String?
			if AppManager.currentApplicationMode() == .online {
				
				if let productIdStr = self.currentProductInfo["product_id"] as? String {
					productId = productIdStr
				}
			} else {
				productId = self.currentProdId
			}
			if let porductId = productId {
				let syncFormat = "&product_id=\(porductId)&language_id=\(languageId)"
				//ProgressIndicatorController.showLoading()
				SyncManager.syncOperation(operationType: .productSpecification, info: syncFormat) { (response, error) in
					if error == nil {
						//ProgressIndicatorController.dismissProgressView()
						if let specificationsList = response as? [[String: AnyObject]] {
							for specification in specificationsList {
								
								if let title = specification["text"] as? String, let details = specification["name"] as? String {
									let specificationData = ProductSpecification(withTitle: title, andDetails: details)
									self.specificationsData.append(specificationData)
								}
							}
							DispatchQueue.main.async {
								self.productSpecificationTableView.reloadData()
							}
						}
						if self.specificationsData.count > 0 {
							self.specificationsLabel.isHidden = false
							//						self.viewMoreButton.isHidden = false
							self.containerViewHeightContraint.constant = self.actualContainerViewHeight
						} else {
							//						self.viewMoreButton.isHidden = true
							self.specificationsLabel.isHidden = true
							self.containerViewHeightContraint.constant = self.noSpecificationViewHeigt
						}
					} else {
						//ProgressIndicatorController.dismissProgressView()
						self.containerViewHeightContraint.constant = self.noSpecificationViewHeigt
					}
				}
			}
		} else {
			if let productId = self.currentProdId {
				if let product = Product.getProductWith(productId: productId) {
					if let specifications = product.specifications?.allObjects {
						for specification in specifications {
							if let spec = specification as? Specifications {
								if AppManager.languageType() == .english {
									if let title = spec.detail, let details = spec.title {
										let specificationData = ProductSpecification(withTitle: title, andDetails: details)
										self.specificationsData.append(specificationData)
									}
								} else {
									if let title = spec.arDetail, let details = spec.arTitle {
										let specificationData = ProductSpecification(withTitle: title, andDetails: details)
										self.specificationsData.append(specificationData)
									}
								}
							}
						}
						
						DispatchQueue.main.async {
							self.productSpecificationTableView.reloadData()
						}
					}
					if self.specificationsData.count > 0 {
						self.specificationsLabel.isHidden = false
						//						self.viewMoreButton.isHidden = false
						self.containerViewHeightContraint.constant = self.actualContainerViewHeight
					} else {
						//						self.viewMoreButton.isHidden = true
						self.specificationsLabel.isHidden = true
						self.containerViewHeightContraint.constant = self.noSpecificationViewHeigt
					}
				} else {
					//ProgressIndicatorController.dismissProgressView()
					self.containerViewHeightContraint.constant = self.noSpecificationViewHeigt
				}
			}
		}
		
	}
	
	func setInitalProductInfo() {
		if let currentProduct = currentProduct {
			if currentProduct.isProductLiked! {
				if let heartRedImage = UIImage(named: "wishList_red") {
					self.myWishListButton.setImage(heartRedImage, for: .normal)
					self.myWishListButton.setImage(heartRedImage, for: .highlighted)
				}
			}
			if currentProduct.isInCart! {
				self.myCartButton.setTitle("IN CART", for: .normal)
				self.myCartButton.setTitle("IN CART", for: .highlighted)
			}
		}
		
	}
	
	func downloadProductImage(withURL url: String?) {
		print("image download---")
		if let imageURL = url {
			let prorperURL = imageURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
			print("image download prorperURL:\(prorperURL)")
			SyncManager.syncOperation(operationType: .imageDownloadOperation, info: prorperURL,
			                          completionHandler: { (imageData, error) in
												if error == nil {
													DispatchQueue.main.async {
														let resizedImage = Toucan(image: UIImage(data: imageData as! Data)!).resize(self.productImageView.frame.size, fitMode: .scale).image
														self.productImageView.image = resizedImage
													}
												}
			})
		}
	}
	
	func downloadMutipleProductImage(atCell cell: MultipleProductImageCustomCell, withURL url: String?) {
		print("image download---")
		if let imageURL = url {
			let prorperURL = imageURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
			print("image download prorperURL:\(prorperURL)")
			SyncManager.syncOperation(operationType: .imageDownloadOperation, info: prorperURL,
			                          completionHandler: { (imageData, error) in
												if error == nil {
													DispatchQueue.main.async {
														let resizedImage = Toucan(image: UIImage(data: imageData as! Data)!).resize(self.productImageView.frame.size, fitMode: .scale).image
														self.productImageView.image = resizedImage
													}
												}
			})
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
	
	func handleCartData() {
		
		var myCartInfo = [String: AnyObject]()
		if AppManager.currentApplicationMode() == .online {
			if let productId = self.currentProductInfo["product_id"] as? String {
				if self.checkProducIsInCart(withProdId: productId) {
					
					//let _ = MyCart.addProductToMyCartList(data: myCartInfo)
					self.myCartButton.setTitle("IN CART", for: .normal)
					self.myCartButton.setTitle("IN CART", for: .highlighted)
					
					var cartObjInfo = [String: AnyObject]()
					cartObjInfo["AddCartProd"] = self.currentProductInfo["product_id"] as AnyObject?
					
					NotificationCenter.default.post(name: Notification.Name("CartAddNotification"), object: cartObjInfo)
					
				} else {
					
					self.myCartButton.setTitle(NSLocalizedString("ADD TO CART", comment: ""), for: .normal)
					self.myCartButton.setTitle(NSLocalizedString("ADD TO CART", comment: ""), for: .highlighted)
					
					NotificationCenter.default.post(name: Notification.Name("MyCartUpdateNotification"), object: nil)
				}
			}
			
		} else {
			
			if let info = self.productInfo {
				if let id = info.productId, let _ = info.image, let name = info.productName, let image = info.image {
					myCartInfo["name"] = name as AnyObject?
					myCartInfo["product_id"] = id as AnyObject?
					myCartInfo["image"] = image as AnyObject?
					myCartInfo["price"] = info.price as AnyObject?
					myCartInfo["quantity"] = 1 as AnyObject?
					
					//wishlist_prod_icon
					if checkProducIsInCart(withProdId: id) {
						
						//let _ = MyCart.addProductToMyCartList(data: myCartInfo)
						self.myCartButton.setTitle("IN CART", for: .normal)
						self.myCartButton.setTitle("IN CART", for: .highlighted)
						
						NotificationCenter.default.post(name: Notification.Name("MyCartUpdateNotification"), object: nil)
					} else {
						self.myCartButton.setTitle(NSLocalizedString("ADD TO CART", comment: ""), for: .normal)
						self.myCartButton.setTitle(NSLocalizedString("ADD TO CART", comment: ""), for: .highlighted)
						
						NotificationCenter.default.post(name: Notification.Name("MyCartUpdateNotification"), object: nil)
					}
				}
			}
		}
	}
	
	func handleWishListData() {
		var wishListInfo = [String: AnyObject]()
		
		if AppManager.currentApplicationMode() == .online {
			if let productId = self.currentProductInfo["product_id"] as? String {
				if self.checkProductIsLiked(withProdId: productId) {
					if let heartRedImage = UIImage(named: "wishList_red") {
						self.myWishListButton.setImage(heartRedImage, for: .normal)
						self.myWishListButton.setImage(heartRedImage, for: .highlighted)
						
						var wishListObjInfo = [String: AnyObject]()
						wishListObjInfo["AddWishlistProd"] = self.currentProductInfo["product_id"] as AnyObject?
						
						NotificationCenter.default.post(name: Notification.Name("WishListAddNotification"), object: wishListObjInfo)
					}
				} else {
					if let heartRedImage = UIImage(named: "wishlist_prod_icon") {
						self.myWishListButton.setImage(heartRedImage, for: .normal)
						self.myWishListButton.setImage(heartRedImage, for: .highlighted)
						
						NotificationCenter.default.post(name: Notification.Name("WishListUpdateNotification"), object: nil)
					}
				}
			}
		} else {
			if let info = self.productInfo {
				if let id = info.productId, let image = info.image, let name = info.productName {
					wishListInfo["name"] = name as AnyObject?
					wishListInfo["product_id"] = id as AnyObject?
					wishListInfo["image"] = image as AnyObject?
					wishListInfo["price"] = info.price as AnyObject?
					
					//wishlist_prod_icon
					
					if self.checkProductIsLiked(withProdId: id) {
						if let heartRedImage = UIImage(named: "wishList_red") {
							self.myWishListButton.setImage(heartRedImage, for: .normal)
							self.myWishListButton.setImage(heartRedImage, for: .highlighted)
							
							NotificationCenter.default.post(name: Notification.Name("WishListUpdateNotification"), object: nil)
						}
					} else {
						if let heartRedImage = UIImage(named: "wishlist_prod_icon") {
							self.myWishListButton.setImage(heartRedImage, for: .normal)
							self.myWishListButton.setImage(heartRedImage, for: .highlighted)
							
							NotificationCenter.default.post(name: Notification.Name("WishListUpdateNotification"), object: nil)
						}
					}
				}
			}
		}
	}
	
	func removeNavigationBarImage() {
		self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
	}
	
	func handleProductSharing() {
		var produURL = ""
		let text = "Checkout what I found on Alzahrani"
		if AppManager.currentApplicationMode() == .online {
			var productImageData: UIImage?
			
			if let info = self.currentProduct {
				if let productName = info.productName, let productDescription = info.productDescription, let productImage = info.productImage, let productId = info.productId {
					produURL = "https://alzahrani-online.com/index.php?route=product/product&product_id=\(productId)"
					let prorperURL = productImage.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
					SyncManager.syncOperation(operationType: .imageDownloadOperation, info: prorperURL
						,
					                          completionHandler: { (imageData, error) in
												if error == nil {
													DispatchQueue.main.async {
														productImageData = UIImage(data: imageData as! Data)!
														// set up activity view controller
														let textToShare = [text, productName, productDescription, productImageData ?? UIImage(), " ", produURL] as [Any]
														let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
														activityViewController.popoverPresentationController?.sourceView = self.view
														
														self.present(activityViewController, animated: true, completion: nil)
													}
												}
					})
				}
			}
		} else {
			let wishListProduct = self.productInfo
			
			if let info = wishListProduct {
				if let productName = info.productName, let productDescription = info.productDescription, let productImage = info.imageData, let productId = info.productId {
					produURL = "https://alzahrani-online.com/index.php?route=product/product&product_id=\(productId)"
					
					let textToShare = [text, productName, productDescription, productImage, " ", produURL] as [Any]
					let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
					activityViewController.popoverPresentationController?.sourceView = self.view
					
					self.present(activityViewController, animated: true, completion: nil)
				}
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
	
	func setNavigationBarImage() {
		self.navigationController?.navigationBar.setBackgroundImage(nil, for: .top, barMetrics: .default)
	}
	
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		let pageWidth = self.multipleImageCollectionView.frame.size.width
		let currentPage = self.multipleImageCollectionView.contentOffset.x / pageWidth
		
		if (0.0 != fmodf(Float(currentPage), 1.0)) {
			pageControl.currentPage = Int(currentPage) + 1
		} else {
			pageControl.currentPage = Int(currentPage)
		}
	}
	
	func downloadProductInfo(notification: Notification) {
		
	}
}

extension ProductDetailViewController: UITextFieldDelegate {
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
	func textFieldDidBeginEditing(_ textField: UITextField) {
		if textField == quantityTextFiled
		{
			let toolBar = UIToolbar()
			toolBar.barStyle = UIBarStyle.blackTranslucent
			toolBar.sizeToFit()
			let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(ProductDetailViewController.dismissNumberPad))
			toolBar.setItems([doneButton], animated: true)
			quantityTextFiled.inputAccessoryView = toolBar
		}
	}
}

extension ProductDetailViewController {
	
	func handleUIElementsLanguage() {
		let languageId = (AppManager.languageType() == .arabic) ? "2" : "1"
		if languageId == "1" {
//			self.viewMoreButton.setTitle(NSLocalizedString("VIEW_MORE", comment: ""), for: .normal)
//			self.reviewsButton.setTitle(NSLocalizedString("REVIEWS", comment: ""), for: .normal)
//			self.specificationsLabel.text = NSLocalizedString("SPECIFICATION", comment: "")
		}
	}
	
	func registerCellNibs() {
		self.productSpecificationTableView.estimatedRowHeight = 44.0
		self.productSpecificationTableView.rowHeight = UITableViewAutomaticDimension
		
		let cellNib = UINib(nibName: SpecificationsTableViewCell.selfName(), bundle: nil)
		self.productSpecificationTableView.register(cellNib, forCellReuseIdentifier: SpecificationsTableViewCell.selfName())
		let sectionNib = UINib(nibName: ProductSpecificationHeaderView.selfName(), bundle: nil)
		self.productSpecificationTableView.register(sectionNib, forHeaderFooterViewReuseIdentifier: ProductSpecificationHeaderView.selfName())
	}
}

extension ProductDetailViewController: UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.specificationsData.count
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: SpecificationsTableViewCell.selfName(), for: indexPath) as? SpecificationsTableViewCell
		cell?.contentView.backgroundColor = UIColor.white
		if (self.specificationsData.count > 0) {
			cell?.specificationTitle.text = self.specificationsData[indexPath.row].details ?? ""
			cell?.specificationDetail.text = self.specificationsData[indexPath.row].title ?? ""
		}
		
		if UIDevice.current.userInterfaceIdiom == .pad {
			cell?.specificationTitle.font = UIFont.systemFont(ofSize: 20.0)
			cell?.specificationDetail.font = UIFont.systemFont(ofSize: 20.0)
		} else {
			cell?.specificationTitle.font = UIFont.systemFont(ofSize: 14.0)
			cell?.specificationDetail.font = UIFont.systemFont(ofSize: 14.0)
		}
		cell?.selectionStyle = .none
		return cell!
	}
}

extension ProductDetailViewController: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let sectionView = tableView.dequeueReusableHeaderFooterView(withIdentifier: ProductSpecificationHeaderView.selfName()) as? ProductSpecificationHeaderView
		return sectionView
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 0.0
	}
	
//	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//		self.showDetailedProductSpecification()
//	}
	
//	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//		
//		if UIDevice.current.userInterfaceIdiom == .pad {
//			return 50.0
//		} else {
//			return 30.0
//		}
//	}
}

extension ProductDetailViewController: ReviewHandlerDelegate {
	
	func didFinishReviewProduct() {
		self.navigationController?.tabBarController?.tabBar.isHidden = false
	}
}

//MARK:- Multiple Image Scroll Helper:
extension ProductDetailViewController {
	
	func setupCollectionView() {
		let nib = UINib(nibName: "MultipleProductImageCustomCell", bundle: nil)
		self.multipleImageCollectionView.register(nib, forCellWithReuseIdentifier: "MultipleProductImageCustomCell")
		self.multipleImageCollectionView.dataSource = self
		self.multipleImageCollectionView.delegate = self
	}
}

//MARK:- UICollectionViewDataSource
extension ProductDetailViewController: UICollectionViewDataSource {
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if AppManager.currentApplicationMode() == .online {
			 return productImages.count
		} else {
			return 1
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MultipleProductImageCustomCell", for: indexPath) as? MultipleProductImageCustomCell
		
		self.pageControl.numberOfPages = self.productImages.count
		//self.pageControl.currentPage = indexPath.row
		if AppManager.currentApplicationMode() == .online {
			let imageURL = self.productImages[indexPath.row]
			let prorperURL = imageURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
			let imageURLStr = URLBuilder.getImageDownloadBaseURL() + prorperURL!
			UploadTaskHandler.sharedInstance.setImage(onImageView: (cell?.productImageView)!, withImageUrl: imageURLStr, placeHolderImage: nil)
		} else {
			if let product = Product.getProductWith(productId: self.currentProdId!) {
				if let productImageData = product.imageData as? Data {
					if let productImage = UIImage(data: productImageData) {
						cell?.productImageView.image = productImage
					}
				}
			}
		}
		
		return cell!
	}
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		//        self.pageControl.currentPage = indexPath.row
	}
}

extension ProductDetailViewController: UICollectionViewDelegate {
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if let cell = self.multipleImageCollectionView.cellForItem(at: indexPath) as? MultipleProductImageCustomCell {
			if AppManager.currentApplicationMode() == .online {
				if let fullScreenVc = self.storyboard?.instantiateViewController(withIdentifier: FullScreenImageViewController.selfName()) as? FullScreenImageViewController {
					let transition = CATransition()
					transition.duration = 0.8
					transition.type = kCATransition
					transition.subtype = kCATransitionFade
					self.view.window?.layer.add(transition, forKey: kCATransition)
					fullScreenVc.productImages = self.productImages
					self.present(fullScreenVc, animated: true, completion: nil)
				}
			} else {
				if let fullScreenVc = self.storyboard?.instantiateViewController(withIdentifier: FullScreenImageViewController.selfName()) as? FullScreenImageViewController {
					let transition = CATransition()
					transition.duration = 0.8
					transition.type = kCATransition
					transition.subtype = kCATransitionFade
					self.view.window?.layer.add(transition, forKey: kCATransition)
					if let product = Product.getProductWith(productId: self.currentProdId!) {
						if let productImageData = product.imageData as? Data {
							fullScreenVc.imageData = productImageData
						}
					}
					self.present(fullScreenVc, animated: true, completion: nil)
				}
			}
		}
	}
}

//MARK:- UICollectionViewDelegateFlowLayout
extension ProductDetailViewController: UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		print("Item selected at .....")
		return CGSize(width: self.multipleImageCollectionView.frame.size.width - 10.0, height: self.multipleImageCollectionView.frame.size.height - 10.0)
	}
}

//MARK:- Image Display Handlers
extension ProductDetailViewController {
	
	func showFullScreen(withImage image: UIImage) {
		
		let window = UIApplication.shared.windows.first!
		if window.viewWithTag(imageTag) == nil {
			self.fullScreenImageView = self.createFullScreenImageView(withImage: image)
			self.closeLabel = self.createLabel()
			
			window.addSubview(self.fullScreenImageView)
			UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseInOut, animations: {
				
				self.fullScreenImageView.frame = window.frame
				self.fullScreenImageView.alpha = 1
				self.fullScreenImageView.layoutSubviews()
				
				self.closeLabel.alpha = 1
			}, completion: { _ in
			})
		}
		
	}
	
	fileprivate func createLabel() -> UILabel {
		
		let label = UILabel(frame: CGRect.zero)
		label.text = "Close"
		label.font = UIFont(name: "HelveticaNeue", size: 12.0)
		label.sizeToFit()
		label.textAlignment = NSTextAlignment.center
		label.textColor = UIColor(white: 0.85, alpha: 1)
		label.backgroundColor = UIColor.black.withAlphaComponent(0.8)
		label.alpha = 0.0
		
		return label
	}
	
	func createFullScreenImageView(withImage image: UIImage) -> UIImageView {
		
		let tmpImageView = UIImageView(frame: self.view.frame)
		tmpImageView.image = image
		tmpImageView.contentMode = UIViewContentMode.scaleAspectFit
		tmpImageView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
		tmpImageView.tag = imageTag
		tmpImageView.alpha = 0.0
		tmpImageView.isUserInteractionEnabled = true
		
		let tap = UITapGestureRecognizer(target: self, action: #selector(hideFullscreen))
		tmpImageView.addGestureRecognizer(tap)
		
		return tmpImageView
	}
	
	func hideFullscreen() {
		
		UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseInOut, animations: {
			
			self.fullScreenImageView?.frame = self.view.frame
			self.fullScreenImageView?.alpha = 0
			
		}, completion: { finished in
			
			self.fullScreenImageView?.removeFromSuperview()
			self.fullScreenImageView = nil
		})
	}
}


extension ProductDetailViewController {
	
	func addProductToWishlist(withProductInfo info: Product) {
		
		var wishListInfo = [String: AnyObject]()
		
		if let info = self.productInfo {
			if let id = info.productId, let image = info.image, let name = info.productName {
				wishListInfo["name"] = name as AnyObject?
				wishListInfo["product_id"] = id as AnyObject?
				wishListInfo["image"] = image as AnyObject?
				wishListInfo["price"] = info.price as AnyObject?
				
				//wishlist_prod_icon
				
				let _ = WishLists.addProductToWishList(data: wishListInfo)
				if let heartRedImage = UIImage(named: "wishList_red") {
					self.myWishListButton.setImage(heartRedImage, for: .normal)
					self.myWishListButton.setImage(heartRedImage, for: .highlighted)
					
					NotificationCenter.default.post(name: Notification.Name("WishListUpdateNotification"), object: nil)
				}
			}
		}
	}
	
	func removeProductFromWishlist(withProductInfo info: Product) {
		if let id = info.productId {
			let _ = WishLists.removeProduct(withId: id)
			if let heartRedImage = UIImage(named: "wishlist_prod_icon") {
				self.myWishListButton.setImage(heartRedImage, for: .normal)
				self.myWishListButton.setImage(heartRedImage, for: .highlighted)
				
				NotificationCenter.default.post(name: Notification.Name("WishListUpdateNotification"), object: nil)
			}
		}
	}
}
