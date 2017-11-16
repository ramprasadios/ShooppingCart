//
//  CartViewController.swift
//  Alzahrani
//
//  Created by Ramprasad A on 12/05/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit
import CoreData
import QuartzCore
import MagicalRecord

enum CouponApplyType {
    case apply
    case refresh
}

struct CartProductData {
    var name: String?
    var quantity: String?
    var unitPrice: String?
    var totalPrice: String?
    var shippingCharges: String?
	var productId: String
    
	init(withName name: String, andQuantity qty: String, unitPrice price: String, totalPrice totPrice: String, withShipping shippingCharges: String? = "", withProductId id: String) {
        self.name = name
        self.quantity = qty
        self.unitPrice = price
        self.totalPrice = totPrice
		self.productId = id
    }
}

struct Quantity{
    static let minimumQuantity = 1
    static var currentQuantity = 1
}

class CartViewController: UIViewController {
    
    //NO Cart:
    @IBOutlet weak var noCartImageView: UIImageView!
    @IBOutlet weak var noCartLabel: UILabel!
    @IBOutlet weak var noCartButton: UIButton!
    
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var continueShoppingButton: UIButton!
    @IBOutlet weak var cartTableView: UITableView!
    @IBOutlet weak var totalQuantityLabel: PaddingLabel!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var totalPriceLabel: PaddingLabel!
    @IBOutlet weak var priceView: UIView!
    @IBOutlet weak var checkoutButton: UIButton!
    @IBOutlet weak var totalLabel: PaddingLabel!
    
    var myCartListFRC: NSFetchedResultsController<NSFetchRequestResult>?
    var shippingCharges: String?
    var _cartAmount: String? = "0"
    var totalCartPrice: String? {
        get {
            return self._cartAmount
        } set {
            self._cartAmount = newValue
        }
    }
    var tableViewNeedsAnimation: Bool = true
    var userAddressData = [UserAddressData]()
    var cartTotalPrice: String = ""
    var couponApplySuccess: Bool = false
    var priceFieldsArray: [String] = []
    var calcFieldsArray: [String] = []
    var isCouponSectionOpen: Bool = false
    var currentSection: IndexPath?
    var currentUsedCouponCode: String = ""
    var isNoDataShown: Bool = false
    
    //MARK:- Cart Price:
    var subTotalPrice: Int = 0
    var couponDiscount: Int = 0
    var finalPrice: Int = 0
    var couponName: String = ""
    
    fileprivate var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>? {
        return getFetchResultController()
    }
    var myCartData = [CartProductData]()
    
    //MARK:- Life cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.leftBarButtonItem?.tintColor = .white
        self.setupTableView()
        self.registerNibs()
        self.addNotificationObservers()
        //downloadUserExistingAddress()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setInitialUI()
        self.couponName = ""
        self.couponDiscount = 0
        self.couponApplySuccess = false
        self.isCouponSectionOpen = false
        self.downloadMyCartData()
        self.myCartData = []
        self.setTabBarBadge()
        self.setInitialUIText()
        
        //self.calculateTotalPrice()
//        self.totalPriceLabel.text = self.calculateTotalPrice() + " " + "SAR"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.cartTableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupFields()
    }
    
    @IBAction func showUserMenu(_ sender: UIBarButtonItem) {
        NotificationCenter.default.post(name: Notification.Name(Constants.hambergerTappedNotification), object: nil)
    }
    
    @IBAction func continueShoppingTapped(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name(Constants.sliderMenuFieldTapNotification), object: nil, userInfo: nil)
    }
    
    
    @IBAction func noCartButtonTapped(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name(Constants.sliderMenuFieldTapNotification), object: nil, userInfo: nil)
    }
    
    @IBAction func checkoutButtonTapped(_ sender: Any) {
		
		if AppManager.currentApplicationMode() == .online {
			self.getMyCartList()
			if self.myCartData.count == 0 {
				self.showAlertWith(warningMsg: "Please add Product before checkout")
			} else {
				let productDetailVc = self.storyboard?.instantiateViewController(withIdentifier: "OrderCheckoutPageViewController") as! OrderCheckoutPageViewController
				
				productDetailVc.cartAddedData = myCartData
				productDetailVc.userExistingAddressData = self.userAddressData
				productDetailVc.couponCodeInfo = self.getCouponDetails()
				self.navigationController?.pushViewController(productDetailVc, animated: true)
			}
		} else {
			if let offlineOrders = Orders.getAllOrdersData() {
				if offlineOrders.count >= 1 {
					let orderLimitAlert = NSLocalizedString("ORDER_LIMIT_ALERT", comment: "")
					ALAlerts.showToast(message: NSLocalizedString(orderLimitAlert, comment: ""))
				} else {
					self.getMyCartList()
					if self.myCartData.count == 0 {
						self.showAlertWith(warningMsg: "Please add Product before checkout")
					} else {
						let productDetailVc = self.storyboard?.instantiateViewController(withIdentifier: "OrderCheckoutPageViewController") as! OrderCheckoutPageViewController
						
						productDetailVc.cartAddedData = myCartData
						productDetailVc.userExistingAddressData = self.userAddressData
						productDetailVc.couponCodeInfo = self.getCouponDetails()
						self.navigationController?.pushViewController(productDetailVc, animated: true)
					}
				}
			}
		}
    }
}

//MARK:- Initial Setup:
extension CartViewController {
    
    func setTabBarBadge() {
        if let cartCount = MyCart.mr_findAll()?.count, cartCount != 0 {
            self.tabBarController?.tabBar.items?[3].badgeValue = cartCount.description
        }
    }
    
    func calculateTotalPrice() -> String {
        var totalPrice: Int? = 0
        if let myCartObjects = MyCart.getAllMyCartlist() {
            for product in myCartObjects {
                if let price = product.totalPrice {
                    if let priceValue = Int(price) {
                        totalPrice = totalPrice! + priceValue
                    }
                }
            }
        }
        return totalPrice!.description
    }
    
	func calculateUnitTotalPrice(ofProduct product: MyCart, withQty qty: Int16) -> String {
        var totalPrice: Int? = 0
        if let price = Int(product.price!) {
            let priceValue = price * Int(qty)
            totalPrice = totalPrice! + priceValue
        }
        
        return totalPrice!.description
    }
	
    func showAlertWith(warningMsg msg: String) {
        let alertController = UIAlertController(title: Constants.alertTitle, message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
            NotificationCenter.default.post(name: Notification.Name(Constants.sliderMenuFieldTapNotification), object: nil)
        })
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showRefreshAlert(withMsg msg: String) {
        let alertController = UIAlertController(title: Constants.alertTitle, message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: Constants.alertAction, style: .default, handler: nil)
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func setupTableView()
    {
        self.cartTableView.rowHeight = UITableViewAutomaticDimension
        self.cartTableView.estimatedRowHeight = 165.0
        
        let nib = UINib(nibName: "ProductTableViewCell", bundle: nil)
        self.cartTableView.register(nib, forCellReuseIdentifier: "ProductTableViewCell")
        cartTableView.dataSource = self
        cartTableView.delegate = self
    }
    
    func setInitialUIText() {
        self.continueShoppingButton.setTitle(NSLocalizedString("Continue Shopping", comment: ""), for: .normal)
        self.checkoutButton.setTitle(NSLocalizedString("CheckOut", comment: ""), for: .normal)
    }
    
    func registerNibs() {
        
        let applyCouponNib = UINib(nibName: CouponCodeApplyTableViewCell.selfName(), bundle: nil)
        self.cartTableView.register(applyCouponNib, forCellReuseIdentifier: CouponCodeApplyTableViewCell.selfName())
        
        let applyCouponSectionNib = UINib(nibName: CouponCodeTableViewSection.selfName(), bundle: nil)
        self.cartTableView.register(applyCouponSectionNib, forHeaderFooterViewReuseIdentifier: CouponCodeTableViewSection.selfName())
        
        let checkoutCartNib = UINib(nibName: CheckOutCartTableViewCell.selfName(), bundle: nil)
        self.cartTableView.register(checkoutCartNib, forCellReuseIdentifier: CheckOutCartTableViewCell.selfName())
        
        let finalCellNib = UINib(nibName: FinalPriceTableViewCell.selfName(), bundle: nil)
        self.cartTableView.register(finalCellNib, forCellReuseIdentifier: FinalPriceTableViewCell.selfName())
        
        let normalTextCellNib = UINib(nibName: NoramlFieldLabelTableViewCell.selfName(), bundle: nil)
        self.cartTableView.register(normalTextCellNib, forCellReuseIdentifier: NoramlFieldLabelTableViewCell.selfName())
        
        let priceFieldsCellNib = UINib(nibName: FinalPriceTableViewCell.selfName(), bundle: nil)
        self.cartTableView.register(priceFieldsCellNib, forCellReuseIdentifier: FinalPriceTableViewCell.selfName())
    }
    
    func addNotificationObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(CartViewController.keyBoardWillShow),
                                               name: .UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(CartViewController.keyBoardWillCollapse),
                                               name: .UIKeyboardWillHide, object: nil)
    }
    
    func downloadUserExistingAddress() {
        if let currentUserId = UserDefaultManager.sharedManager().loginUserId {
            SyncManager.syncOperation(operationType: .getUserExistingAddress, info: currentUserId) { (response, error) in
                if error == nil {
                    if let responseData = response as? [[String: AnyObject]] {
                        for addressObj in responseData {
                            for key in addressObj.keys {
                                if let addressData = addressObj[key] as? [String: AnyObject] {
                                    let userAddress = UserAddressData(customerId: AppManager.getCustId(), AppManager.getCustGroupId(), addressData["firstname"] as? String ?? "", addressData["lastname"] as? String ?? "", addressData["company"] as? String ?? "", "", addressData["address_1"] as? String ?? "", addressData["address_2"] as? String ?? "", addressData["city"] as? String ?? "", addressData["postcode"] as? String ?? "", addressData["country"] as? String ?? "", addressData["country_id"] as? String ?? "", addressData["zone"] as? String ?? "", addressData["zone_id"] as? String ?? "", "")
                                    
                                    self.userAddressData.append(userAddress)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    func setupFields() {
//        continueShoppingButton.layer.cornerRadius = 5
//        // continueShoppingButton.layer.masksToBounds = true
//        continueShoppingButton.layer.shadowColor = UIColor.lightGray.cgColor
//        continueShoppingButton.layer.shadowOpacity = 0.5
//        continueShoppingButton.layer.shadowOffset = CGSize(width:2,height:2)
//        continueShoppingButton.layer.shadowRadius = 3
        //checkoutButton.layer.cornerRadius = 5
        
//        totalPriceLabel.layer.cornerRadius = 5
//        totalPriceLabel.layer.shadowColor = UIColor.lightGray.cgColor
//        
//        totalPriceLabel.layer.shadowOpacity = 1
//        totalPriceLabel.layer.shadowOffset = CGSize(width:0,height:2)
//        totalPriceLabel.layer.shadowRadius = 2
//        totalPriceLabel.layer.masksToBounds = false
//        totalPriceLabel.layer.shouldRasterize = true
//        totalPriceLabel.leftInset = 10
        //
//        totalLabel.layer.cornerRadius = 5
//        totalLabel.layer.shadowColor = UIColor.lightGray.cgColor
//        
//        totalLabel.layer.shadowOpacity = 1
//        totalLabel.layer.shadowOffset = CGSize(width:0,height:2)
//        totalLabel.layer.shadowRadius = 2
//        totalLabel.layer.masksToBounds = false
//        totalLabel.layer.shouldRasterize = true
//        totalLabel.leftInset = 10
    }
}


//MARK:- Helper Methods
extension CartViewController {
    
    func getCouponDetails() -> [String: AnyObject] {
        var couponObject = [String: AnyObject]()
        couponObject["CouponName"] = self.couponName as AnyObject?
        couponObject["CouponAmount"] = self.couponDiscount as AnyObject?
        
        return couponObject
    }
    
    func getMyCartList() {
        
        if let cartData = self.fetchedResultsController?.fetchedObjects as? [MyCart] {
            for cartItem in cartData {
                if let name = cartItem.productName, let unitPriceVal = cartItem.price, let qty = cartItem.productsCount, let productId = cartItem.productId {
                    var totalProductPrice = ""
                    if let prodQty = Int(qty), let unitPrice = Int(unitPriceVal) {
                        totalProductPrice = (prodQty * unitPrice).description
                    }
                    
                    if AppManager.currentApplicationMode() == .online {
                        if let prodPrice = cartItem.price {
									let cartData = CartProductData(withName: name, andQuantity: qty, unitPrice: prodPrice, totalPrice: totalProductPrice, withShipping: self.shippingCharges, withProductId: productId)
                            self.myCartData.append(cartData)
                        }
                    } else {
                        if let product = Product.getProductWith(productId: cartItem.productId!) {
                            let cartData = CartProductData(withName: name, andQuantity: qty, unitPrice: product.price.description, totalPrice: totalProductPrice, withShipping: self.shippingCharges, withProductId: productId)
                            self.myCartData.append(cartData)
                        }
                    }
                }
            }
        }
    }
    
    func downloadImageForCells(cell: ProductTableViewCell?, withIndexPath indexPath: IndexPath) {
        if let currentCartProduct = self.fetchedResultsController?.fetchedObjects?[indexPath.row] as? MyCart {
            if let imageURL = currentCartProduct.productImage {
                let prorperURL = imageURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                let imageURLStr = URLBuilder.getImageDownloadBaseURL() + prorperURL!
                let url = URL(string: imageURLStr)
                cell?.productImageView.af_setImage(withURL: url!, placeholderImage: nil, filter: nil, imageTransition: .crossDissolve(0.5), runImageTransitionIfCached: true, completion: nil)
            }
        }
    }
    
    func updateFetchRequest() {
        if self.tableViewNeedsAnimation {
            self.myCartListFRC = MyCart.mr_fetchAllSorted(by: nil,
                                                          ascending: true,
                                                          with: nil,
                                                          groupBy: nil,
                                                          delegate: self)
        } else {
            self.myCartListFRC = MyCart.mr_fetchAllSorted(by: nil,
                                                          ascending: true,
                                                          with: nil,
                                                          groupBy: nil,
                                                          delegate: nil)
        }
    }
    
    func getFetchResultController() -> NSFetchedResultsController<NSFetchRequestResult>? {
        return myCartListFRC
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
						
						ProgressIndicatorController.showLoading()
						SyncManager.syncOperation(operationType: .getAllCartData, info: syncDataFormat, completionHandler: { (response, error) in
							ProgressIndicatorController.dismissProgressView()
							if error == nil {
								print("Response MyCart: \(response)")
								//                            if let cartTotalPrice = response.first["cart_total"] as? Int {
								//                                self.cartTotalPrice = cartTotalPrice.description
								//                            }
								if let myCartResponse = response as? [[String: AnyObject]] {
									if let subTotalData = myCartResponse.first?["cart_total"] as? Int {
										self.subTotalPrice = subTotalData
									}
									self.handleResponseData(data: myCartResponse)
									//                                self.totalPriceLabel.text = self.calculateTotalPrice() + " " + "SAR"
									NotificationCenter.default.post(name: Notification.Name("MyCartUpdateNotification"), object: nil)
								}
								DispatchQueue.main.async {
									self.updateFetchRequest()
									self.cartTableView.reloadData()
									if !self.isNoDataShown {
										self.showNoData()
									}
								}
							}
						})
					}
				} else {
					//Fetch All From Local DB
					self.updateFetchRequest()
					self.cartTableView.reloadData()
					self.showNoData()
				}
			} else {
				//Fetch All From Local DB
				self.updateFetchRequest()
				self.cartTableView.reloadData()
				self.showNoData()
			}
		} else {
			self.updateFetchRequest()
			self.cartTableView.reloadData()
			self.showNoData()
		}
		
    }
	
    func handleResponseData(data: [[String: AnyObject]]) {
		
        let responseData = data.first
        if let shippingInfo = responseData?["shipping"] {
            print("Shipping Info \(shippingInfo)")
            if shippingInfo is NSNull {
                self.shippingCharges = "0"
            } else {
                self.shippingCharges = shippingInfo.description
            }
        }
    }
	
    func handleWishListData(withProduct product: MyCart?, atCell cell: ProductTableViewCell) {
        var wishListInfo = [String: AnyObject]()
        if let info = product {
			if AppManager.currentApplicationMode() == .online {
				if let id = info.productId, let _ = info.productImage, let name = info.productName, let image = info.productImage, let price = info.price {
					wishListInfo["name"] = name as AnyObject?
					wishListInfo["product_id"] = id as AnyObject?
					wishListInfo["image"] = image as AnyObject?
					wishListInfo["price"] = price as AnyObject?
					
					//wishlist_prod_icon
					
					if self.checkProductIsLiked(withProdId: id) {
						let _ = WishLists.removeProduct(withId: id)
						cell.addwishList.setTitle("Add Wishlist", for: .normal)
						cell.addwishList.setTitle("Add Wishlist", for: .normal)
					}
				}
			} else {
				
				if let id = info.productId, let name = info.productName, let price = info.price {
					wishListInfo["name"] = name as AnyObject?
					wishListInfo["product_id"] = id as AnyObject?
					wishListInfo["price"] = price as AnyObject?
					
					//wishlist_prod_icon
//					if self.checkProductIsLiked(withProdId: id) {
//						let _ = WishLists.removeProduct(withId: id)
//						cell.addwishList.setTitle("Add Wishlist", for: .normal)
//						cell.addwishList.setTitle("Add Wishlist", for: .normal)
//					}
				}
			}
        }
    }
	
    func deleteMyCartDataAt(withIndexPath indexPath: IndexPath) {
        self.tableViewNeedsAnimation = true
		if AppManager.currentApplicationMode() == .online {
			if let cartProduct = self.fetchedResultsController?.fetchedObjects?[indexPath.row] as? MyCart {
				UploadTaskHandler.sharedInstance.deleteMyCartData(withProductId: cartProduct.productId, cartProduct.cartId, withHandler: { (success) in
					if success {
						var cartObjInfo = [String: AnyObject]()
						cartObjInfo["removedProduct"] = cartProduct.productId as AnyObject?
						
						if let cartProdId = cartProduct.productId {
							let _ = MyCart.removeProduct(withId: cartProdId)
							NotificationCenter.default.post(name: Notification.Name("MyCartUpdateNotification"), object: cartObjInfo)
							self.downloadMyCartData()
						}
						//                    self.totalPriceLabel.text = self.calculateTotalPrice() + " " + "SAR"
					}
				})
			}
		} else {
			if let cartProduct = self.fetchedResultsController?.fetchedObjects?[indexPath.row] as? MyCart {
				var cartObjInfo = [String: AnyObject]()
				cartObjInfo["removedProduct"] = cartProduct.productId as AnyObject?
				
				if let cartProdId = cartProduct.productId {
					let _ = MyCart.removeProduct(withId: cartProdId)
					NotificationCenter.default.post(name: Notification.Name("MyCartUpdateNotification"), object: cartObjInfo)
					self.downloadMyCartData()
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
    
    func calculatePrice(withQunatity qty: Int, andPrice price: Int) -> Int {
        return qty * price
    }
    
    func handleProductIncrement(atCell cell: ProductTableViewCell) {
        if let indexPath = self.cartTableView.indexPath(for: cell) {
            if let cartProduct = self.fetchedResultsController?.fetchedObjects?[indexPath.row] as? MyCart {
                if let currentCount = Int(cartProduct.productsCount!) {
                    let currentObjCount = currentCount + 1
                    cartProduct.productsCount = currentObjCount.description
                    
                    let localMOC = cartProduct.managedObjectContext
                    localMOC?.mr_saveToPersistentStoreAndWait()
                }
            }
        }
    }
    
    func handleProductDecrement(atCell cell: ProductTableViewCell) {
        if let indexPath = self.cartTableView.indexPath(for: cell) {
            if let cartProduct = self.fetchedResultsController?.fetchedObjects?[indexPath.row] as? MyCart {
                if let currentCount = Int(cartProduct.productsCount!) {
                    let currentObjCount = currentCount - 1
                    cartProduct.productsCount = currentObjCount.description
                    
                    let localMOC = cartProduct.managedObjectContext
                    localMOC?.mr_saveToPersistentStoreAndWait()
                }
            }
        }
    }
    
    func getCustomerType() -> UserLoginType {
        if let custGrpId = UserDefaultManager.sharedManager().customerGroupId {
            if custGrpId == "1" {
                return .endUser
            } else if ((custGrpId == "15") || (custGrpId == "16")) {
                return .salesExecutive
            } else {
                return .employee
            }
        } else {
            return .endUser
        }
    }
    
    func getPriceFields() {
        if self.couponApplySuccess {
            self.calcFieldsArray = [NSLocalizedString("Sub-Total:", comment: ""), NSLocalizedString("COUPON_VALUE", comment: ""), NSLocalizedString("Total:", comment: "")]
            self.priceFieldsArray = [self.subTotalPrice.description + " SAR", "-" + self.couponDiscount.description + " SAR", self.finalPrice.description + " SAR"]
        } else {
			if AppManager.currentApplicationMode() == .online {
				self.calcFieldsArray = [NSLocalizedString("Sub-Total:", comment: ""), NSLocalizedString("Total:", comment: "")]
				self.priceFieldsArray = [self.subTotalPrice.description + " SAR", self.subTotalPrice.description + " SAR"]
			} else {
				self.calcFieldsArray = [NSLocalizedString("Sub-Total:", comment: ""), NSLocalizedString("Total:", comment: "")]
				self.priceFieldsArray = [self.calculateTotalPrice() + " SAR", self.calculateTotalPrice() + " SAR"]
			}
        }
    }
    
    func keyBoardWillShow(notification: Notification) {
        if let keyBoardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyBoardSize.height, right: 0.0)
            
            self.cartTableView.contentInset = contentInset
            self.cartTableView.scrollIndicatorInsets = contentInset
            let indexPath = IndexPath(row: 2, section: 2)
            
            //self.cartTableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
    
    func keyBoardWillCollapse(notification: Notification) {
        self.cartTableView.contentInset = UIEdgeInsets.zero
        self.cartTableView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
    
    func applyCouponCode(withCouponCode code: String, withApplyType type: CouponApplyType) {
        let defaultManager = UserDefaultManager.sharedManager()
        var custId = ""
        var custGrpId = ""
        let languageId = (AppManager.languageType() == .arabic) ? "2" : "1"
        if let customerId = defaultManager.loginUserId, let customerGrpId = defaultManager.customerGroupId {
            custId = customerId
            custGrpId = customerGrpId
        }
        let couponSyncParameter = "coupon=\(code)&customer_id=\(custId)&customer_group_id=\(custGrpId)&language_id=\(languageId)"
        SyncManager.syncOperation(operationType: .applyCouponCode, info: couponSyncParameter) { (response, error) in
            if error == nil {
                
                if let couponResponse = response as? [String: AnyObject] {
                    if let successResponse = couponResponse["SuccessInfo"] as? String {
                        self.couponApplySuccess = true
                        self.couponName = code
                        if type == .apply {
                            self.showRefreshAlert(withMsg: successResponse)
                        }
                        
                        if let couponObject = couponResponse["CouponInfo"] as? [String: AnyObject] {
                            if let subTotalPrice = couponObject["sub_total"] as? Int, let couponAmount =  couponObject["coupon_amount"] as? Int, let finalAmount =  couponObject["final_price"] as? Int {
                                self.subTotalPrice = subTotalPrice
                                self.couponDiscount = couponAmount
                                self.finalPrice = finalAmount
                            }
                        }
                    } else {
                        self.couponApplySuccess = false
                        if let errorResponse = couponResponse["ErrorInfo"] as? String {
                            self.showRefreshAlert(withMsg: errorResponse)
                        }
                    }
                    
                }
                DispatchQueue.main.async {
                    self.cartTableView.reloadData()
                }
            } else {
                self.couponApplySuccess = false
            }
        }
    }
    
    func showNoData() {
        if let objcetsCount = MyCart.getAllMyCartlist()?.count {
            if objcetsCount == 0 {
                self.cartTableView.isHidden = true
                
                self.noCartLabel.isHidden = false
                self.noCartImageView.isHidden = false
                self.noCartButton.isHidden = false
                
                self.noCartLabel.text = NSLocalizedString("YOUR_CART_IS_EMPTY", comment: "")
                self.noCartButton.setTitle(NSLocalizedString("TAP_HERE_TO_ADD", comment: ""), for: .normal)
                self.noCartButton.setTitle(NSLocalizedString("TAP_HERE_TO_ADD", comment: ""), for: .highlighted)
                
                self.continueShoppingButton.isHidden = true
                self.checkoutButton.isHidden = true
                
                /* if let noDataVc = self.storyboard?.instantiateViewController(withIdentifier: NoDataViewController.selfName()) as? NoDataViewController {
                    noDataVc.noDataText = "Your Cart is Empty"
                    noDataVc.noDataMsgButton = "Tap here to add"
                    noDataVc.delegate = self
                    self.isNoDataShown = true
                    /* let noDataView = noDataVc.view
                     noDataView?.tag = 1111
                     self.mywishlistTableView.addSubview(noDataVc.view) */
                    
                    self.present(noDataVc, animated: true, completion: nil)
                } */
            } /* else {
             self.mywishlistTableView.viewWithTag(1111)?.removeFromSuperview()
             } */
				} else {
					self.cartTableView.isHidden = true
					
					self.noCartLabel.isHidden = false
					self.noCartImageView.isHidden = false
					self.noCartButton.isHidden = false
					
					self.noCartLabel.text = NSLocalizedString("YOUR_CART_IS_EMPTY", comment: "")
					self.noCartButton.setTitle(NSLocalizedString("TAP_HERE_TO_ADD", comment: ""), for: .normal)
					self.noCartButton.setTitle(NSLocalizedString("TAP_HERE_TO_ADD", comment: ""), for: .highlighted)
					
					self.continueShoppingButton.isHidden = true
					self.checkoutButton.isHidden = true
			}
    }
	
    func setInitialUI() {
			
        self.cartTableView.isHidden = false
			
        self.noCartLabel.isHidden = true
        self.noCartImageView.isHidden = true
        self.noCartButton.isHidden = true
        
        
        self.continueShoppingButton.isHidden = false
        self.checkoutButton.isHidden = false
    }
}

//Mark:- UITableViewDataSource
extension CartViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if self.fetchedResultsController?.sections?.count == 0 {
            return 0
        } else {
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.fetchedResultsController?.sections?[section].objects?.count ?? 0
        } else if section == 1 {
            if self.isCouponSectionOpen {
                return 2
            } else {
                return 0
            }
        } else if section == 2 {
            if self.couponApplySuccess {
                return 3
            } else {
                return 2
            }
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductTableViewCell") as! ProductTableViewCell
            cell.selectionStyle = .none
            cell.cartDelegate = self
            cell.removeProduct.isEnabled = true
            if let cartObjectInfo = self.fetchedResultsController?.fetchedObjects?[indexPath.row] as? MyCart {
                
                cell.originalPriceLabel.text = ""
					
					if AppManager.currentApplicationMode() == .online {
						
						if let imageURL = cartObjectInfo.productImage {
							let prorperURL = imageURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
							let imageURLStr = prorperURL!
							if AppManager.currentApplicationMode() == .online {
						  UploadTaskHandler.sharedInstance.setImage(onImageView: (cell.productImageView)!, withImageUrl: imageURLStr, placeHolderImage: nil)
							}
						}
						
						if let productPrice = cartObjectInfo.totalPrice {
							if let price = Double(productPrice) {
								let roundedPrice = String(format: "%.2f", price)
								cell.offerPriceLabel.text = roundedPrice + " " + "SAR"
							}
						}
						cell.quantityTextField.text = cartObjectInfo.productsCount
						cell.productNameLabel.text = cartObjectInfo.productName
						
					} else {
						if let product = Product.getProductWith(productId: cartObjectInfo.productId!) {
							if let imageData = product.imageData {
								if let image = UIImage(data: imageData as Data) {
									cell.productImageView.image = image
								}
							} else {
								cell.productImageView.image = #imageLiteral(resourceName: "placeHolderImage")
							}
						} else {
							cell.productImageView.image = #imageLiteral(resourceName: "placeHolderImage")
						}
						
						if let productPrice = cartObjectInfo.totalPrice {
							if let price = Double(productPrice) {
								let roundedPrice = String(format: "%.2f", price)
								cell.offerPriceLabel.text = roundedPrice + " " + "SAR"
							}
						}
						cell.quantityTextField.text = cartObjectInfo.productsCount
						cell.productNameLabel.text = cartObjectInfo.productName
					}
            }
            return cell
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: NoramlFieldLabelTableViewCell.selfName(), for: indexPath) as! NoramlFieldLabelTableViewCell
                cell.normalTextLabel.text = NSLocalizedString("ENTER_YOUR_COUPON", comment: "")
                cell.normalTextLabel.textColor = UIColor.black
                cell.normalTextLabel.font = UIFont.systemFont(ofSize: 12.0)
                cell.contentView.backgroundColor = UIColor.clear
                return cell
            } else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: CouponCodeApplyTableViewCell.selfName(), for: indexPath) as! CouponCodeApplyTableViewCell
                cell.delegate = self
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "NormalCell", for: indexPath)
                return cell
            }
        } else if indexPath.section == 2 {
            self.getPriceFields()
            let cell = tableView.dequeueReusableCell(withIdentifier: FinalPriceTableViewCell.selfName(), for: indexPath) as? FinalPriceTableViewCell
            cell?.productUnitPriceLabel.text = self.calcFieldsArray[indexPath.row]
            cell?.productTotalPriceLabel.text = self.priceFieldsArray[indexPath.row]
            
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NormalCell", for: indexPath)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let sectionHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: CouponCodeTableViewSection.selfName()) as?  CouponCodeTableViewSection
        sectionHeader?.delegate = self
        return sectionHeader
    }
    
    func decreaseQuantity(sender:UIButton){
        
        let cell = self.cartTableView.cellForRow(at:IndexPath.init(row:sender.tag, section: 0)) as!  ProductTableViewCell
        let qty = Int(cell.quantityTextField.text!)
        let total = qty!  - 1
        if  total <= 1
        {
            
            cell.quantityTextField.text = "1"
        }
        else{
            cell.quantityTextField.text = String(describing:total)
        }
    }
    
    func increaseQuantity(sender:UIButton){
        print("tag",sender.tag)
        let cell = self.cartTableView.cellForRow(at:IndexPath.init(row:sender.tag, section: 0)) as! ProductTableViewCell
        let qty = Int(cell.quantityTextField.text!)
        let total = qty! + 1
        if let indexPath = self.cartTableView.indexPath(for: cell) {
            if let currentCartProduct = self.fetchedResultsController?.fetchedObjects?[indexPath.row] as? MyCart {
                UploadTaskHandler.sharedInstance.uploadIndividualMyCartData(withProductId: currentCartProduct.productId)
            }
            self.downloadMyCartData()
            //self.cartTableView.reloadData()
        }
        cell.quantityTextField.text = String(describing:total)
    }
}

//MARK:- UITableViewDelegate
extension CartViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableViewAutomaticDimension
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if ((section == 0) || (section == 2)) {
            return 0.0
        } else {
            return 44.0
        }
    }
}

//MARK:- NSFetchedResultsControllerDelegate
extension CartViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.cartTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        let tableView = self.cartTableView
        
        switch type {
        case .delete:
            if let indexPath = indexPath {
                tableView?.deleteRows(at: [indexPath], with: .none)
            }
        case .insert:
            if let newIndexPath = newIndexPath {
                if indexPath != newIndexPath {
                    tableView?.insertRows(at: [newIndexPath], with: .none)
                }
            }
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                var animation = UITableViewRowAnimation.fade
                if indexPath == newIndexPath {
                    animation = UITableViewRowAnimation.none
                    tableView?.reloadRows(at: [indexPath], with: .none)
                } else {
                    tableView?.deleteRows(at: [indexPath], with: animation)
                    tableView?.insertRows(at: [newIndexPath], with: animation)
                }
            }
        case .update:
            if let indexPath = indexPath {
                tableView?.reloadRows(at: [indexPath], with: .none)
            }
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.cartTableView.endUpdates()
    }
}

extension CartViewController: MyCartActionDelegate {
    
    func didTapDeleteButton(atCell cell: ProductTableViewCell) {
        self.tableViewNeedsAnimation = true
        let alertMessage = NSLocalizedString("Are you sure you want to remove this item?", comment: "")
        let deleteAlertController = UIAlertController(title: Constants.alertTitle, message: alertMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title: Constants.alertAction, style: .destructive) { (UIAlerAction) in
            
            if let indexPath = self.cartTableView.indexPath(for: cell) {
                if let cartProduct = self.fetchedResultsController?.fetchedObjects?[indexPath.row] as? MyCart {
						if AppManager.currentApplicationMode() == .online {
							UploadTaskHandler.sharedInstance.deleteMyCartData(withProductId: cartProduct.productId, cartProduct.cartId, withHandler: { (success) in
								if success {
									
									if self.couponApplySuccess {
										self.applyCouponCode(withCouponCode: self.currentUsedCouponCode, withApplyType: .refresh)
									}
									self.subTotalPrice = 0
									cell.removeProduct.isEnabled = true
									var cartObjInfo = [String: AnyObject]()
									cartObjInfo["removedProduct"] = cartProduct.productId as AnyObject?
									
									if let cartProdId = cartProduct.productId {
										let _ = MyCart.removeProduct(withId: cartProdId)
										NotificationCenter.default.post(name: Notification.Name("MyCartUpdateNotification"), object: cartObjInfo)
									}
									self.downloadMyCartData()
									//self.showNoData()
									//self.totalPriceLabel.text = self.calculateTotalPrice() + " " + "SAR"
								} else {
									
									cell.removeProduct.isEnabled = true
								}
							})
						} else {
							cell.removeProduct.isEnabled = true
							var cartObjInfo = [String: AnyObject]()
							cartObjInfo["removedProduct"] = cartProduct.productId as AnyObject?
							
							if let cartProdId = cartProduct.productId {
								let _ = MyCart.removeProduct(withId: cartProdId)
								NotificationCenter.default.post(name: Notification.Name("MyCartUpdateNotification"), object: cartObjInfo)
								
								self.downloadMyCartData()
							}
						}
                }
            }
        }
		
        let cancleAction = UIAlertAction(title: Constants.cancelAction, style: .default, handler: {
            (UIAlertAction) in
            cell.removeProduct.isEnabled = true
        })
        deleteAlertController.addAction(okAction)
        deleteAlertController.addAction(cancleAction)
        self.present(deleteAlertController, animated: true, completion: nil)
    }
    
    func didTapAddtoWishListButton(atCell cell: ProductTableViewCell) {
        self.tableViewNeedsAnimation = true
        var wishListInfo = [String: AnyObject]()
        if let indexPath = self.cartTableView.indexPath(for: cell) {
            if let cartProduct = self.fetchedResultsController?.fetchedObjects?[indexPath.row] as? MyCart {
                if let prodName = cartProduct.productName, let productId = cartProduct.productId {
					if AppManager.currentApplicationMode() == .online {
						wishListInfo["name"] = prodName as AnyObject?
						wishListInfo["product_id"] = productId as AnyObject?
						if ((AppManager.isUserLoggedIn) && (!self.checkProductIsLiked(withProdId: productId))) {
							UploadTaskHandler.sharedInstance.deleteMyCartData(withProductId: cartProduct.productId, cartProduct.cartId, withHandler: { (success) in
								if success {
									cell.addwishList.isEnabled = true
									UploadTaskHandler.sharedInstance.uploadIndividualWishList(withProductId: productId, withHandler: { (success) in
										if success {
											let _ = WishLists.addProductToWishList(data: wishListInfo)
											ALAlerts.showToast(message: NSLocalizedString("Item Moved to Wishlist.", comment: ""))
											cell.addwishList.isEnabled = true
											
										} else {
											ALAlerts.showToast(message: NSLocalizedString("Item not Moved to Wishlist.", comment: ""))
											cell.addwishList.isEnabled = true
										}
										
										self.deleteMyCartDataAt(withIndexPath: indexPath)
										var cartObjInfo = [String: AnyObject]()
										cartObjInfo["removedProduct"] = cartProduct.productId as AnyObject?
										NotificationCenter.default.post(name: Notification.Name("MyCartUpdateNotification"), object: cartObjInfo)
										
										var wishListObjInfo = [String: AnyObject]()
										wishListObjInfo["AddWishlistProd"] = productId as AnyObject?
										
										NotificationCenter.default.post(name: Notification.Name("WishListAddNotification"), object: wishListObjInfo)
										
										//self.totalPriceLabel.text = self.calculateTotalPrice() + " " + "SAR"
										self.handleWishListData(withProduct: cartProduct, atCell: cell)
									})
								} else {
									cell.addwishList.isEnabled = true
								}
							})
						} else {
							UploadTaskHandler.sharedInstance.deleteMyCartData(withProductId: cartProduct.productId, cartProduct.cartId, withHandler: { (success) in
								if success {
									
									self.deleteMyCartDataAt(withIndexPath: indexPath)
									var cartObjInfo = [String: AnyObject]()
									cartObjInfo["removedProduct"] = cartProduct.productId as AnyObject?
									NotificationCenter.default.post(name: Notification.Name("MyCartUpdateNotification"), object: cartObjInfo)
									//                                self.totalPriceLabel.text = self.calculateTotalPrice() + " " + "SAR"
									self.handleWishListData(withProduct: cartProduct, atCell: cell)
									ALAlerts.showToast(message: NSLocalizedString("Already In Wishlist", comment: ""))
									cell.addwishList.isEnabled = true
									
									var wishListObjInfo = [String: AnyObject]()
									wishListObjInfo["AddWishlistProd"] = cartProduct.productId as AnyObject?
									
									NotificationCenter.default.post(name: Notification.Name("WishListAddNotification"), object: wishListObjInfo)
								}
							})
						}
					} else {
						if (!self.checkProductIsLiked(withProdId: productId)) {
							
							wishListInfo["name"] = prodName as AnyObject?
							wishListInfo["product_id"] = productId as AnyObject?
							wishListInfo["price"] = cartProduct.price as AnyObject?
							let _ = WishLists.addProductToWishList(data: wishListInfo)
							ALAlerts.showToast(message: NSLocalizedString("Item Moved to Wishlist.", comment: ""))
							cell.addwishList.isEnabled = true
							
							var wishListObjInfo = [String: AnyObject]()
							wishListObjInfo["AddWishlistProd"] = productId as AnyObject?
							self.handleWishListData(withProduct: cartProduct, atCell: cell)
							
						} else {
							
							self.handleWishListData(withProduct: cartProduct, atCell: cell)
							ALAlerts.showToast(message: NSLocalizedString("Already In Wishlist", comment: ""))
							cell.addwishList.isEnabled = true
						}
						
						self.deleteMyCartDataAt(withIndexPath: indexPath)
						var cartObjInfo = [String: AnyObject]()
						cartObjInfo["removedProduct"] = cartProduct.productId as AnyObject?
						NotificationCenter.default.post(name: Notification.Name("MyCartUpdateNotification"), object: cartObjInfo)
						
						var wishListObjInfo = [String: AnyObject]()
						wishListObjInfo["AddWishlistProd"] = cartProduct.productId as AnyObject?
						
						NotificationCenter.default.post(name: Notification.Name("WishListAddNotification"), object: wishListObjInfo)
					}
                }
            }
        }
    }
	
    func incrementProductCountTapped(atCell cell: ProductTableViewCell) {
		
        let qty = Int16(cell.quantityTextField.text!)
        self.fetchedResultsController?.delegate = nil
        var maxProdQuantity = "0"
        if let indexPath = self.cartTableView.indexPath(for: cell) {
            if let product = self.fetchedResultsController?.fetchedObjects?[indexPath.row] as? MyCart {
                if AppManager.currentApplicationMode() == .online {
                    if let maximQuantity = product.maxQuantity {
                        maxProdQuantity = maximQuantity
                    } else {
                        maxProdQuantity = "0"
                    }
                    if let maxQty = Int16(maxProdQuantity), let availability = Int16(product.quantity!) {
                        if ((maxQty >= 0) && (availability > qty!)) {
                            if maxQty < qty! {
								
                                UploadTaskHandler.sharedInstance.uploadIndividualMyCartData(withProductId: product.productId, withHandler: { (success, id) in
                                    if success {
                                        DispatchQueue.main.async {
//                                            cell.incrementQtyButton.isEnabled = true
                                            cell.quantityTextField.text = String(describing: qty! + 1)
                                            let price = self.calculatePrice(withQunatity: Int(qty! + 1), andPrice: Int(product.price!)!)
                                            cell.offerPriceLabel.text = ""
                                            cell.offerPriceLabel.text = price.description + " " +  "SAR"
//                                            self.totalPriceLabel.text = self.calculateTotalPrice() + " " + "SAR"
                                            self.tableViewNeedsAnimation = false
                                            self.downloadMyCartData()

                                            //self.handleProductIncrement(atCell: cell)
                                        }
                                    } else {
//                                        cell.incrementQtyButton.isEnabled = true
                                        cell.quantityTextField.text = String(describing: qty!)
                                        ALAlerts.showToast(message: NSLocalizedString("Please try again...!", comment: ""))
                                    }
                                })
                            }
                        } else {
//                            cell.incrementQtyButton.isEnabled = true
                            let msg = NSLocalizedString("Product not available with the current quantity", comment: "")
                            let alertController = UIAlertController(title: Constants.alertTitle, message: msg, preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertController.addAction(okAction)
                            
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                } else {
                    if let currentProduct = Product.getProductWith(productId: product.productId!) {
                        if ((currentProduct.maxQuanity >= 0) && (currentProduct.availability > qty!)) {
                            if currentProduct.maxQuanity < qty! {
                                cell.quantityTextField.text = String(describing: qty! + 1)
                                UploadTaskHandler.sharedInstance.uploadIndividualMyCartData(withProductId: currentProduct.productId)
                                //cell.offerPriceLabel.text = self.calculateUnitTotalPrice(ofProduct: product) + " " +  "SAR"
                                self.downloadMyCartData()
                            }
                        } else {
                            let msg = NSLocalizedString("Product not available with the current quantity", comment: "")
                            let alertController = UIAlertController(title: Constants.alertTitle, message: msg, preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertController.addAction(okAction)
                            
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
    
    func decrementProductCountTapped(atCell cell: ProductTableViewCell) {
        
        var qty = Int16(cell.quantityTextField.text!)
        var minProductQty = "1"
        if let indexPath = self.cartTableView.indexPath(for: cell) {
            if let product = self.fetchedResultsController?.fetchedObjects?[indexPath.row] as? MyCart {
                if AppManager.currentApplicationMode() == .online {
                    if let maximQuantity = product.minQuantity {
                        minProductQty = maximQuantity
                    } else {
                        minProductQty = "0"
                    }
                    
                    if let minQty = Int16(minProductQty) {
                        qty = qty! - 1
                        if (minQty <= qty!) {
                            cell.quantityTextField.text = String(describing: qty!)
                            
                            UploadTaskHandler.sharedInstance.uploadIndividualMyCartData(withProductId: product.productId, withSubtractQty: "0", withHandler: { (success, id) in
                                if success {
//                                    cell.decrementQtyButton.isEnabled = true
                                    cell.offerPriceLabel.text = ""
                                    let price = self.calculatePrice(withQunatity: Int(qty!), andPrice: Int(product.price!)!)
                                    cell.offerPriceLabel.text = price.description + " " +  "SAR"
//                                    self.totalPriceLabel.text = self.calculateTotalPrice() + " " + "SAR"
                                    self.downloadMyCartData()
                                } else {
//                                    cell.decrementQtyButton.isEnabled = true
                                }
                            })
                        } else {
//                            cell.decrementQtyButton.isEnabled = true
                            let msg = "Min Qty is \(qty! + 1)"
                            let alertController = UIAlertController(title: Constants.alertTitle, message: msg, preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertController.addAction(okAction)
                            
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                } else {
                    if let currentProduct = Product.getProductWith(productId: product.productId!) {
                        if ((currentProduct.maxQuanity >= 0) && (currentProduct.availability > qty!)) {
                            if currentProduct.maxQuanity < qty! {
                                cell.quantityTextField.text = String(describing: qty! - 1)
                                UploadTaskHandler.sharedInstance.uploadIndividualMyCartData(withProductId: currentProduct.productId)
                                //cell.offerPriceLabel.text = self.calculateUnitTotalPrice(ofProduct: product) + " " +  "SAR"
                                self.downloadMyCartData()
                            }
                        } else {
                            cell.quantityTextField.text = qty?.description
                            let msg = NSLocalizedString("Product not available with the current quantity", comment: "")
                            let alertController = UIAlertController(title: Constants.alertTitle, message: msg, preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertController.addAction(okAction)
                            
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
    
    func didTapRefreshButton(atCell cell: ProductTableViewCell) {
		if let enteredQuantity = cell.quantityTextField.text {
			if let qty = Int16(enteredQuantity) {
				self.fetchedResultsController?.delegate = nil
				var maxProdQuantity = "0"
				var minProdQuantity = "0"
				if let indexPath = self.cartTableView.indexPath(for: cell) {
					if let product = self.fetchedResultsController?.fetchedObjects?[indexPath.row] as? MyCart {
						if AppManager.currentApplicationMode() == .online {
							if let maximQuantity = product.maxQuantity {
								maxProdQuantity = maximQuantity
							} else {
								maxProdQuantity = "0"
							}
							if let minimumQuantity = product.minQuantity {
								minProdQuantity = minimumQuantity
							} else {
								minProdQuantity = "0"
							}
							if let maxQty = Int16(maxProdQuantity), let availability = Int16(product.quantity!), let minQty = Int16(minProdQuantity) {
								if ((availability > 0) || (self.getCustomerType() == .salesExecutive)) {
									if ((qty < maxQty) || (self.getCustomerType() == .salesExecutive) || maxQty == 0) {
										if ((qty >= minQty) || (self.getCustomerType() == .salesExecutive)) {
											
											if ((availability >= qty) || (self.getCustomerType() == .salesExecutive)) {
												UploadTaskHandler.sharedInstance.uploadIndividualMyCartData(withProductId: product.productId, withQuantity: qty.description, withHandler: { (success, id) in
													if success {
														DispatchQueue.main.async {
															
															if self.couponApplySuccess {
																self.applyCouponCode(withCouponCode: self.currentUsedCouponCode, withApplyType: .refresh)
															}
															
															cell.refreshButton.isEnabled = true
															let price = self.calculatePrice(withQunatity: Int(qty), andPrice: Int(product.price!)!)
															cell.offerPriceLabel.text = ""
															cell.offerPriceLabel.text = price.description + " " +  "SAR"
															//                                                    self.totalPriceLabel.text = self.calculateTotalPrice() + " " + "SAR"
															self.tableViewNeedsAnimation = false
															self.downloadMyCartData()
															ALAlerts.showToast(message: NSLocalizedString("Updated Successfully... !", comment: ""))
														}
													} else {
														cell.refreshButton.isEnabled = true
														cell.quantityTextField.text = String(describing: qty)
														ALAlerts.showToast(message: NSLocalizedString("Please try again...!", comment: ""))
													}
												})
											} else {
												cell.refreshButton.isEnabled = true
												cell.quantityTextField.text = "1"
												self.showRefreshAlert(withMsg: NSLocalizedString("Product not available with the current quantity", comment: ""))
											}
										} else {
											cell.refreshButton.isEnabled = true
											cell.quantityTextField.text = "1"
											self.showRefreshAlert(withMsg: NSLocalizedString("MIN_QTY_IS", comment: "") + "\(minQty)")
										}
									} else {
										cell.refreshButton.isEnabled = true
										cell.quantityTextField.text = "1"
										self.showRefreshAlert(withMsg: NSLocalizedString("YOU_CAN_ONLY_ADD", comment: "") + "\(maxQty)")
									}
								} else {
									cell.refreshButton.isEnabled = true
									cell.quantityTextField.text = "1"
									let msg = "Product currently not available"
									self.showRefreshAlert(withMsg: msg)
								}
							} else {
								cell.refreshButton.isEnabled = true
								cell.quantityTextField.text = "1"
								self.showRefreshAlert(withMsg: "Oops...! Cannot update Quantity")
							}
						} else {
							cell.refreshButton.isEnabled = true
							self.tableViewNeedsAnimation = true
							if let _ = Product.getProductWith(productId: product.productId!) {
								let subTotal = self.calculateUnitTotalPrice(ofProduct: product, withQty: qty)
								
								MagicalRecord.save({ (context) in
									let localProduct = product.mr_(in: context)
									localProduct?.productsCount = qty.description
									localProduct?.totalPrice = subTotal
									
								}, completion: { (success, error) in
									if success {
										cell.quantityTextField.text = product.productsCount
										if let productPrice = product.totalPrice {
											if let price = Double(productPrice) {
												let roundedPrice = String(format: "%.2f", price)
												cell.offerPriceLabel.text = roundedPrice + " " + "SAR"
												
												self.downloadMyCartData()
											}
										}
									}
								})
							}
						}
					}
				}
			} else {
				cell.refreshButton.isEnabled = true
				cell.quantityTextField.text = "1"
				ALAlerts.showToast(message: NSLocalizedString("Please try again...!", comment: ""))
			}
		}
    }
	
    func quantityTextFieldTapped(atCell cell: ProductTableViewCell) {
		
        let textFieldPosition = cell.quantityTextField.convert(cell.quantityTextField.bounds.origin, to: self.cartTableView)
        if let indexPath = self.cartTableView.indexPathForRow(at: textFieldPosition) {
            self.cartTableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
	
    func quantityDoneButtonTapped(atCell cell: ProductTableViewCell) {
        if let enteredQuantity = cell.quantityTextField.text {
            if enteredQuantity == "0" {
                ALAlerts.showToast(message: NSLocalizedString("Quantity cannot be Zero", comment: ""))
                cell.quantityTextField.text = "1"
            } else {
                cell.quantityTextField.text = enteredQuantity
            }
        }
    }
}

extension CartViewController: CouponHandlerDelegate {
	
    func applyCouponButtonTapped(atCell cell: CouponCodeApplyTableViewCell, withCouponCode code: String) {
        self.applyCouponCode(withCouponCode: code, withApplyType: .apply)
        self.currentUsedCouponCode = code
    }
}

extension CartViewController: CouponSectionDelegate {
	
    func didTapCouponSection() {
		if AppManager.currentApplicationMode() == .online {
			if let fetchedObjects = self.fetchedResultsController?.fetchedObjects?.count {
				if fetchedObjects > 0 {
					self.isCouponSectionOpen = !self.isCouponSectionOpen
					self.cartTableView.reloadData()
				}
			}
		}
    }
}

extension CartViewController: NoDataDisplayDelegate {
    func didTapContinueShopping() {
        self.isNoDataShown = true
    }
}
