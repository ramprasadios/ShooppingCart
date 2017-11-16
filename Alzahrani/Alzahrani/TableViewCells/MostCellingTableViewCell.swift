//
//  MostCellingTableViewCell.swift
//  Alzahrani
//
//  Created by Hardwin on 04/05/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit
import CoreData

protocol TSCellButtonActionsDelegate: NSObjectProtocol {
    func didTapTSShareButton(withProduInfo info: TopSelling?, withOnlineProduct onlineProd: [String: AnyObject]?)
    func didTapTSCartProductButton()
}

typealias TopCellingCellTapHandler = ((_ success: Bool, _ product: TopSelling?, _ productData: ProductData?, _ productInfo: [String: AnyObject]?) -> Void)

class MostCellingTableViewCell: UITableViewCell {
    
    //MARK:- IB-Outlets:
    @IBOutlet weak var mostCellingCollectionView: UICollectionView!
    
    //MARK:- Properties:-
    weak var delegate: TSCellButtonActionsDelegate?
    var cellTappedHandler: TopCellingCellTapHandler?
    var downloadSuccessHandler: DownloadCompletion?
    var mostSellingsList = [TopSelling]()
    
    var blockOperations: [BlockOperation] = []
    var shouldReloadCollectionView: Bool = false
    var newArrivalImageData = [BannerImage]()
    var topSelllingInfo = [[String: AnyObject]]()
    
    //Mark:- Life Cycle:
    override func awakeFromNib() {
        self.contentView.backgroundColor = UIColor(rgba: "EBEBF1")
        super.awakeFromNib()
        self.setupCollectionView()
        self.addNotificationObservers()
        //self.handleOnlineModeProductDownload()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //MARK:- Designated Initilizers:
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

//MARK:- Helper Methods:
extension MostCellingTableViewCell {
    
    func addNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(MostCellingTableViewCell.reloadUI), name: Notification.Name("TopSellingDownloadSuccessNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MostCellingTableViewCell.handleCartProductRemove), name: Notification.Name("MyCartUpdateNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MostCellingTableViewCell.handleMyWishlistRemove), name: Notification.Name("WishListUpdateNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MostCellingTableViewCell.handleWishListAdd), name: Notification.Name("WishListAddNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MostCellingTableViewCell.handleCartAddNotification), name: Notification.Name("CartAddNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MostCellingTableViewCell.updateProductCartStatus), name: Notification.Name("UpdateProductCartStatus"), object: nil)
    }
    
    func reloadUI() {
        if self.mostSellingsList.count == 0 {
            self.getAllTopSellingData()
        }
        self.mostCellingCollectionView.reloadData()
    }
    
    func handleMyWishlistRemove(notification: Notification) {
        if let object = notification.object as? [String: AnyObject] {
            if let wishListObj = object["removedProduct"] as? String {
                
                if AppManager.currentApplicationMode() == .online {
                    for (index, product) in topSelllingInfo.enumerated() {
                        if let productId = product["product_id"] {
                            if productId as! String == wishListObj {
                                let indexPath = IndexPath(row: index, section: 0)
                                let cell = self.mostCellingCollectionView.cellForItem(at: indexPath)
                                
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
                        self.mostCellingCollectionView.reloadData()
                    }
                }
            }
        }
    }
    
    func handleWishListAdd(notification: Notification) {
        if let object = notification.object as? [String: AnyObject] {
            if let wishListObj = object["AddWishlistProd"] as? String {
                
                if AppManager.currentApplicationMode() == .online {
                    for (index, product) in topSelllingInfo.enumerated() {
                        if let productId = product["product_id"] {
                            if productId as! String == wishListObj {
                                let indexPath = IndexPath(row: index, section: 0)
                                let cell = self.mostCellingCollectionView.cellForItem(at: indexPath)
                                
                                if let heartRedImage = UIImage(named: "wishList_red") {
                                    (cell as? NewArrivalsCollectionViewCell)?.wishListButton.setImage(heartRedImage, for: .normal)
                                    (cell as? NewArrivalsCollectionViewCell)?.wishListButton.setImage(heartRedImage, for: .highlighted)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func handleCartAddNotification(notification: Notification) {
        if let object = notification.object as? [String: AnyObject] {
            if let wishListObj = object["AddCartProd"] as? String {
                
                if AppManager.currentApplicationMode() == .online {
                    for (index, product) in topSelllingInfo.enumerated() {
                        if let productId = product["product_id"] {
                            if productId as! String == wishListObj {
                                let indexPath = IndexPath(row: index, section: 0)
                                let cell = self.mostCellingCollectionView.cellForItem(at: indexPath)
                                
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
    
    func handleCartProductRemove(notification: Notification) {
        if let object = notification.object as? [String: AnyObject] {
            if let cartObjectId = object["removedProduct"] as? String {
                
                if AppManager.currentApplicationMode() == .online {
                    for (index, product) in topSelllingInfo.enumerated() {
                        if let productId = product["product_id"] {
                            if productId as! String == cartObjectId {
                                let indexPath = IndexPath(row: index, section: 0)
                                let cell = self.mostCellingCollectionView.cellForItem(at: indexPath)
                                
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
                        self.mostCellingCollectionView.reloadData()
                    }
                }
            }
        }
    }
    
    func setupCollectionView() {
        let nib = UINib(nibName: "NewArrivalsCollectionViewCell", bundle: nil)
        self.mostCellingCollectionView.register(nib, forCellWithReuseIdentifier: "NewArrivalsCollectionViewCell")
        self.mostCellingCollectionView.backgroundColor = UIColor.clear
        self.mostCellingCollectionView.dataSource = self
        self.mostCellingCollectionView.delegate = self
    }
    
    func setTopSellingProductImageTo(indexValue index: Int, cell: NewArrivalsCollectionViewCell, withImageURL url: String, withCompletion completionHandler: @escaping ImageDownloadHandler) {
        
        //        cell.productImageView.image = UIImage(named: Constants.placeHolderImage)
        //        cell.bringSubview(toFront: cell.imageDownloadIndicator)
        //        cell.imageDownloadIndicator.startAnimating()
        //        cell.imageDownloadIndicator.isHidden = false
        
        SyncManager.syncOperation(operationType: .imageDownloadOperation, info: url, completionHandler: { (imageData, error) in
            if error == nil {
                completionHandler(true, imageData as! Data?)
                
            } else {
                DispatchQueue.main.async {
                    self.mostCellingCollectionView.reloadData()
                }
            }
        })
    }
    
    func getAllTopSellingData() {
        self.mostSellingsList = TopSelling.getAllTopSellings()!
    }
    
    func handleOnlineModeProductDownload() {
        if AppManager.currentApplicationMode() == .offline {
            self.getAllTopSellingData()
        } else {
            self.downloadTopSelliings(withSuccesshandler: { (success) in
                if success {
                    DispatchQueue.main.async {
                        self.mostCellingCollectionView.reloadData()
                    }
                }
            })
        }
    }
    
    func downloadTopSelliings(withSuccesshandler successHandler: DownloadCompletion? = nil) {
        let custGrpId = (AppManager.isUserLoggedIn) ? UserDefaultManager.sharedManager().customerGroupId : "1"
        SyncManager.syncOperation(operationType: .getTopSetllingProducts, info: custGrpId) { (response, error) in
            
            if error == nil {
                successHandler?(true)
                
                print("New Arrival Response: \(response)")
                
                if let newArrivalsInfo = response as? [[String: AnyObject]] {
                    DispatchQueue.main.async {
                        self.topSelllingInfo = newArrivalsInfo
                    }
                } else {
                    
                }
            } else {
                successHandler?(false)
            }
        }
    }
    
    func handleWishListData(withProduInfo info: TopSelling?, withCellInfo cell: NewArrivalsCollectionViewCell, withOnlineProd product: [String: AnyObject]? = nil) {
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
            if let id = info?.productid, let _ = info?.productImage, let name = info?.name, let image = info?.productImage, let price = info?.price {
                wishListInfo["name"] = name as AnyObject?
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
    
    func handleCartData(withProduInfo info: TopSelling?, withCellInfo cell: NewArrivalsCollectionViewCell, withOnlineProd product: [String: AnyObject]? = nil) {
        
        if AppManager.currentApplicationMode() == .online {
            //self.delegate?.didTapCartProductButton()
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
            var myCartInfo = [String: AnyObject]()
            if AppManager.isUserLoggedIn {
                
                if let cartProd = info {
                    cartProd.isInCart = !cartProd.isInCart
                    do {
                        try cartProd.managedObjectContext?.save()
                        //self.mostCellingCollectionView.reloadData()
                    } catch {
                        print("Product not added to Cart")
                    }
                }
                
                if let id = info?.productid, let _ = info?.productImage, let name = info?.name, let image = info?.productImage, let price = info?.price {
                    if AppManager.languageType() == .english {
                        myCartInfo["name"] = name as AnyObject?
                    } else {
                        myCartInfo["name"] = info?.arName as AnyObject?
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
                self.delegate?.didTapTSCartProductButton()
            }
        }
    }
    
    func getProductData(atIndex index: Int) -> ProductData {
        let product = self.topSelllingInfo[(index)]
        let isInCart = self.checkProducIsInCart(withProdId: product["product_id"] as! String)
        let isLiked = self.checkProductIsLiked(withProdId: product["product_id"] as! String)
        let productData = ProductData(withName: product["name"] as! String, withProductId: product["product_id"] as! String, andDescription: product["description"] as! String, product["sku"] as! String, product["price"] as! String, prodImage: product["image"] as! String, isInCart, isLiked, specialPrice: product["special"] as? String ?? "", availability: product["quantity"] as! String, product["arname"] as! String, product["ardescription"] as! String)
        
        return productData
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
        self.topSelllingInfo = data
    }
    
    func updateProductCartStatus() {
        
        for (index, _) in self.topSelllingInfo.enumerated() {
            let indexPath = IndexPath(row: index, section: 0)
            if let cell = self.mostCellingCollectionView.cellForItem(at: indexPath) {
                if let selectedCartImage = UIImage(named: "cart_prod_icon") {
                    (cell as? NewArrivalsCollectionViewCell)?.cartButton.setImage(selectedCartImage, for: .normal)
                    (cell as? NewArrivalsCollectionViewCell)?.cartButton.setImage(selectedCartImage, for: .highlighted)
                }
            }
        }
    }
}

//MARK:- UICollectionViewDataSource:
extension MostCellingTableViewCell: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if AppManager.currentApplicationMode() == .online {
            return self.topSelllingInfo.count
        } else {
            if self.mostSellingsList.count > 25 {
                return 25
            } else {
                return self.mostSellingsList.count
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewArrivalsCollectionViewCell", for: indexPath) as? NewArrivalsCollectionViewCell
        cell?.cellActionHandlerDelegate = self
        
        cell?.goToProductDetailPageBtn.tag = indexPath.row
        cell?.goToProductDetailPageBtn.addTarget(self, action: #selector(self.goToProductDetailPageTapped(sender:)), for: .touchUpInside)
        
        if AppManager.currentApplicationMode() == .online {
            
            let topSellingProd = self.topSelllingInfo[indexPath.row]
            
            self.handleCartData(withProduInfo: nil, withCellInfo: cell!, withOnlineProd: topSellingProd)
            self.handleWishListData(withProduInfo: nil, withCellInfo: cell!, withOnlineProd: topSellingProd)
            if let produName = topSellingProd["name"] as? String, let prodPrice = topSellingProd["price"] as? String, let image = topSellingProd["image"], let arName = topSellingProd["arname"] {
                
                if AppManager.languageType() == .arabic {
                    cell?.productNameLabel.text = arName as? String
                } else {
                    cell?.productNameLabel.text = produName
                }
                
                let prorperURL = image.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                let imageURLStr = URLBuilder.getImageDownloadBaseURL() + prorperURL!
//                let url = URL(string: imageURLStr)
                
                UploadTaskHandler.sharedInstance.setImage(onImageView: (cell?.productImageView)!, withImageUrl: imageURLStr, placeHolderImage: nil)
                
//                cell?.productImageView.af_setImage(withURL: url!, placeholderImage: nil, filter: nil, imageTransition: .crossDissolve(0.5), runImageTransitionIfCached: true, completion: nil)
                
                if let price = Double(prodPrice) {
                    let roundedPrice = String(format: "%.2f", price)
                    cell?.productOfferLabel.text = roundedPrice + " " + "SAR"
                }
                
                if let quantity = topSellingProd["quantity"] as? String {
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
            }
            
            //Set Product Offers Price:
            if let specialPrice = topSellingProd["special"] as? String {
                
                if let price = Double(topSellingProd["price"] as? String ?? "") {
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
                if let price = Double(topSellingProd["price"] as? String ?? "") {
                    let roundedPrice = String(format: "%.2f", price)
                    cell?.productOfferLabel.text = roundedPrice + " " + "SAR"
                }
            }
            
            if let specialPrice = topSellingProd["special"] as? String, let price = topSellingProd["price"] as? String {
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
            let topSellingProduct = self.mostSellingsList[indexPath.row]
            let userSelectedLanguage = UserDefaultManager.sharedManager().selectedLanguageId
            if let languageType = LanguageType(rawValue: userSelectedLanguage!) {
                switch languageType {
                case .arabic:
                    cell?.productNameLabel.text = topSellingProduct.arName
                case .english:
                    cell?.productNameLabel.text = topSellingProduct.name
                }
            }
            
            cell?.productOfferLabel.text = topSellingProduct.price
            let imageURL = topSellingProduct.productImage
            let prorperURL = imageURL?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            
            if topSellingProduct.isInCart {
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
            if topSellingProduct.isProductLiked {
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
            
            if let specialPrice = topSellingProduct.specialPrice {
                
                if let price = Double(topSellingProduct.price ?? "") {
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
                if let price = Double(topSellingProduct.price ?? "") {
                    let roundedPrice = String(format: "%.2f", price)
                    cell?.productOfferLabel.text = roundedPrice + " " + "SAR"
                }
            }
            
            let imageURLStr = URLBuilder.getImageDownloadBaseURL() + prorperURL!
            let url = URL(string: imageURLStr)
            cell?.productImageView.af_setImage(withURL: url!, placeholderImage: nil, filter: nil, imageTransition: .crossDissolve(0.5), runImageTransitionIfCached: true, completion: nil)
            
            if let offerPrice = topSellingProduct.specialPrice {
                if offerPrice != "" {
                    cell?.discountProductPrice.isHidden = false
                    if let actualPrice = Float(topSellingProduct.price!), let specialPrice = Float(topSellingProduct.specialPrice!) {
                        let difference = actualPrice - specialPrice
                        let percentageDiscount = ((difference / actualPrice) * 100)
                        let finalValue = Int(percentageDiscount)
                        cell?.discountProductPrice.text = "- " + finalValue.description + "%"
                    }
                } else {
                    cell?.discountProductPrice.isHidden = true
                }
            }
            
            let quantity = topSellingProduct.availability
            let languageId = LanguageType(rawValue: UserDefaultManager.sharedManager().selectedLanguageId!)
            let qty = Int(quantity)
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
            return cell!
        }
    }
    
    //MARK: Go to product detail page
    func goToProductDetailPageTapped(sender : UIButton){
        
        if AppManager.currentApplicationMode() == .offline {
            let topSellingProduct = self.mostSellingsList[sender.tag]
            self.cellTappedHandler?(true, topSellingProduct, nil, nil)
        } else {
            let topSellingProduct = self.topSelllingInfo[sender.tag]
            if let _ = topSellingProduct["product_id"] as? String {
                
                self.cellTappedHandler?(true, nil, self.getProductData(atIndex: sender.tag), self.topSelllingInfo[sender.tag])
            }
        }
        print(sender.tag)
    }
}

//MARK:- UICollectionViewDelegate:
extension MostCellingTableViewCell: UICollectionViewDelegate {
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

//MARK:- UICollectionViewDelegateFlowLayout:
extension MostCellingTableViewCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.frame.size.width * 0.4, height: self.frame.size.height)
    }
}

//MARK:- CellButtonActionProtocol
extension MostCellingTableViewCell: CellButtonActionProtocol {
    
    func didTapShareButton(atCell cell: NewArrivalsCollectionViewCell) {
        
        if AppManager.currentApplicationMode() == .online {
            if let indexPath = self.mostCellingCollectionView.indexPath(for: cell) {
                let shareProduct = self.topSelllingInfo[indexPath.row]
                self.delegate?.didTapTSShareButton(withProduInfo: nil, withOnlineProduct: shareProduct)
            }
        } else {
            if let indexPath = self.mostCellingCollectionView.indexPath(for: cell) {
                let shareProduct = self.mostSellingsList[indexPath.row]
                print("Sharing \(shareProduct.name)")
                self.delegate?.didTapTSShareButton(withProduInfo: shareProduct, withOnlineProduct: nil)
            }
        }
    }
    
    func didTapCartButton(atCell cell: NewArrivalsCollectionViewCell) {
			if AppManager.isUserLoggedIn {
				
			} else {
				self.delegate?.didTapTSCartProductButton()
			}
        var cartListInfo = [String: AnyObject]()
        if AppManager.currentApplicationMode() == .online {
            
            if let indexPath = self.mostCellingCollectionView.indexPath(for: cell) {
                let cartProd = self.topSelllingInfo[indexPath.row]
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
                        if let cartProduct = MyCart.getProductWith(productId: prodId as! String) {
                            if let cartId = cartProduct.cartId {
                                UploadTaskHandler.sharedInstance.deleteMyCartData(withProductId: prodId as? String, cartId, withHandler: { (success) in
                                    if success {
                                        if let cartProdId = cartProduct.productId {
                                            let _ = MyCart.removeProduct(withId: cartProdId)
                                        }
                                        ALAlerts.showToast(message: NSLocalizedString("ITEM_REMOVED_FROM_CART", comment: ""))
                                    } else {
                                        ALAlerts.showToast(message: "Item not removed from cart due to network issue.")
                                    }
                                    cell.cartButton.isEnabled = true
                                    self.handleCartData(withProduInfo: nil, withCellInfo: cell, withOnlineProd: cartListInfo)
                                    
                                })
                            } else {
                                cell.cartButton.isEnabled = true
                            }
                        }
                    }
                }
            }
        } else {
            var cartListInfo = [String: AnyObject]()
            if let indexPath = self.mostCellingCollectionView.indexPath(for: cell) {
                let cartProd = self.mostSellingsList[indexPath.row]
                cartListInfo["name"] = cartProd.name as AnyObject?
                cartListInfo["product_id"] = cartProd.productid as AnyObject?
                if ((AppManager.isUserLoggedIn) && (cartProd.isInCart != true)) {
                    UploadTaskHandler.sharedInstance.uploadIndividualMyCartData(withProductId: cartProd.productid)
                } else {
                    if let cartProdId = cartProd.productid {
                        if let cartProduct = MyCart.getProductWith(productId: cartProdId) {
                            if let cartId = cartProduct.cartId {
                                UploadTaskHandler.sharedInstance.deleteMyCartData(withProductId: cartProd.productid, cartId)
                            }
                        }
                    }
                    
                }
                self.handleCartData(withProduInfo: cartProd, withCellInfo: cell)
            }
        }
    }
    
    func didTapWishlistButton(atCell cell: NewArrivalsCollectionViewCell) {
			if AppManager.isUserLoggedIn {
				var wishListInfo = [String: AnyObject]()
				if AppManager.currentApplicationMode() == .online {
					if let indexPath = self.mostCellingCollectionView.indexPath(for: cell) {
						let cartProd = self.topSelllingInfo[indexPath.row]
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
					if let indexPath = self.mostCellingCollectionView.indexPath(for: cell) {
						let wishListProduct = self.mostSellingsList[indexPath.row]
						print("Adding \(wishListProduct.name) to wishlist")
						if ((AppManager.isUserLoggedIn) && (wishListProduct.isProductLiked != true)) {
							UploadTaskHandler.sharedInstance.uploadIndividualWishList(withProductId: wishListProduct.productid)
						}
						wishListProduct.isProductLiked = !wishListProduct.isProductLiked
						do {
							try wishListProduct.managedObjectContext?.save()
							//self.mostCellingCollectionView.reloadData()
						} catch {
							print("Error Saving Data")
						}
						self.handleWishListData(withProduInfo: wishListProduct, withCellInfo: cell)
					}
				}
			} else {
				cell.wishListButton.isEnabled = true
				self.delegate?.didTapTSCartProductButton()
			}
    }
}
