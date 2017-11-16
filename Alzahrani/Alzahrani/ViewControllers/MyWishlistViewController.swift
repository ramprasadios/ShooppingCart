
//
//  MyWishlistViewController.swift
//  Alzahrani
//
//  Created by shilpa shree on 5/16/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit
import CoreData

struct WishListProduct {
    let productName: String
    let productPrice: String
    let prodSpecialPrice: String
    let isInCart: Bool
    let isInWihsList: Bool
    
    init(withProdName name: String, andProductPrice price: String, specaialPrice specialPrice: String, isInCart inCart: Bool, isInWishList wishList: Bool) {
        self.productName = name
        self.productPrice = price
        self.prodSpecialPrice = specialPrice
        self.isInCart = inCart
        self.isInWihsList = wishList
    }
}

class MyWishlistViewController: UIViewController {
    
    //MARK:- IB-Outlets:
    @IBOutlet weak var mywishlistTableView: UITableView!
    @IBOutlet weak var actualPriceLabel: UILabel!
    @IBOutlet weak var discountPriceLabel: UILabel!
    @IBOutlet weak var noWishlistImageView: UIImageView!
    
    @IBOutlet weak var noWishlistLabel: UILabel!
    
    @IBOutlet weak var noWishlistButton: UIButton!
    //MARK:- Properties:
    var infoLabel:UILabel!
    var wishlist = ["coffeemachine","Iron box","coffemug","tava"]
    var myWishListFRC: NSFetchedResultsController<NSFetchRequestResult>?
    
    fileprivate var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>? {
        return getFetchResultController()
    }
    
    
    //MARK:- Life Cycle:
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem?.tintColor = .white
        mywishlistTableView.delegate = self
        mywishlistTableView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setInitialUI()
        self.downloadWishlists()
        self.reloadWishListView()
        self.setTabBarBadge()
        self.removeNavigationBarImage()
//        self.mywishlistTableView.viewWithTag(1111)?.removeFromSuperview()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func showUserMenu(_ sender: UIBarButtonItem) {
        NotificationCenter.default.post(name: Notification.Name(Constants.hambergerTappedNotification), object: nil)
    }
    
    
    @IBAction func noWishlistButtonTapped(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name(Constants.sliderMenuFieldTapNotification), object: nil, userInfo: nil)
    }
}



//MARK:- Helper Methods:
extension MyWishlistViewController {
    
    func setTabBarBadge() {
        if let wishListCount = WishLists.mr_findAll()?.count, wishListCount != 0 {
            self.tabBarController?.tabBar.items?[1].badgeValue = wishListCount.description
        }
    }
    
    func removeNavigationBarImage() {
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
    }
    
    func downloadImageForCells(cell: WishlistTableViewCell?, withIndexPath indexPath: IndexPath) {
        if let currentWishListProduct = self.fetchedResultsController?.fetchedObjects?[indexPath.row] as? WishLists {
            if let imageURL = currentWishListProduct.image {
                self.downloadImage(withURL: imageURL, atCell: cell!)
            } else {
                if let currentProdImage = Product.getProductWith(productId: currentWishListProduct.productId!) {
                    self.downloadImage(withURL: currentProdImage.image!, atCell: cell!)
                } else {
                    if let currentProd = NewArrival.getNewArrivalProductWith(prodId: currentWishListProduct.productId!) {
                        self.downloadImage(withURL: currentProd.productImage!, atCell: cell!)
                    } else {
                        if let currentProd = TopSelling.getTopSellingProductWith(prodId: currentWishListProduct.productId!) {
                            self.downloadImage(withURL: currentProd.productImage!, atCell: cell!)
                        }
                    }
                }
            }
        }
    }
    
    func downloadImage(withURL url: String, atCell cell: WishlistTableViewCell) {
        let prorperURL = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        let imageURLStr = URLBuilder.getImageDownloadBaseURL() + prorperURL!
//        let url = URL(string: imageURLStr)
        
        UploadTaskHandler.sharedInstance.setImage(onImageView: (cell.wishlistImageView), withImageUrl: imageURLStr, placeHolderImage: nil)
        
//        cell.wishlistImageView.af_setImage(withURL: url!, placeholderImage: nil, filter: nil, imageTransition: .crossDissolve(0.5), runImageTransitionIfCached: true, completion: nil)
        
        }
    
    func downloadWishlists() {
		
		if AppManager.currentApplicationMode() == .online {
			if NetworkManager.sharedReachability.isReachable() {
				if AppManager.isUserLoggedIn {
					//Fetch All From Web
					
					if let customerId = UserDefaultManager.sharedManager().loginUserId {
						var url = ""
						url = URLBuilder.getAllWishLists()
						
						if let customerGroupId = UserDefaultManager.sharedManager().customerGroupId {
							let syncDataFormat = url + "&customer_id=\(customerId)&customer_group_id=\(customerGroupId)"
							ProgressIndicatorController.showLoading()
							SyncManager.syncOperation(operationType: .getAllWishLists, info: syncDataFormat, completionHandler: { (response, error) in
								
								if error == nil {
									ProgressIndicatorController.dismissProgressView()
									DispatchQueue.main.async {
										self.updateFetchRequest()
										self.mywishlistTableView.reloadData()
										self.showNoData()
									}
									
									NotificationCenter.default.post(name: Notification.Name("WishListUpdateNotification"), object: nil)
								} else {
									ProgressIndicatorController.dismissProgressView()
								}
							})
						}
						
					}
				} else {
					//Fetch All From Local DB
					//self.updateFetchRequest()
					self.mywishlistTableView.reloadData()
					self.showNoData()
				}
			} else {
				//Fetch All From Local DB
				//self.updateFetchRequest()
				self.mywishlistTableView.reloadData()
				self.showNoData()
			}
		} else {
			self.updateFetchRequest()
			self.mywishlistTableView.reloadData()
			self.showNoData()
		}

    }
	
    func handleWishListData(withProduInfo info: WishLists?, withCellInfo cell: WishlistTableViewCell, withOnlineProd product: [String: AnyObject]? = nil) {
		
        if let id = info?.productId {
			
            //wishlist_prod_icon
            if self.checkProducIsInCart(withProdId: id) {
                cell.addToCartButton.setTitle("IN CART", for: .normal)
                cell.addToCartButton.setTitle("IN CART", for: .normal)
					
                NotificationCenter.default.post(name: Notification.Name("MyCartUpdateNotification"), object: nil)
            } else {
                cell.addToCartButton.setTitle(NSLocalizedString("ADD TO CART", comment: ""), for: .normal)
                cell.addToCartButton.setTitle(NSLocalizedString("ADD TO CART", comment: ""), for: .normal)
                
                NotificationCenter.default.post(name: Notification.Name("MyCartUpdateNotification"), object: nil)
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
    
    func showNoData() {
        if let objcetsCount = self.fetchedResultsController?.fetchedObjects?.count {
            if objcetsCount == 0 {
                
                self.mywishlistTableView.isHidden = true
                
                self.noWishlistLabel.isHidden = false
                self.noWishlistImageView.isHidden = false
                self.noWishlistButton.isHidden = false
                
                self.noWishlistLabel.text = NSLocalizedString("YOUR_WISHLIST_IS_EMPTY", comment: "")
                self.noWishlistButton.setTitle(NSLocalizedString("TAP_HERE_TO_ADD", comment: ""), for: .normal)
                self.noWishlistButton.setTitle(NSLocalizedString("TAP_HERE_TO_ADD", comment: ""), for: .highlighted)
                /* if let noDataVc = self.storyboard?.instantiateViewController(withIdentifier: NoDataViewController.selfName()) as? NoDataViewController {
                    noDataVc.noDataText = "Your Wishlist is Empty"
                    noDataVc.noDataMsgButton = "Tap here to add"
                    /* let noDataView = noDataVc.view
                    noDataView?.tag = 1111
                    self.mywishlistTableView.addSubview(noDataVc.view) */
                    
                    self.present(noDataVc, animated: true, completion: nil)
                } */
            } /* else {
                self.mywishlistTableView.viewWithTag(1111)?.removeFromSuperview()
            } */
				} else {
					self.mywishlistTableView.isHidden = true
					
					self.noWishlistLabel.isHidden = false
					self.noWishlistImageView.isHidden = false
					self.noWishlistButton.isHidden = false
					
					self.noWishlistLabel.text = NSLocalizedString("YOUR_WISHLIST_IS_EMPTY", comment: "")
					self.noWishlistButton.setTitle(NSLocalizedString("TAP_HERE_TO_ADD", comment: ""), for: .normal)
					self.noWishlistButton.setTitle(NSLocalizedString("TAP_HERE_TO_ADD", comment: ""), for: .highlighted)
			}
    }
	
    func setInitialUI() {
			
        self.mywishlistTableView.isHidden = false
        
        self.noWishlistLabel.isHidden = true
        self.noWishlistImageView.isHidden = true
        self.noWishlistButton.isHidden = true
    }
    
    func continueShopping() {
        
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
}

//MARK:- UITableViewDataSource
extension MyWishlistViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.fetchedResultsController?.sections?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fetchedResultsController?.sections?[section].objects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "wishcell", for: indexPath) as? WishlistTableViewCell
        cell?.addToCartButton.isEnabled = true
        cell?.wishListDelegate = self
        if let wishListProduct = self.fetchedResultsController?.fetchedObjects?[indexPath.row] as? WishLists {
            self.handleWishListData(withProduInfo: wishListProduct, withCellInfo: cell!)
            if let productPrice = wishListProduct.price {
                if let price = Double(productPrice) {
                    let roundedPrice = String(format: "%.2f", price)
                    
                    cell?.discountPriceLabel.text = roundedPrice + " " + "SAR"
                } else {
                    cell?.discountPriceLabel.text = "0" + " " + "SAR"
                }
            }
            cell?.actualPriceLabel.text = ""
            if AppManager.languageType() == .arabic {
                cell?.ordername.text = wishListProduct.arName
            } else {
                cell?.ordername.text = wishListProduct.productName
            }
    
            if AppManager.currentApplicationMode() == .online {
                if let imageURL = wishListProduct.image {
                    self.downloadImage(withURL: imageURL, atCell: cell!)
                }
            } else {
				if let productId = wishListProduct.productId {
					if let product = Product.getProductWith(productId: productId) {
						if let imageData = product.imageData {
							if let image = UIImage(data: imageData as Data) {
								cell?.wishlistImageView.image = image
							}
						} else {
							cell?.wishlistImageView.image = #imageLiteral(resourceName: "placeHolderImage")
						}
					}
				}
				
                //self.downloadImageForCells(cell: cell, withIndexPath: indexPath)
            }
            
            if self.getCustomerType() == .salesExecutive {
                cell?.addToCartButton.isEnabled = true
				if AppManager.languageType() == .arabic {
					cell?.ordername.text = (wishListProduct.arName != nil) ? wishListProduct.arName : wishListProduct.productName
				} else {
					cell?.ordername.text = wishListProduct.productName
				}
            } else {
                if let availability = wishListProduct.availability {
                    if let availabilityCount = Int(availability) {
                        if availabilityCount > 0 {
                            cell?.addToCartButton.isEnabled = true
                        } else {
                            cell?.addToCartButton.isEnabled = false
                            cell?.addToCartButton.alpha = 0.5
                        }
                    }
                }
            }
            
            if let specialPrice = wishListProduct.specialPrice {
                
                if let price = Double(wishListProduct.price ?? "") {
                    let roundedPrice = String(format: "%.2f", price)
                    let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: roundedPrice + " " + "SAR")
                    attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))
                    attributeString.addAttribute(NSStrikethroughColorAttributeName, value: UIColor(red:164/255,green:41/255,blue:63/255,alpha:1), range: NSMakeRange(0, attributeString.length))
                    cell?.actualPriceLabel.attributedText =  attributeString
                }
                
                if let price = Double(specialPrice) {
                    let roundedPrice = String(format: "%.2f", price)
                    cell?.discountPriceLabel.text = roundedPrice + " " + "SAR"
                }
            } else {
                cell?.actualPriceLabel.text = ""
                if let price = Double(wishListProduct.price ?? "") {
                    let roundedPrice = String(format: "%.2f", price)
                    cell?.discountPriceLabel.text = roundedPrice + " " + "SAR"
                }
            }
        }
        
        
        cell?.removeButton.tag = indexPath.row
        return (cell)!
    }
}

//MARK:- UITableViewDelegate
extension MyWishlistViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if UIDevice.current.userInterfaceIdiom == .pad {
			return 200.0
		} else {
			return 140.0
		}
    }
}

//MARK:- Data Fetching Methods:
extension MyWishlistViewController {
    
    func updateFetchRequest() {
        self.myWishListFRC = WishLists.mr_fetchAllSorted(by: nil,
                                                         ascending: true,
                                                         with: nil,
                                                         groupBy: nil,
                                                         delegate: self)
    }
    
    func getFetchResultController() -> NSFetchedResultsController<NSFetchRequestResult>? {
        return myWishListFRC
    }
}

extension MyWishlistViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.mywishlistTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        let tableView = self.mywishlistTableView
        
        switch type {
        case .delete:
            if let indexPath = indexPath {
                tableView?.deleteRows(at: [indexPath], with: .fade)
            }
        case .insert:
            if let newIndexPath = newIndexPath {
                if indexPath != newIndexPath {
                    tableView?.insertRows(at: [newIndexPath], with: .fade)
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
        self.mywishlistTableView.endUpdates()
    }
}

extension MyWishlistViewController {
    
    func reloadWishListView() {
        
        DispatchQueue.main.async {
            self.mywishlistTableView.reloadData()
            //self.setupNofollowLabel()
        }
    }
    
    func setupNofollowLabel() {
        
        if self.fetchedResultsController?.fetchedObjects?.count == 0 {
            let noContentLabel = UILabel(frame: .zero)
            noContentLabel.translatesAutoresizingMaskIntoConstraints=false
            
            noContentLabel.text = NSLocalizedString("NO_CONTENT_AVAILABLE_FOR_PROGRAM", comment: "")
            
            noContentLabel.textAlignment = .center
            let constarintCenterX = NSLayoutConstraint(item:noContentLabel, attribute: NSLayoutAttribute.centerX, relatedBy: .equal, toItem: self.mywishlistTableView, attribute: .centerX, multiplier: 1.0, constant: 0)
            let constarintCenterY = NSLayoutConstraint(item:noContentLabel, attribute: NSLayoutAttribute.centerY, relatedBy: .equal, toItem: self.mywishlistTableView, attribute: .centerY, multiplier: 1.0, constant: 0)
            self.mywishlistTableView.backgroundView = noContentLabel
            self.mywishlistTableView.addConstraint(constarintCenterX)
            self.mywishlistTableView.addConstraint(constarintCenterY)
        } else {
            self.mywishlistTableView.backgroundView = nil
        }
    }
    
    func handleCartData(atCell cell: WishlistTableViewCell, withProduct product: WishLists?, withOnlineProd productInfo: [String: AnyObject]? = nil) {
        
        if AppManager.currentApplicationMode() == .online {
            if let cartProdId = productInfo?["product_id"] {
                if self.checkProducIsInCart(withProdId: cartProdId as! String) {
                    cell.addToCartButton.setTitle("In Cart", for: .normal)
                    cell.addToCartButton.setTitle("In Cart", for: .highlighted)
                    
                    NotificationCenter.default.post(name: Notification.Name("MyCartUpdateNotification"), object: nil)
                } else {
                    
                    cell.addToCartButton.setTitle(NSLocalizedString("ADD TO CART", comment: ""), for: .normal)
                    cell.addToCartButton.setTitle(NSLocalizedString("ADD TO CART", comment: ""), for: .highlighted)
                    NotificationCenter.default.post(name: Notification.Name("MyCartUpdateNotification"), object: nil)
                }
            }
        } else {
            var myCartInfo = [String: AnyObject]()
            if let info = product {
                if let id = info.productId, let name = info.productName, let price = info.price {
                    myCartInfo["name"] = name as AnyObject?
                    myCartInfo["product_id"] = id as AnyObject?
                    //myCartInfo["image"] = image as AnyObject?
                    myCartInfo["price"] = price as AnyObject?
                    
                    //wishlist_prod_icon
                    if MyCart.getProductWith(productId: id) == nil {
                        let _ = MyCart.addProductToMyCartList(data: myCartInfo)
                        cell.addToCartButton.setTitle("In Cart", for: .normal)
                        cell.addToCartButton.setTitle("In Cart", for: .highlighted)
                        
                        NotificationCenter.default.post(name: Notification.Name("MyCartUpdateNotification"), object: nil)
                    } else {
                        let _ = MyCart.removeProduct(withId: id)
                        if AppManager.isUserLoggedIn {
                            UploadTaskHandler.sharedInstance.deleteMyCartData(withProductId: id, "")
                        }
                        cell.addToCartButton.setTitle(NSLocalizedString("ADD TO CART", comment: ""), for: .normal)
                        cell.addToCartButton.setTitle(NSLocalizedString("ADD TO CART", comment: ""), for: .highlighted)
                        
                        NotificationCenter.default.post(name: Notification.Name("MyCartUpdateNotification"), object: nil)
                    }
                }
            }
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
}

//MARK:- WishListProductDelegeate
extension MyWishlistViewController: WishListProductDelegeate {
    
    func didTapAddToCartButton(atCell cell: WishlistTableViewCell) {
        var cartListInfo = [String: AnyObject]()
        if AppManager.currentApplicationMode() == .online {
            if let indexPath = self.mywishlistTableView.indexPath(for: cell) {
                if let cartProd = self.fetchedResultsController?.fetchedObjects?[indexPath.row] as? WishLists {
                    if let cartProdName = cartProd.productName, let prodId = cartProd.productId {
                        cartListInfo["name"] = cartProdName as AnyObject?
                        cartListInfo["product_id"] = prodId as AnyObject?
                        if ((AppManager.isUserLoggedIn) && (!self.checkProducIsInCart(withProdId: prodId))) {
                            
                            UploadTaskHandler.sharedInstance.uploadIndividualMyCartData(withProductId: prodId, withHandler: { (success, cartId) in
                                
                                if success {
                                    cartListInfo["cart_id"] = cartId as AnyObject?
                                    let _ = MyCart.addProductToMyCartList(data: cartListInfo)
                                    self.handleWishListData(withProduInfo: cartProd, withCellInfo: cell)
                                    ALAlerts.showToast(message: NSLocalizedString("ITEM_ADDED_TO_CART", comment: ""))
                                    cell.addToCartButton.isEnabled = true
                                } else {
                                    ALAlerts.showToast(message: NSLocalizedString("ITEM_NOT_ADDED_TO_CART", comment: ""))
                                    cell.addToCartButton.isEnabled = true
                                }
                            })
                        } else {
                            if let cartProduct = MyCart.getProductWith(productId: prodId) {
                                if let cartId = cartProduct.cartId {
                                    UploadTaskHandler.sharedInstance.deleteMyCartData(withProductId: prodId, cartId, withHandler: { (success) in
                                        if success {
                                            if let cartProdId = cartProduct.productId {
                                                let _ = MyCart.removeProduct(withId: cartProdId)
                                            }
                                            ALAlerts.showToast(message: NSLocalizedString("ITEM_REMOVED_FROM_CART", comment: ""))
                                            self.handleWishListData(withProduInfo: cartProd, withCellInfo: cell)
                                            
                                            var cartObjInfo = [String: AnyObject]()
                                            cartObjInfo["removedProduct"] = prodId as AnyObject?
                                            
                                            NotificationCenter.default.post(name: Notification.Name("MyCartUpdateNotification"), object: cartObjInfo)
                                        }
                                        cell.addToCartButton.isEnabled = true
                                        
                                    })
                                } else {
                                    cell.addToCartButton.isEnabled = true
                                }
                            }
                        }
                    }
                }
            }
        } else {
            if let indexPath = self.mywishlistTableView.indexPath(for: cell) {
                if let currentObject = self.fetchedResultsController?.fetchedObjects?[indexPath.row] as? WishLists {
                    var cartListInfo = [String: AnyObject]()
                    cartListInfo["name"] = currentObject.productName as AnyObject?
                    cartListInfo["product_id"] = currentObject.productId as AnyObject?
						  cartListInfo["total"] = currentObject.price as AnyObject?
						  cartListInfo["price"] = currentObject.price as AnyObject?
						  cartListInfo["quantity"] = 1 as AnyObject?
						
						if !checkProducIsInCart(withProdId: currentObject.productId!) {
							
							print("Product is not in Cart")
							self.addProductToCart(withProductDetails: cartListInfo, atCell: cell)
						} else {
							self.removeProductFromCart(withProductDetails: currentObject, atCell: cell)
						}
						cell.addToCartButton.isEnabled = true
						do {
							try currentObject.managedObjectContext?.save()
							currentObject.managedObjectContext?.mr_saveToPersistentStoreAndWait()
						} catch let error {
							print("Error Saving Cart Object \(error.localizedDescription)")
						}
						
                    /* if AppManager.isUserLoggedIn {
                        if let product = Product.getProductWith(productId: currentObject.productId!) {
                            if !product.isInCart {
                                UploadTaskHandler.sharedInstance.uploadIndividualMyCartData(withProductId: currentObject.productId)
                            } else {
                                if let cartProdId = currentObject.productId {
                                    if let cartProduct = MyCart.getProductWith(productId: cartProdId) {
                                        if let cartId = cartProduct.cartId {
                                            UploadTaskHandler.sharedInstance.deleteMyCartData(withProductId: currentObject.productId, cartId)
                                        }
                                    }
                                }
                            }
                        }
                        self.handleCartData(atCell: cell, withProduct: currentObject)
                    } else {
                        self.showAlertWith(warningMsg: "Please, Login to Continue")
                    } */
                }
            }
        }
    }
    
    func didTapRemoveButton(atCell cell: WishlistTableViewCell) {
        
        let alertMessage = NSLocalizedString("Are you sure you want to remove this item?", comment: "")
        let deleteAlertController = UIAlertController(title: Constants.alertTitle, message: alertMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title: Constants.alertAction, style: .destructive) { (UIAlerAction) in
            
            if let indexPath = self.mywishlistTableView.indexPath(for: cell) {
                if let currentObject = self.fetchedResultsController?.fetchedObjects?[indexPath.row] as? WishLists {
                    if let wishListProd = WishLists.getProductWith(productId: currentObject.productId!) {
						if AppManager.currentApplicationMode() == .online {
							if AppManager.isUserLoggedIn {
								UploadTaskHandler.sharedInstance.deleteWishListData(withProductId: wishListProd.productId, withHandler: { (success) in
									if success {
										ALAlerts.showToast(message: NSLocalizedString("ITEM_REMOVED_FROM_WISHLIST", comment: ""))
										self.handleWishListData(withProduInfo: wishListProd, withCellInfo: cell, withOnlineProd: nil)
										cell.removeButton.isEnabled = true
										
										var wishListObjInfo = [String: AnyObject]()
										wishListObjInfo["removedProduct"] = wishListProd.productId as AnyObject?
										
										if let productId = wishListProd.productId {
											let _ = WishLists.removeProduct(withId: productId)
											NotificationCenter.default.post(name: Notification.Name("WishListUpdateNotification"), object: wishListObjInfo)
										}
										
										if let myWishlistCount = WishLists.mr_findAll() {
											if myWishlistCount.count == 0 {
												self.showNoData()
											}
										}
									}
								})
							}
						} else {
							cell.removeButton.isEnabled = true
							
							var wishListObjInfo = [String: AnyObject]()
							wishListObjInfo["removedProduct"] = wishListProd.productId as AnyObject?
							
							if let productId = wishListProd.productId {
								let _ = WishLists.removeProduct(withId: productId)
								NotificationCenter.default.post(name: Notification.Name("WishListUpdateNotification"), object: wishListObjInfo)
							}
							
							if let myWishlistCount = WishLists.mr_findAll() {
								if myWishlistCount.count == 0 {
									self.showNoData()
								}
							}
						}
                    }
                }
            }
        }
		
        let cancleAction = UIAlertAction(title: Constants.cancelAction, style: .default, handler: nil)
        deleteAlertController.addAction(okAction)
        deleteAlertController.addAction(cancleAction)
        self.present(deleteAlertController, animated: true, completion: nil)
    }
}

//MARK:- Cart Helper Methods:
extension MyWishlistViewController {
	
	func addProductToCart(withProductDetails productInfo: [String: AnyObject], atCell cell: WishlistTableViewCell) {
		
		let _ = MyCart.addProductToMyCartList(data: productInfo)
		
		cell.addToCartButton.setTitle("IN CART", for: .normal)
		cell.addToCartButton.setTitle("IN CART", for: .highlighted)
		
		NotificationCenter.default.post(name: Notification.Name("MyCartUpdateNotification"), object: nil)
	}
	
	func removeProductFromCart(withProductDetails productInfo: WishLists, atCell cell: WishlistTableViewCell) {
		if let productId = productInfo.productId {
			let _ = MyCart.removeProduct(withId: productId)
			
			cell.addToCartButton.setTitle("ADD TO CART", for: .normal)
			cell.addToCartButton.setTitle("ADD TO CART", for: .highlighted)
	  
			NotificationCenter.default.post(name: Notification.Name("MyCartUpdateNotification"), object: nil)
		}
	}
}
