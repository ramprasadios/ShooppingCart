//
//  GetProductCommonTableViewCell.swift
//  Alzahrani
//
//  Created by Prakash on 13/07/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

//
//  GetProductCommonTableViewCell.swift
//  Alzahrani
//
//  Created by Hardwin on 04/05/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit
import CoreData
import AlamofireImage

protocol GPCellButtonActionsDelegate: NSObjectProtocol {
    func didTapShareButton(withProduInfo info: NewArrival?, withOnlineProduct onlineProd: [String: AnyObject]?)
    func didTapCartProductButton()
}

typealias GPImageDownloadHandler = ((_ success: Bool, _ response: Data?) -> Void)
typealias GPNewArrivalTapCallback = ((_ success: Bool, _ withProduct: NewArrival?, _ productData: ProductData?, _ productInfo: [String: AnyObject]?) -> Void)

class GetProductCommonTableViewCell: UITableViewCell {
    
    //MARK:- IB-Outlets:
    @IBOutlet weak var newArrivalsCollectionView: UICollectionView!
    
    //MARK:- Properties:-
    weak var delegate: GPCellButtonActionsDelegate?
    var cellTappedHandler: GPNewArrivalTapCallback?
    var newArrivalsList = [NewArrival]()
    var newArrivalImageData = [BannerImage]()
    var newArrivalsInfo = [[String: AnyObject]]()
    
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
extension GetProductCommonTableViewCell {
    
    func addNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(GetProductCommonTableViewCell.reloadUI), name: Notification.Name("NewArrivalDownloadSuccessNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GetProductCommonTableViewCell.handleCartProductRemove), name: Notification.Name("MyCartUpdateNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GetProductCommonTableViewCell.handleMyWishlistRemove), name: Notification.Name("WishListUpdateNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GetProductCommonTableViewCell.handleWishListAdd), name: Notification.Name("WishListAddNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GetProductCommonTableViewCell.handleCartAddNotification), name: Notification.Name("CartAddNotification"), object: nil)
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
                        if let productId = product["product_id"] {
                            if productId as! String == cartObjectId {
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
    
    func handleMyWishlistRemove(notification: Notification) {
        if let object = notification.object as? [String: AnyObject] {
            if let wishListObj = object["removedProduct"] as? String {
                
                if AppManager.currentApplicationMode() == .online {
                    for (index, product) in newArrivalsInfo.enumerated() {
                        if let productId = product["product_id"] {
                            if productId as! String == wishListObj {
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
                        if let productId = product["product_id"] {
                            if productId as! String == wishListObj {
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
    
    func handleWishListData(withProduInfo info: NewArrival?, withCellInfo cell: NewArrivalsCollectionViewCell, withOnlineProd product: [String: AnyObject]? = nil) {
        
        var wishListInfo = [String: AnyObject]()
        if AppManager.currentApplicationMode() == .online {
            if let wishlistProdId = product?["product_id"] {
                if self.checkProductIsLiked(withProdId: wishlistProdId as! String) {
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
            if let id = info?.productId, let _ = info?.productImage, let name = info?.name, let image = info?.productImage, let price = info?.price {
                if AppManager.languageType() == .english {
                    wishListInfo["name"] = name as AnyObject?
                } else {
                    wishListInfo["name"] = info?.name as AnyObject?
                }
                wishListInfo["product_id"] = id as AnyObject?
                wishListInfo["image"] = image as AnyObject?
                wishListInfo["price"] = price as AnyObject?
                
                //wishlist_prod_icon
                if WishLists.getProductWith(productId: id) == nil {
                    let _ = WishLists.addProductToWishList(data: wishListInfo)
                    if let heartRedImage = UIImage(named: "wishList_red") {
                        cell.wishListButton.setImage(heartRedImage, for: .normal)
                        cell.wishListButton.setImage(heartRedImage, for: .highlighted)
                        
                        NotificationCenter.default.post(name: Notification.Name("WishListUpdateNotification"), object: nil)
                    }
                } else {
                    let _ = WishLists.removeProduct(withId: id)
                    if AppManager.isUserLoggedIn {
                        UploadTaskHandler.sharedInstance.deleteWishListData(withProductId: id)
                    }
                    if let heartRedImage = UIImage(named: "wishlist_prod_icon") {
                        cell.wishListButton.setImage(heartRedImage, for: .normal)
                        cell.wishListButton.setImage(heartRedImage, for: .highlighted)
                        
                        NotificationCenter.default.post(name: Notification.Name("WishListUpdateNotification"), object: nil)
                    }
                }
            }
        }
    }
    
    func handleCartData(withProduInfo info: NewArrival?, withCellInfo cell: NewArrivalsCollectionViewCell, withOnlineProd product: [String: AnyObject]? = nil) {
        
        if AppManager.currentApplicationMode() == .online {
//            self.delegate?.didTapCartProductButton()
            if let cartProdId = product?["product_id"] {
                if self.checkProducIsInCart(withProdId: cartProdId as! String) {
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
//            self.delegate?.didTapCartProductButton()
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
                
                if let id = info?.productId, let _ = info?.productImage, let name = info?.name, let image = info?.productImage, let price = info?.price {
                    if AppManager.languageType() == .english {
                        myCartInfo["name"] = name as AnyObject?
                    } else {
                        myCartInfo["name"] = info?.name as AnyObject?
                    }
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
//                self.delegate?.didTapCartProductButton()
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
extension GetProductCommonTableViewCell: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if AppManager.currentApplicationMode() == .online {
            return self.newArrivalsInfo.count
        } else {
            if self.newArrivalsList.count > 25 {
                return 25
            } else {
                return self.newArrivalsList.count
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewArrivalsCollectionViewCell", for: indexPath) as? NewArrivalsCollectionViewCell
        cell?.cellActionHandlerDelegate = self
        cell?.goToProductDetailPageBtn.tag = indexPath.row
        cell?.goToProductDetailPageBtn.addTarget(self, action: #selector(self.goToProductDetailPageTapped(sender:)), for: .touchUpInside)
        
        if AppManager.currentApplicationMode() == .online {
            let newArrivalProd = self.newArrivalsInfo[indexPath.row]
            self.handleCartData(withProduInfo: nil, withCellInfo: cell!, withOnlineProd: newArrivalProd)
            self.handleWishListData(withProduInfo: nil, withCellInfo: cell!, withOnlineProd: newArrivalProd)
            let nameKey = (AppManager.languageType() == .english) ? "name" : "name"
            if let produName = newArrivalProd[nameKey] as? String, let prodPrice = newArrivalProd["price"] as? String, let image = newArrivalProd["image"] {
                cell?.productNameLabel.text = produName
                
                let prorperURL = image.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                let imageURLStr = URLBuilder.getImageDownloadBaseURL() + prorperURL!
                //let url = URL(string: imageURLStr)
                
                UploadTaskHandler.sharedInstance.setImage(onImageView: (cell?.productImageView)!, withImageUrl: imageURLStr, placeHolderImage: nil)
                
                //                    cell?.productImageView.af_setImage(withURL: url!, placeholderImage: nil, filter: nil, imageTransition: .crossDissolve(0.5), runImageTransitionIfCached: true, completion: nil)
                
                if let quantity = newArrivalProd["quantity"] as? String {
                    let languageId = LanguageType(rawValue: UserDefaultManager.sharedManager().selectedLanguageId!)
                    if let qty = Int(quantity) {
                        if qty >= 1 {
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
                    //                cell?.productOfferLabel.text = newArrivalProduct.price
                }
            }
            
            if let specialPrice = newArrivalProd["special"] as? String, let price = newArrivalProd["price"] as? String {
                cell?.discountProductPrice.isHidden = false
                if let actualPrice = Float(price), let specialPrice = Float(specialPrice) {
                    let difference = actualPrice - specialPrice
                    let percentageDiscount = ((difference / actualPrice) * 100)
                    let finalValue = Int(percentageDiscount)
                    cell?.discountProductPrice.text = "- " + finalValue.description + "%"
                }
            } else {
                cell?.discountProductPrice.isHidden = true
            }
            
            return cell!
        } else {
            let newArrivalProduct = self.newArrivalsList[indexPath.row]
            let userSelectedLanguage = UserDefaultManager.sharedManager().selectedLanguageId
            if let languageType = LanguageType(rawValue: userSelectedLanguage!) {
                switch languageType {
                case .arabic:
                    cell?.productNameLabel.text = newArrivalProduct.name
                case .english:
                    cell?.productNameLabel.text = newArrivalProduct.name
                }
            }
            
            if let specialPrice = newArrivalProduct.specialPrice {
                
                if let price = Double(newArrivalProduct.price ?? "") {
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
                if let price = Double(newArrivalProduct.price ?? "") {
                    let roundedPrice = String(format: "%.2f", price)
                    cell?.productOfferLabel.text = roundedPrice + " " + "SAR"
                }
                //                cell?.productOfferLabel.text = newArrivalProduct.price
            }
            //cell?.productOfferLabel.text = newArrivalProduct.price
            let imageURL = newArrivalProduct.productImage
            let prorperURL = imageURL?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            
            if newArrivalProduct.isInCart {
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
            if newArrivalProduct.isProductLiked {
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
            
            let imageURLStr = URLBuilder.getImageDownloadBaseURL() + prorperURL!
            let url = URL(string: imageURLStr)
            cell?.productImageView.af_setImage(withURL: url!, placeholderImage: nil, filter: nil, imageTransition: .crossDissolve(0.5), runImageTransitionIfCached: true, completion: nil)
            
            if let offerPrice = newArrivalProduct.specialPrice {
                if offerPrice != "" {
                    cell?.discountProductPrice.isHidden = false
                    if let actualPrice = Float(newArrivalProduct.price!), let specialPrice = Float(newArrivalProduct.specialPrice!) {
                        let difference = actualPrice - specialPrice
                        let percentageDiscount = ((difference / actualPrice) * 100)
                        let finalValue = Int(percentageDiscount)
                        cell?.discountProductPrice.text = "- " + finalValue.description
                    }
                } else {
                    cell?.discountProductPrice.isHidden = true
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
                    let newArrivalProduct = self.newArrivalsList[indexPath.row]
                    self.cellTappedHandler?(true, newArrivalProduct, nil, nil)
                }
            }
        }
    }
}




//MARK:- UICollectionViewDelegate:
extension GetProductCommonTableViewCell: UICollectionViewDelegate {
    
    
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
                    let newArrivalProduct = self.newArrivalsList[indexPath.row]
                    self.cellTappedHandler?(true, newArrivalProduct, nil, nil)
                }
            }
        }
    }
}

//MARK:- UICollectionViewDelegateFlowLayout:
extension GetProductCommonTableViewCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.frame.size.width * 0.4, height: self.frame.size.height)
    }
}

extension GetProductCommonTableViewCell: CellButtonActionProtocol {
    
    func didTapShareButton(atCell cell: NewArrivalsCollectionViewCell) {
        if AppManager.currentApplicationMode() == .online {
            if let indexPath = self.newArrivalsCollectionView.indexPath(for: cell) {
                let shareProduct = self.newArrivalsInfo[indexPath.row]
                //print("Sharing \(shareProduct.name)")
                self.delegate?.didTapShareButton(withProduInfo: nil, withOnlineProduct: shareProduct)
            }
        } else {
            if let indexPath = self.newArrivalsCollectionView.indexPath(for: cell) {
                let shareProduct = self.newArrivalsList[indexPath.row]
                print("Sharing \(shareProduct.name)")
                self.delegate?.didTapShareButton(withProduInfo: shareProduct, withOnlineProduct: nil)
            }
        }
    }
    
    func didTapCartButton(atCell cell: NewArrivalsCollectionViewCell) {
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
                                ALAlerts.showToast(message: "Item added to cart.")
                                cell.cartButton.isEnabled = true
                            } else {
                                ALAlerts.showToast(message: "Item not added to cart due to network issue.")
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
                                        ALAlerts.showToast(message: "Item removed from cart.")
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
                //                    self.handleCartData(withProduInfo: nil, withCellInfo: cell, withOnlineProd: cartListInfo)
            }
        } else {
            if let indexPath = self.newArrivalsCollectionView.indexPath(for: cell) {
                let cartProd = self.newArrivalsList[indexPath.row]
                cartListInfo["name"] = cartProd.name as AnyObject?
                cartListInfo["product_id"] = cartProd.productId as AnyObject?
                if ((AppManager.isUserLoggedIn) && (cartProd.isInCart != true)) {
                    UploadTaskHandler.sharedInstance.uploadIndividualMyCartData(withProductId: cartProd.productId)
                } else {
									self.delegate?.didTapCartProductButton()
                    if let cartProdId = cartProd.productId {
                        if let cartProduct = MyCart.getProductWith(productId: cartProdId) {
                            if let cartId = cartProduct.cartId {
                                UploadTaskHandler.sharedInstance.deleteMyCartData(withProductId: cartProd.productId, cartId)
                            }
                        }
                    }
                }
                self.handleCartData(withProduInfo: cartProd, withCellInfo: cell)
            }
        }
    }
    
    func didTapWishlistButton(atCell cell: NewArrivalsCollectionViewCell) {
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
                                ALAlerts.showToast(message: "Item added to Wishlist.")
                                cell.wishListButton.isEnabled = true
                                
                            } else {
                                ALAlerts.showToast(message: "Item not added to Wishlist.")
                                cell.wishListButton.isEnabled = true
                            }
                        })
                    } else {
                        if let wishListProd = WishLists.getProductWith(productId: prodId as! String) {
                            
                            if let cartProdId = wishListProd.productId {
                                
                                UploadTaskHandler.sharedInstance.deleteWishListData(withProductId: cartProdId, withHandler: { (success) in
                                    if success {
                                        let _ = WishLists.removeProduct(withId: cartProdId)
                                        ALAlerts.showToast(message: "Item removed From Wishlist.")
                                        //                                            self.updateWishlistStatus(withProductId: cartProdId, atCell: cell)
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
                let wishListProduct = self.newArrivalsList[indexPath.row]
                print("Adding \(wishListProduct.name) to wishlist")
                if ((AppManager.isUserLoggedIn) && (wishListProduct.isProductLiked != true)) {
                    UploadTaskHandler.sharedInstance.uploadIndividualWishList(withProductId: wishListProduct.productId)
                }
                wishListProduct.isProductLiked = !wishListProduct.isProductLiked
                do {
                    try wishListProduct.managedObjectContext?.save()
                    //self.newArrivalsCollectionView.reloadData()
                } catch {
                    print("Error Saving Data")
                }
                self.handleWishListData(withProduInfo: wishListProduct, withCellInfo: cell)
            }
        }
    }
}

