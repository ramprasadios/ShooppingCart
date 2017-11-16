//
//  ProductListViewController.swift
//  Alzahrani
//
//  Created by Ashok Kumar on 09/05/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit
import CoreData

class ProductListViewController: UIViewController {
    
    //IB-Outlets:
    @IBOutlet weak var productsCollectionView: UICollectionView!
    @IBOutlet weak var inStock: CheckBox!
    @IBOutlet weak var outofStock: CheckBox!
    @IBOutlet weak var sortbyTextField: UITextField!
    
    @IBOutlet weak var productFilterButton: UIButton!
    //Properties
    var checkbox = false
    var selectedSubCategory: String?
    var compoundFilterPredicate: NSCompoundPredicate?
    var productsFRC : NSFetchedResultsController<NSFetchRequestResult>?
    var featchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? {
        return getFetchResultController()
    }
    
    var blockOperations: [BlockOperation] = []
    var shouldReloadCollectionView: Bool = false
    var manufacturerIdList = [Int32]()
    var productsListInfo = [[String: AnyObject]]()
    var currentCategory: String?
    var subCategory=true
    var fromScreenType: FromScreenType = .category
    
    //Product Download From Bannnners:
    var bannerBrandName: String = ""
    var bannerBrandId: String = ""
    
    //Product Download From Offers:
    var offerBrandName: String = ""
    var offerBrandId: String = ""
    
    //Product Download from Banners:
    var brandName: String = ""
    var brandsId: String = ""
    
    override func viewDidLoad() {
        self.addNotificationObserver()
        super.viewDidLoad()
        self.setUp()
		self.sortbyTextField.placeholder = NSLocalizedString("FILTER_TEXT_PLACEHOLDER", comment: "")
        self.setFilterImage()
        self.view.bringSubview(toFront: productFilterButton)
        print("Product in List View \(self.subCategory)")
		if AppManager.currentApplicationMode() == .online {
			 self.initialDownloadSetup()
		} else {
			self.updateFetchRequest(withFilterType: .None)
		}
		
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarImage()
    }
    
    @IBAction func productFilterButtonTapped(_ sender: Any) {
        
        let brandsList = self.getAvailableBrandsList()
        if let filterVc = self.storyboard?.instantiateViewController(withIdentifier: ProductFilterViewController.selfName()) as? ProductFilterViewController {
            let filterNavigationVc = UINavigationController(rootViewController: filterVc)
            filterVc.filterResultsArray = brandsList
            self.present(filterNavigationVc, animated: true, completion: nil)
        }
    }
    
    func setUp(){
        let nib = UINib(nibName: "NewArrivalsCollectionViewCell", bundle: nil)
        self.productsCollectionView.register(nib, forCellWithReuseIdentifier: "NewArrivalsCollectionViewCell")
        productsCollectionView.dataSource = self
        productsCollectionView.delegate = self
        inStock.delegate = self
        outofStock.delegate = self
        sortbyTextField.delegate = self
        addPadding()
        self.title = currentCategory
		
		if AppManager.currentApplicationMode() == .offline {
			self.inStock.isEnabled = false
			self.outofStock.isEnabled = false
		}
    }
    
    func setFilterImage() {
        
        let imageView = UIImageView(image: #imageLiteral(resourceName: "filter_icon"))
        imageView.contentMode = .scaleAspectFit
        self.productFilterButton.setImage(imageView.image, for: .normal)
        self.productFilterButton.setImage(imageView.image, for: .highlighted)
    }
    
    func addPadding() {
        let dropDown = self.resizeImageForPadding(UIImage(named:"downArrow1")!,dropDown: true)
        let sortButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        sortButton.setImage(dropDown, for: UIControlState())
        sortButton.addTarget(self, action: #selector(ProductListViewController.showFilterPopover), for: UIControlEvents.touchUpInside)
        sortbyTextField.rightView =  sortButton
        sortbyTextField.rightViewMode = UITextFieldViewMode.always
    }
    
    func showFilterPopover() {
        
        let dropDownMenuVc = self.storyboard?.instantiateViewController(withIdentifier: MenuPopTableViewController.selfName()) as? MenuPopTableViewController
        dropDownMenuVc?.delegate = self
        dropDownMenuVc?.contentSize = CGSize(width: CGFloat(self.sortbyTextField.frame.size.width),height: CGFloat(44 * self.numberOfMenu()))
        dropDownMenuVc?.popoverPresentationController?.permittedArrowDirections = .any
        dropDownMenuVc?.popoverPresentationController?.sourceView = self.sortbyTextField as UIView
        dropDownMenuVc?.popoverPresentationController?.sourceRect = self.sortbyTextField.bounds
        dropDownMenuVc?.popoverPresentationController?.delegate = dropDownMenuVc
        dropDownMenuVc?.sourceRect = self.sortbyTextField.bounds
        
        self.present(dropDownMenuVc!, animated: true, completion: nil)
        
    }
    
    func resizeImageForPadding(_ resizeImage:UIImage, dropDown:Bool) -> UIImage {
        if dropDown == true
        {
            UIGraphicsBeginImageContext(CGSize(width: 16, height: 16))
            resizeImage.draw(in:    CGRect(x: 4, y: 4, width: 8, height: 8))
        }
        else
        {
            UIGraphicsBeginImageContext(CGSize(width: 20, height: 20))
            resizeImage.draw(in: CGRect(x: 4, y: 4, width: 12, height: 12))
        }
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage!
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//MARK:- CheckboxDelegate
extension ProductListViewController: CheckboxDelegate {
    func checkBoxClicked(_ checked: Bool, withTag tag: Int) {
        switch tag {
        case 1:
            if self.inStock.isChecked {
                
                if AppManager.currentApplicationMode() == .online {
                    self.outofStock.isChecked = false
                    self.filterProductsSetup(withFilterType: .InStock)
                } else {
                    self.outofStock.isChecked = false
                    self.updateFetchRequest(withFilterType: .InStock)
                }
            } else {
                if AppManager.currentApplicationMode() == .online {
                    if self.fromScreenType == .category {
                        self.downloadProductsWithCategoryId(categoryId: self.selectedSubCategory)
                    } else {
                        self.filterProductsSetup(withFilterType: .None)
                    }
                } else {
                    self.updateFetchRequest(withFilterType: .None)
                }
            }
        case 2:
            if outofStock.isChecked {
                if AppManager.currentApplicationMode() == .online {
                    self.filterProductsSetup(withFilterType: .OutOfStock)
                    self.inStock.isChecked = false
                } else {
                    self.inStock.isChecked = false
                    self.updateFetchRequest(withFilterType: .OutOfStock)
                }
            } else {
                if AppManager.currentApplicationMode() == .online {
                    if self.fromScreenType == .category {
                        self.downloadProductsWithCategoryId(categoryId: self.selectedSubCategory)
                    } else {
                        self.filterProductsSetup(withFilterType: .None)
                    }
                } else {
                    self.updateFetchRequest(withFilterType: .None)
                }
            }
        case 3:
            break
        default:
            break
        }
        self.productsCollectionView.reloadData()
        checkbox = checked
    }
}

extension ProductListViewController:listDelegate{
    func selectedList(_ listValue: NSString,selectedrow:Int){
        sortbyTextField.text = listValue as String
    }
}

extension ProductListViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == sortbyTextField
        {
            textField.resignFirstResponder()
            showFilterPopover()
        }
    }
}

extension ProductListViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if AppManager.currentApplicationMode() == .online {
            return productsListInfo.count
        } else {
            return self.featchedResultsController?.sections![section].objects?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewArrivalsCollectionViewCell", for: indexPath) as! NewArrivalsCollectionViewCell
        cell.cellActionHandlerDelegate = self
        cell.goToProductDetailPageBtn.tag = indexPath.row
        cell.goToProductDetailPageBtn.addTarget(self, action: #selector(self.goToProductDetailPageTapped(sender:)), for: .touchUpInside)
        let userDefaults = UserDefaultManager.sharedManager()
        let customerGroupId = userDefaults.customerGroupId
        
        let cust_grop_id1 = NSLocalizedString("Customer_Group_Id1", comment: "")
        let cust_grop_id2 = NSLocalizedString("Customer_Group_Id2", comment: "")
        
        if AppManager.currentApplicationMode() == .online {
            let productInfo = self.productsListInfo[indexPath.row]
            self.handleWishListData(withProduInfo: nil, withCellInfo: cell, withOnlineProd: productInfo)
            self.handleCartData(withProduInfo: nil, withCellInfo: cell, withOnlineProd: productInfo)
            let nameKey = (AppManager.languageType() == .english) ? "name" : "arname"
            if let produName = productInfo[nameKey] as? String, let prodPrice = productInfo["price"] as? String, let image = productInfo["image"] {
                cell.productNameLabel.text = produName
                
                let prorperURL = image.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                let imageURLStr = URLBuilder.getImageDownloadBaseURL() + prorperURL!
                
                UploadTaskHandler.sharedInstance.setImage(onImageView: (cell.productImageView)!, withImageUrl: imageURLStr, placeHolderImage: nil)
                
                //                cell.productImageView.af_setImage(withURL: url!, placeholderImage: nil, filter: nil, imageTransition: .crossDissolve(0.5), runImageTransitionIfCached: true, completion: nil)
                
                if let quantity = productInfo["quantity"] as? String {
                    let languageId = LanguageType(rawValue: UserDefaultManager.sharedManager().selectedLanguageId!)
                    if let qty = Int(quantity) {
                        if (qty >= 1||customerGroupId==cust_grop_id1||customerGroupId==cust_grop_id2) {
                            cell.outOfStockImageView.isHidden = true
                            cell.outOfStockArabicImageView.isHidden = true
                            cell.cartButton.isEnabled = true
                        } else {
                            
                            if languageId == .english {
                                cell.outOfStockImageView.isHidden = false
                                cell.outOfStockArabicImageView.isHidden = true
                                cell.cartButton.isEnabled = false
                            } else {
                                cell.outOfStockImageView.isHidden = true
                                cell.outOfStockArabicImageView.isHidden = false
                                cell.cartButton.isEnabled = false
                            }
                        }
                    }
                }
                
                if let _ = MyCart.getProductWith(productId: productInfo["product_id"] as! String) {
                    if let normalCartImage = UIImage(named: "cart_sel_icon") {
                        cell.cartButton.setImage(normalCartImage, for: .normal)
                        cell.cartButton.setImage(normalCartImage, for: .highlighted)
                    }
                } else {
                    if let selectedCartImage = UIImage(named: "cart_prod_icon") {
                        cell.cartButton.setImage(selectedCartImage, for: .normal)
                        cell.cartButton.setImage(selectedCartImage, for: .highlighted)
                    }
                }
                
                if let price = Double(prodPrice) {
                    let roundedPrice = String(format: "%.2f", price)
                    cell.productOfferLabel.text = roundedPrice + " " + "SAR"
                }
                
                //Set Product Offers Price:
                if let specialPrice = productInfo["special"] as? String {
                    
                    if let price = Double(productInfo["price"] as? String ?? "") {
                        let roundedPrice = String(format: "%.2f", price)
                        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: roundedPrice + " " + "SAR")
                        attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))
                        attributeString.addAttribute(NSStrikethroughColorAttributeName, value: UIColor(red:164/255,green:41/255,blue:63/255,alpha:1), range: NSMakeRange(0, attributeString.length))
                        cell.productPriceLabel.attributedText =  attributeString
                    }
                    
                    if let price = Double(specialPrice) {
                        let roundedPrice = String(format: "%.2f", price)
                        cell.productOfferLabel.text = roundedPrice + " " + "SAR"
                    }
                } else {
                    cell.productPriceLabel.text = ""
                    if let price = Double(productInfo["price"] as? String ?? "") {
                        let roundedPrice = String(format: "%.2f", price)
                        cell.productOfferLabel.text = roundedPrice + " " + "SAR"
                    }
                }
            }
            
            if let specialPrice = productInfo["special"] as? String, let price = productInfo["price"] as? String {
                cell.discountProductPrice.isHidden = false
                if let actualPrice = Float(price), let specialPrice = Float(specialPrice) {
                    let difference = actualPrice - specialPrice
                    if difference > 0 {
                        let percentageDiscount = ((difference / actualPrice) * 100)
                        let finalValue = Int(round(percentageDiscount))
                        cell.discountProductPrice.text = "- " + finalValue.description + "%"
                    }
                }
            } else {
                cell.discountProductPrice.isHidden = true
            }
            
            return cell
        } else {
            if let product = self.featchedResultsController?.fetchedObjects?[indexPath.row] as? Product {
                let userSelectedLanguage = UserDefaultManager.sharedManager().selectedLanguageId
                if let languageType = LanguageType(rawValue: userSelectedLanguage!) {
                    switch languageType {
                    case .arabic:
                        cell.productNameLabel.text = product.arName
                    case .english:
                        cell.productNameLabel.text = product.productName
                    }
                }
					
					if let _ = MyCart.getProductWith(productId: product.productId!) {
						if let normalCartImage = UIImage(named: "cart_sel_icon") {
							cell.cartButton.setImage(normalCartImage, for: .normal)
							cell.cartButton.setImage(normalCartImage, for: .highlighted)
						}
					} else {
						if let selectedCartImage = UIImage(named: "cart_prod_icon") {
							cell.cartButton.setImage(selectedCartImage, for: .normal)
							cell.cartButton.setImage(selectedCartImage, for: .highlighted)
						}
					}
					
					if let _ = WishLists.getProductWith(productId: product.productId!) {
						if let heartRedImage = UIImage(named: "wishList_red") {
							cell.wishListButton.setImage(heartRedImage, for: .normal)
							cell.wishListButton.setImage(heartRedImage, for: .highlighted)
						}
					} else {
						if let heartRedImage = UIImage(named: "wishlist_prod_icon") {
							cell.wishListButton.setImage(heartRedImage, for: .normal)
							cell.wishListButton.setImage(heartRedImage, for: .highlighted)
						}
					}
					
					if let imageData = product.imageData {
						if let image = UIImage(data: imageData as Data) {
							cell.productImageView.image = image
						}
					} else {
						cell.productImageView.image = #imageLiteral(resourceName: "placeHolderImage")
					}
                //self.setProductImageTo(indexValue: indexPath.row, cell: cell, withImageURL: product.image!)
                self.checkAndApped(manufacturerId: product.manufacturerId)
                
                if product.specialPrice == "" {
                    let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: product.price.description)
                    attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))
                    attributeString.addAttribute(NSStrikethroughColorAttributeName, value: UIColor(red:164/255,green:41/255,blue:63/255,alpha:1), range: NSMakeRange(0, attributeString.length))
                    cell.productPriceLabel.attributedText = attributeString
                    cell.productOfferLabel.text = product.specialPrice
                    
                } else {
                    cell.productOfferLabel.text = product.price.description
                }
                
                if let offerPrice = product.specialPrice {
                    if offerPrice != "" {
                        cell.discountProductPrice.isHidden = false
                        let actualPrice = Float(product.price)
                        let specialPrice = Float(product.specialPrice ?? "")
                        let difference = actualPrice - specialPrice!
                        let percentageDiscount = ((difference / actualPrice) * 100)
                        let finalValue = Int(percentageDiscount)
                        cell.discountProductPrice.text = "- " + finalValue.description
                    } else {
                        cell.discountProductPrice.isHidden = true
                    }
                }
                
                let quantity = product.availability
                let languageId = LanguageType(rawValue: UserDefaultManager.sharedManager().selectedLanguageId!)
                let qty = Int(quantity)
                if (qty >= 1 || customerGroupId == "15" || customerGroupId == "16") {
                    cell.outOfStockImageView.isHidden = true
                    cell.outOfStockArabicImageView.isHidden = true
                    cell.cartButton.isEnabled = true
                } else {
                    
                    if languageId == .english {
                        cell.outOfStockImageView.isHidden = false
                        cell.outOfStockArabicImageView.isHidden = true
                        cell.cartButton.isEnabled = false
                    } else {
                        cell.outOfStockImageView.isHidden = true
                        cell.outOfStockArabicImageView.isHidden = false
                        cell.cartButton.isEnabled = false
                    }
                }
            }
            
            return cell
        }
    }
    
    //MARK: Go to product detail page
    func goToProductDetailPageTapped(sender : UIButton){
        let indexPath = IndexPath(item: sender.tag, section: 0)
        let productDetailVc = self.storyboard?.instantiateViewController(withIdentifier: "ProductDetailViewController") as!  ProductDetailViewController
        
        if AppManager.currentApplicationMode() == .online {
            productDetailVc.currentProductInfo = self.productsListInfo[indexPath.row]
            productDetailVc.fromScreenType = .banner
            self.navigationController?.pushViewController(productDetailVc, animated: true)
            
        } else {
            if let currentProduct = self.featchedResultsController?.fetchedObjects?[indexPath.row] as? Product {
                
                /*  let productInfoData = ProductData(withName: currentProduct.productName!, withProductId: currentProduct.productId!, andDescription: currentProduct.productDescription!, currentProduct.model!, currentProduct.price, prodImage: currentProduct.image!, currentProduct.isInCart, currentProduct.isProductLiked, specialPrice: currentProduct.specialPrice ?? "", availability: currentProduct.availability.description, currentProduct.arName!, currentProduct.arDescription!)  */
					productDetailVc.currentProdId = currentProduct.productId
                productDetailVc.fromScreenType = .banner
                //productDetailVc.currentProduct = productInfoData
                self.navigationController?.pushViewController(productDetailVc, animated: true)
            }
        }
    }
}

extension ProductListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //        let productDetailVc = self.storyboard?.instantiateViewController(withIdentifier: "ProductDetailViewController") as!  ProductDetailViewController
        //
        //        if let currentProduct = self.featchedResultsController?.fetchedObjects?[indexPath.row] as? Product {
        //            if AppManager.currentApplicationMode() == .offline {
        //                let productInfoData = ProductData(withName: currentProduct.productName!, withProductId: currentProduct.productId!, andDescription: currentProduct.productDescription!, currentProduct.model!, currentProduct.price.description, prodImage: currentProduct.image!, currentProduct.isInCart, currentProduct.isProductLiked, specialPrice: currentProduct.specialPrice ?? "", availability: currentProduct.availability.description, currentProduct.arName!, currentProduct.arDescription!)
        //
        //                if let cell = self.productsCollectionView.cellForItem(at: indexPath) {
        //                    if ((cell as? NewArrivalsCollectionViewCell)?.isValidTouch)! {
        //                        productDetailVc.currentProduct = productInfoData
        //                        self.navigationController?.pushViewController(productDetailVc, animated: true)
        //                    }
        //                }
        //            }
        //
        //            if AppManager.currentApplicationMode() == .online {
        //
        //                let productInfoData = ProductData(withName: currentProduct.productName!, withProductId: currentProduct.productId!, andDescription: currentProduct.productDescription!, currentProduct.model!, currentProduct.price.description, prodImage: currentProduct.image!, currentProduct.isInCart, currentProduct.isProductLiked, specialPrice: currentProduct.specialPrice ?? "", availability: currentProduct.availability.description, currentProduct.arName!, currentProduct.arDescription!)
        //
        //                if let cell = self.productsCollectionView.cellForItem(at: indexPath) {
        //                    if AppManager.currentApplicationMode() == .online {
        //                        let productInfo = self.productsListInfo[indexPath.row]
        //                        if let _ = productInfo["product_id"] as? String {
        //                            if ((cell as? NewArrivalsCollectionViewCell)?.isValidTouch)! {
        //                                productDetailVc.currentProductInfo = productInfo
        //                                productDetailVc.currentProduct = productInfoData
        //
        //                                self.navigationController?.pushViewController(productDetailVc, animated: true)
        //                            }
        //                        }
        //                    }
        //                }
        //            }
        //        }
    }
}

extension ProductListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		if UIDevice.current.userInterfaceIdiom == .pad {
			return CGSize(width: self.productsCollectionView.frame.size.width * 0.3, height: 400.0)
		} else {
			return CGSize(width: (self.productsCollectionView.frame.size.width / 2) - 10, height: 210.0)
		}
    }
}

//MARK:- Helper Methods:
extension ProductListViewController {
    
    func updateFetchRequest(withFilterType type: ProductFilterTypes) {
        if let selectedCategory = self.selectedSubCategory {
			var predicate: NSPredicate!
			if self.fromScreenType == .home {
			    predicate = NSPredicate(format: "prodCategoryId == %@", selectedCategory)
			} else {
				predicate = NSPredicate(format: "manufacturerId == %@", selectedCategory)
			}
            switch type  {
            case .LowToHigh:
                self.productsFRC = Product.mr_fetchAllSorted(by: "price",
                                                             ascending: true,
                                                             with: predicate,
                                                             groupBy: nil,
                                                             delegate: self)
            case .HighToLow:
                self.productsFRC = Product.mr_fetchAllSorted(by: "price",
                                                             ascending: false,
                                                             with: predicate,
                                                             groupBy: nil,
                                                             delegate: self)
                //            case .ByBrands:
                //                self.productsFRC = Product.mr_fetchAllSorted(by: "manufacturerId",
                //                                                             ascending: true,
                //                                                             with: predicate,
                //                                                             groupBy: nil,
                //                                                             delegate: self)
                //            case .ViewedCount:
                //                self.productsFRC = Product.mr_fetchAllSorted(by: "productViewedCount",
                //                                                             ascending: true,
                //                                                             with: predicate,
                //                                                             groupBy: nil,
            //                                                             delegate: self)
            case .None:
                self.productsFRC = Product.mr_fetchAllSorted(by: nil,
                                                             ascending: true,
                                                             with: predicate,
                                                             groupBy: nil,
                                                             delegate: self)
            case .InStock:
                let stockPredicate = NSPredicate(format: "stockStatusId == %@", "6")
                let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, stockPredicate])
                
                self.productsFRC = Product.mr_fetchAllSorted(by: nil,
                                                             ascending: true,
                                                             with: compoundPredicate,
                                                             groupBy: nil,
                                                             delegate: self)
                
            case .OutOfStock:
                let stockPredicate = NSPredicate(format: "stockStatusId == %@", "7")
                let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, stockPredicate])
                
                self.productsFRC = Product.mr_fetchAllSorted(by: nil,
                                                             ascending: true,
                                                             with: compoundPredicate,
                                                             groupBy: nil,
                                                             delegate: self)
                
            case .filterBrands:
                let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, self.compoundFilterPredicate!])
                self.productsFRC = Product.mr_fetchAllSorted(by: nil,
                                                             ascending: true,
                                                             with: compoundPredicate,
                                                             groupBy: nil,
                                                             delegate: self)
            }
            
        }
    }
    
    func getFetchResultController() -> NSFetchedResultsController<NSFetchRequestResult>? {
        return self.productsFRC
    }
    
    func setProductImageTo(indexValue index: Int, cell: NewArrivalsCollectionViewCell, withImageURL url: String) {
        
        let imageURL = url
        let prorperURL = imageURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let imageURLStr = URLBuilder.getImageDownloadBaseURL() + prorperURL!
        
        //        let url = URL(string: imageURLStr)
        
        UploadTaskHandler.sharedInstance.setImage(onImageView: (cell.productImageView)!, withImageUrl: imageURLStr, placeHolderImage: nil)
        
        //        cell.productImageView.af_setImage(withURL: url!, placeholderImage: nil, filter: nil, imageTransition: .crossDissolve(0.5), runImageTransitionIfCached: true, completion: nil)
        
    }
    
    func checkAndApped(manufacturerId Id: Int32) {
        if !(self.manufacturerIdList.contains(Id)) {
            self.manufacturerIdList.append(Id)
        }
    }
    
    func getAvailableBrandsList() -> [Brands] {
        var brandsList = [Brands]()
        
        for manufacturerId in manufacturerIdList {
            if let brandData = Brands.getBrandWith(manufacturer: manufacturerId) {
                brandsList.append(brandData)
            }
        }
        return brandsList
    }
    
    func handleWishListData(withProduInfo info: Product?, withCellInfo cell: NewArrivalsCollectionViewCell, withOnlineProd product: [String: AnyObject]? = nil) {
        var wishListInfo = [String: AnyObject]()
        if AppManager.currentApplicationMode() == .online {
            if let wishlistProdId = product?["product_id"] as? String {
                if self.checkProductIsLiked(withProdId: wishlistProdId) {
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
            if let id = info?.productId, let _ = info?.image, let name = info?.productName, let image = info?.image, let price = info?.price {
					
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
            if let cartProdId = product?["product_id"] as? String {
                if self.checkProducIsInCart(withProdId: cartProdId) {
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
            //self.delegate?.didTapCartProductButton()
            var myCartInfo = [String: AnyObject]()
            if AppManager.isUserLoggedIn {
                
//                if let cartProd = info {
//                    cartProd.isInCart = !cartProd.isInCart
//                    do {
//                        try cartProd.managedObjectContext?.save()
//                    } catch {
//                        print("Product not added to Cart")
//                    }
//                }
					
                if let id = info?.productId, let _ = info?.image, let name = info?.productName, let image = info?.image, let price = info?.price {
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
                //self.delegate?.didTapCartProductButton()
            }
        }
    }
    
    func showAlertWith(warningMsg msg: String) {
        let alertController = UIAlertController(title: NSLocalizedString("Alzahrani", comment: ""), message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (UIAlertAction) in
            let loginVc = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
            let menuNavController = UINavigationController(rootViewController: loginVc!)
            self.present(menuNavController, animated:true, completion: nil)
        })
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
	func handleShareButtonAction(withProdInfo info: Product?, orOnlineProductInfo onlineProduct: [String: AnyObject]?) {
		if AppManager.currentApplicationMode() == .online {
			var produURL = ""
			let imageURL = onlineProduct?["image"]
			let productName = onlineProduct?["name"]
			let description = onlineProduct?["description"]
			var productImageData: UIImage?
			let text = "Checkout what I found on Alzahrani"
			if let productId = onlineProduct?["product_id"] as? String {
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
																			let textToShare = [text, prorperURL ?? "", productName ?? "", description ?? "", productImageData ?? UIImage(), " ", produURL] as [Any]
																			let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
																			activityViewController.popoverPresentationController?.sourceView = self.view
																			
																			self.present(activityViewController, animated: true, completion: nil)
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
	
    func downloadProductsWithCategoryId(categoryId id: String?) {
        self.productsListInfo = []
        if let categoryId = id {
            DownloadManager.sharedDownloadManager.downloadAllProduct(withCategoryId: categoryId) { (success, response) in
                if success {
                    if let productData = response as? [[String: AnyObject]] {
                        
                        for product in productData {
                            if let productId = product["product_id"] as? Bool {
                                if productId == false {
                                    print("Invalid Product")
                                }
                            } else {
                                self.productsListInfo.append(product)
                            }
                        }
                        DispatchQueue.main.async {
                            self.productsCollectionView.reloadData()
                        }
                    }
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
    
    func handleCartProductRemove(notification: Notification) {
        if let object = notification.object as? [String: AnyObject] {
            if let cartObjectId = object["removedProduct"] as? String {
                
                if AppManager.currentApplicationMode() == .online {
                    for (index, product) in productsListInfo.enumerated() {
                        if let productId = product["product_id"] {
                            if productId as! String == cartObjectId {
                                let indexPath = IndexPath(row: index, section: 0)
                                let cell = self.productsCollectionView.cellForItem(at: indexPath)
                                
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
                        self.productsCollectionView.reloadData()
                    }
                }
            }
        }
    }
    
    func handleMyWishlistRemove(notification: Notification) {
        if let object = notification.object as? [String: AnyObject] {
            if let wishListObj = object["removedProduct"] as? String {
                
                if AppManager.currentApplicationMode() == .online {
                    for (index, product) in productsListInfo.enumerated() {
                        if let productId = product["product_id"] as? String {
                            if productId == wishListObj {
                                let indexPath = IndexPath(row: index, section: 0)
                                let cell = self.productsCollectionView.cellForItem(at: indexPath)
                                
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
                        self.productsCollectionView.reloadData()
                    }
                }
            }
        }
    }
    
    func handleWishListAdd(notification: Notification) {
        if let object = notification.object as? [String: AnyObject] {
            if let wishListObj = object["AddWishlistProd"] as? String {
                
                if AppManager.currentApplicationMode() == .online {
                    for (index, product) in productsListInfo.enumerated() {
                        if let productId = product["product_id"] as? String {
                            if productId  == wishListObj {
                                let indexPath = IndexPath(row: index, section: 0)
                                let cell = self.productsCollectionView.cellForItem(at: indexPath)
                                
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
                    for (index, product) in productsListInfo.enumerated() {
                        if let productId = product["product_id"] as? String {
                            if productId == wishListObj {
                                let indexPath = IndexPath(row: index, section: 0)
                                let cell = self.productsCollectionView.cellForItem(at: indexPath)
                                
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
    
    func setNavigationBarImage() {
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .top, barMetrics: .default)
    }
    
    func handlerProductFiltering(fromScreenType type: FromScreenType, andFilterType filterType: ProductFilterTypes) {
        switch type {
        case .banner:
            break
        case .brands:
            break
        case .category:
//					self.filterProduct(withFilterType: filterType)
					self.filterProduct(ofScreenType: .category, withFilterType: filterType)
        case .offers:
            break
        default:
            break
        }
    }
}

//MARK:- NSFetchedResultsControllerDelegate:
extension ProductListViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.productsCollectionView.reloadData()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        
        switch type {
        case .delete:
            if self.productsCollectionView.numberOfItems(inSection: indexPath!.section) == 1 {
                self.shouldReloadCollectionView = true
            } else {
                blockOperations.append(
                    BlockOperation(block: { [weak self] in
                        if let timerVc = self {
                            DispatchQueue.main.async {
                                timerVc.productsCollectionView.deleteItems(at: [indexPath!])
                            }
                        }
                    })
                )
            }
            
        case .insert:
            //            if self.BBCCollectionView.numberOfSections > 0 {
            //                if self.BBCCollectionView.numberOfItems(inSection: newIndexPath!.section) == 0 {
            //                    self.shouldReloadCollectionView = true
            //                } else {
            //                    blockOperations.append(
            //                        BlockOperation(block: { [weak self] in
            //                            if let timerVc = self {
            //                                DispatchQueue.main.async {
            //                                    timerVc.BBCCollectionView.insertItems(at: [newIndexPath!])
            //                                }
            //                            }
            //                        })
            //                    )
            //                }
            //            }
            break
        case .move:
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let timerVc = self {
                        DispatchQueue.main.async {
                            timerVc.productsCollectionView.moveItem(at: indexPath!, to: newIndexPath!)
                        }
                    }
                })
            )
        case .update:
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let timerVc = self {
                        DispatchQueue.main.async {
                            timerVc.productsCollectionView.reloadItems(at: [indexPath!])
                        }
                    }
                })
            )
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if self.shouldReloadCollectionView {
            DispatchQueue.main.async {
                self.productsCollectionView.reloadData()
            }
        } else {
            
            DispatchQueue.main.async {
                self.productsCollectionView.performBatchUpdates({
                    for operations in self.blockOperations {
                        operations.start()
                    }
                }, completion: { (finished) in
                    self.blockOperations.removeAll(keepingCapacity: false)
                })
            }
        }
    }
}

//MARK:- Check Product Availability:
extension ProductListViewController {
    func validateProductData() {
        if (self.featchedResultsController?.fetchedObjects?.count)! > 0 {
            ProgressIndicatorController.showLoading()
        } else {
            self.productsCollectionView.reloadData()
        }
    }
    
    func addNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(ProductListViewController.reloadUI), name: Notification.Name("ProductsDownloadSuccessNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ProductListViewController.updatePredicateForSlectedBrands), name: Notification.Name(Constants.filteredBrandsDictNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ProductListViewController.handleCartProductRemove), name: Notification.Name("MyCartUpdateNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ProductListViewController.handleMyWishlistRemove), name: Notification.Name("WishListUpdateNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ProductListViewController.handleWishListAdd), name: Notification.Name("WishListAddNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ProductListViewController.handleCartAddNotification), name: Notification.Name("CartAddNotification"), object: nil)
        
    }
    
    func reloadUI() {
        self.productsCollectionView.reloadData()
    }
    
    func updatePredicateForSlectedBrands(notification: Notification) {
        
        if let notificationObject = notification.object as? [String: AnyObject] {
            if let brandsDict = notificationObject[Constants.selectedBrands] as? [BrandsData] {
                var predicateArray = [NSPredicate]()
                for filteredBrands in brandsDict {
                    let predicate = NSPredicate(format: "manufacturerId = %@", filteredBrands.manufactureID!)
                    predicateArray.append(predicate)
                }
                let compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicateArray)
                self.compoundFilterPredicate = compoundPredicate
                self.updateFetchRequest(withFilterType: .filterBrands)
                self.reloadUI()
            }
        }
    }
}

//MARK:- MenuPopViewControllerDelegate
extension ProductListViewController: MenuPopViewControllerDelegate {
    
    func numberOfMenu() -> Int {
        return ProductFilterTypes.caseValues.count
    }
    
    func menuNameAtIndexPath(indexPath: IndexPath) -> String {
        let textString = ProductFilterTypes.caseValues[indexPath.row].rawValue
		let filrNerName = NSLocalizedString(textString, comment: "")
        return filrNerName
    }
    
	func didSelectMenuAtIndexPath(indexPath: IndexPath, menuController: MenuPopTableViewController) {
		let textString = ProductFilterTypes.caseValues[indexPath.row].rawValue
		self.sortbyTextField.text = NSLocalizedString(textString, comment: "")
		self.inStock.isChecked = false
		self.outofStock.isChecked = false
		let selectedFileterType = ProductFilterTypes.caseValues[indexPath.row]
		if AppManager.currentApplicationMode() == .online {
			self.filterProduct(ofScreenType: self.fromScreenType, withFilterType: selectedFileterType)
		} else {
			self.updateFetchRequest(withFilterType: selectedFileterType)
			self.productsCollectionView.reloadData()
		}
	}
}

extension ProductListViewController: CellButtonActionProtocol {
    
    func didTapShareButton(atCell cell: NewArrivalsCollectionViewCell) {
			if AppManager.currentApplicationMode() == .online {
				if let indexPath = self.productsCollectionView.indexPath(for: cell) {
						let shareProduct = self.productsListInfo[indexPath.row]
						self.handleShareButtonAction(withProdInfo: nil, orOnlineProductInfo: shareProduct)
				}
			} else {
				if let indexPath = self.productsCollectionView.indexPath(for: cell) {
					if let shareProduct = self.featchedResultsController?.fetchedObjects?[indexPath.row] as? Product {
						print("Sharing \(shareProduct.productName)")
						self.handleShareButtonAction(withProdInfo: shareProduct, orOnlineProductInfo: nil)
					}
				}
			}
    }
	
    func didTapCartButton(atCell cell: NewArrivalsCollectionViewCell) {
        var cartListInfo = [String: AnyObject]()
        
        if AppManager.isUserLoggedIn {
            if AppManager.currentApplicationMode() == .online {
                if let indexPath = self.productsCollectionView.indexPath(for: cell) {
                    let cartProd = self.productsListInfo[indexPath.row]
                    if let cartProdName = cartProd["name"] as? String, let prodId = cartProd["product_id"] {
                        cartListInfo["name"] = cartProdName as AnyObject?
                        cartListInfo["product_id"] = prodId as AnyObject?
                        print("Prime Cart  1")
                        if ((AppManager.isUserLoggedIn) && (!self.checkProducIsInCart(withProdId: prodId as! String))) {
                            UploadTaskHandler.sharedInstance.uploadIndividualMyCartData(withProductId: prodId as? String, withHandler: { (success, cartId)
                                in
                                if success {
                                    print("Prime Cart  2")
                                    cartListInfo["cart_id"] = cartId as AnyObject?
                                    let _ = MyCart.addProductToMyCartList(data: cartListInfo)
                                    self.handleCartData(withProduInfo: nil, withCellInfo: cell, withOnlineProd: cartListInfo)
                                    ALAlerts.showToast(message: "Item added to cart.")
                                    cell.cartButton.isEnabled = true
                                } else {
                                    print("Prime Cart--- : \(success)")
                                    print("Prime Cart--- : \(cartId)")
                                    
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
                                            
                                            ALAlerts.showToast(message: "Item removed from cart.")
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
                    self.handleCartData(withProduInfo: nil, withCellInfo: cell, withOnlineProd: cartListInfo)
                }
            } else {
                if let indexPath = self.productsCollectionView.indexPath(for: cell) {
                    if let cartProd = self.featchedResultsController?.fetchedObjects?[indexPath.row] as? Product {
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
							}
							
							cell.cartButton.isEnabled = true
//							do {
//								try cartProd.managedObjectContext?.save()
//								cartProd.managedObjectContext?.mr_saveToPersistentStoreAndWait()
//							} catch let error {
//								print("Error Saving Cart Object \(error.localizedDescription)")
//							}
						 }
                }
            }
        } else {
			let loginAlert = NSLocalizedString("LOGIN_ALERT_PROMPT", comment: "")
            self.showAlertWith(warningMsg: loginAlert)
						cell.cartButton.isEnabled = true
        }
    }
    
    func didTapWishlistButton(atCell cell: NewArrivalsCollectionViewCell) {
			if AppManager.isUserLoggedIn {
				var wishListInfo = [String: AnyObject]()
				if AppManager.currentApplicationMode() == .online {
					if let indexPath = self.productsCollectionView.indexPath(for: cell) {
						let wishlistProd = self.productsListInfo[indexPath.row]
						if let cartProdName = wishlistProd["name"] as? String, let prodId = wishlistProd["product_id"] {
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
										let _ = WishLists.removeProduct(withId: cartProdId)
										
										UploadTaskHandler.sharedInstance.deleteWishListData(withProductId: cartProdId, withHandler: { (success) in
											if success {
												let _ = WishLists.removeProduct(withId: cartProdId)
												ALAlerts.showToast(message: "Item removed From Wishlist.")
												self.handleWishListData(withProduInfo: nil, withCellInfo: cell, withOnlineProd: wishListInfo)
												cell.wishListButton.isEnabled = true
											}
										})
									}
								}
							}
						}
					}
				} else {
					if let indexPath = self.productsCollectionView.indexPath(for: cell) {
						if let wishListProduct = self.featchedResultsController?.fetchedObjects?[indexPath.row] as? Product {
						    self.handleWishListData(withProduInfo: wishListProduct, withCellInfo: cell)
							cell.wishListButton.isEnabled = true
						}
					}
				}
			} else {
					cell.wishListButton.isEnabled = true
			}
    }
}

//MARK:- Product Filtering Methods:
extension ProductListViewController {
	
		func filterProduct(ofScreenType screenType: FromScreenType, withFilterType type: ProductFilterTypes) {
        self.productsListInfo = []
			switch screenType {
			case .banner:
				self.downloadProductFromBanner(category_id: self.bannerBrandId, brandName: self.bannerBrandName, withFiletType: type)
			case .brands:
				self.downloadProductsForBrand(category_id: self.brandsId, brandName: self.brandName, withFiletType: type)
			case .category:
				self.handleCategoryProductFiltering(withFilterType: type)
			case .home:
				break
			case .offers:
				self.downloadOfferZoneProduct(category_id: self.offerBrandId, withFiletType: type)
			case .search:
				break
			}
    }
    
    func filterBrandProducts(withFilterType type: ProductFilterTypes) {
        
    }
    
    func filterOfferProducts(withFilterType type: ProductFilterTypes) {
        
    }
    
    func filterBannerProducts(withFilterType type: ProductFilterTypes) {
        
    }
	
		func handleCategoryProductFiltering(withFilterType type: ProductFilterTypes) {
			var syncParam = ""
			let custGrpIdStr = UserDefaultManager.sharedManager().customerGroupId
			if let prodId = self.selectedSubCategory, let custGrpId = custGrpIdStr {
				switch type {
				case .InStock:
					syncParam = "\(prodId)&customer_group_id=\(custGrpId)&availability=1"
				case .OutOfStock:
					syncParam = "\(prodId)&customer_group_id=\(custGrpId)&availability=0"
				case .HighToLow:
					syncParam = "\(prodId)&customer_group_id=\(custGrpId)&order=DESC"
				case .LowToHigh:
					syncParam = "\(prodId)&customer_group_id=\(custGrpId)&order=ASC"
				default:
					break
				}
				ProgressIndicatorController.showLoading()
				SyncManager.syncOperation(operationType: .getFilteredProducts, info: syncParam, completionHandler: { (response, error) in
					if error == nil {
						ProgressIndicatorController.dismissProgressView()
						print("Filtered Products: \(response)")
						if let productData = response as? [[String: AnyObject]] {
							for product in productData {
								if let productId = product["product_id"] as? Bool {
									if productId == false {
										print("Invalid Product")
									}
								} else {
									self.productsListInfo.append(product)
								}
							}
							DispatchQueue.main.async {
								self.productsCollectionView.reloadData()
							}
						}
					} else {
						ProgressIndicatorController.dismissProgressView()
						print("Error : \(error?.localizedDescription)")
					}
				})
			}
		}
}


extension ProductListViewController {
	
    func filterProductsSetup(withFilterType filterType: ProductFilterTypes) {
        switch self.fromScreenType {
        case .banner:
            self.downloadProductFromBanner(category_id: self.bannerBrandId, brandName: self.bannerBrandName, withFiletType: filterType)
        case .category:
//            self.filterProduct(withFilterType: filterType)
						self.filterProduct(ofScreenType: .category, withFilterType: filterType)
        case .offers:
            self.downloadOfferZoneProduct(category_id: self.offerBrandId, withFiletType: filterType)
        case .brands:
            self.downloadProductsForBrand(category_id: self.brandsId, brandName: self.brandName, withFiletType: filterType)
        default:
            break
        }
    }
    
	func initialDownloadSetup() {
		switch self.fromScreenType {
		case .banner:
			self.downloadProductFromBanner(category_id: self.bannerBrandId, brandName: self.bannerBrandName)
		case .category:
			self.downloadProductsWithCategoryId(categoryId: self.selectedSubCategory)
		case .offers:
			self.downloadOfferZoneProduct(category_id: self.offerBrandId)
		case .brands:
			self.downloadProductsForBrand(category_id: self.brandsId, brandName: self.brandName)
		default:
			break
		}
	}
	
    //Download Banner Products:
	func downloadProductFromBanner(category_id id: String, brandName name: String, withFiletType filterType: ProductFilterTypes? = nil) {
		var syncDataFormat = ""
		ProgressIndicatorController.showLoading()
		let catId=Int(id)
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
			let customerGroupId = AppManager.getCustGroupId()
			print("Language is: \(languageId)")
			if let languageId = languageId {
				if let filterType = filterType {
					if filterType == .InStock {
						syncDataFormat = "\(catId!)&customer_group_id=\(customerGroupId)&language_id=\(languageId)&availability=1"
					} else if filterType == .OutOfStock {
						syncDataFormat = "\(catId!)&customer_group_id=\(customerGroupId)&language_id=\(languageId)&availability=0"
					} else if filterType == .HighToLow {
						syncDataFormat = "\(catId!)&customer_group_id=\(customerGroupId)&language_id=\(languageId)&order=DESC"
					} else if filterType == .LowToHigh {
						syncDataFormat = "\(catId!)&customer_group_id=\(customerGroupId)&language_id=\(languageId)&order=ASC"
					}else {
						syncDataFormat = "\(catId!)&customer_group_id=\(customerGroupId)&language_id=\(languageId)"
					}
				} else {
					syncDataFormat = "\(catId!)&customer_group_id=\(customerGroupId)&language_id=\(languageId)"
				}
				SyncManager.syncOperation(operationType: .getAllProducts, info: syncDataFormat, completionHandler: { (response, error) in
					if error == nil {
						ProgressIndicatorController.dismissProgressView()
						self.productsListInfo = []
						if let productData = response as? [[String: AnyObject]] {
							for product in productData {
								if let productId = product["product_id"] as? Bool {
									if productId == false {
										print("Invalid Product")
									}
								} else {
									self.productsListInfo.append(product)
								}
							}
							DispatchQueue.main.async {
								self.productsCollectionView.reloadData()
							}
						}
					} else {
						ProgressIndicatorController.dismissProgressView()
						print("Response error: \(error)")
					}
				})
			} else {
				ProgressIndicatorController.dismissProgressView()
			}
		} else {
			ProgressIndicatorController.dismissProgressView()
		}
	}
	
    //Download OfferZone Products:
    func downloadOfferZoneProduct(category_id:String, withFiletType filterType: ProductFilterTypes? = nil) {
        var syncDataFormat = ""
        let catId=Int(category_id)
        ProgressIndicatorController.showLoading()
        let userDefaults = UserDefaultManager.sharedManager()
        if let customerGroupId = userDefaults.customerGroupId {
            if let filterType = filterType {
                if filterType == .InStock {
                    syncDataFormat = "&category_id=\(catId!)&customer_group_id=\(customerGroupId)&availability=1"
                } else if filterType == .OutOfStock {
                    syncDataFormat = "&category_id=\(catId!)&customer_group_id=\(customerGroupId)&availability=0"
								} else if filterType == .HighToLow {
									syncDataFormat = "&category_id=\(catId!)&customer_group_id=\(customerGroupId)&order=DESC"
								} else if filterType == .LowToHigh {
									syncDataFormat = "&category_id=\(catId!)&customer_group_id=\(customerGroupId)&order=ASC"
								} else {
                    syncDataFormat = "&category_id=\(catId!)&customer_group_id=\(customerGroupId)"
                }
            } else {
                syncDataFormat = "&category_id=\(catId!)&customer_group_id=\(customerGroupId)"
            }
            SyncManager.syncOperation(operationType: .getAllProducts, info: syncDataFormat) { (response, error) in
                if error == nil {
                    ProgressIndicatorController.dismissProgressView()
                    self.productsListInfo = []
                    if let productData = response as? [[String: AnyObject]] {
                        for product in productData {
                            if let productId = product["product_id"] as? Bool {
                                if productId == false {
                                    print("Invalid Product")
                                }
                            } else {
                                self.productsListInfo.append(product)
                            }
                        }
                        DispatchQueue.main.async {
                            self.productsCollectionView.reloadData()
                        }
                    }
                } else {
                    ProgressIndicatorController.dismissProgressView()
                    print("Response error: \(error)")
                }
            }
        }
    }
    
    func downloadProductsForBrand(category_id: String, brandName: String, withFiletType filterType: ProductFilterTypes? = nil) {
        var syncDataFormat = ""
        let catId=Int(category_id)
        ProgressIndicatorController.showLoading()
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
                    
                    if let filterType = filterType {
                        if filterType == .InStock {
                            syncDataFormat = "&manufacture_name=\(brandName)&category_id=\(catId!)&customer_group_id=\(customerGroupId)&language_id=\(languageId)&availability=1"
                        } else if filterType == .OutOfStock {
                            syncDataFormat = "&manufacture_name=\(brandName)&category_id=\(catId!)&customer_group_id=\(customerGroupId)&language_id=\(languageId)&availability=0"
												} else if filterType == .HighToLow {
													syncDataFormat = "&manufacture_name=\(brandName)&category_id=\(catId!)&customer_group_id=\(customerGroupId)&language_id=\(languageId)&order=DESC"
												} else if filterType == .LowToHigh {
													syncDataFormat = "&manufacture_name=\(brandName)&category_id=\(catId!)&customer_group_id=\(customerGroupId)&language_id=\(languageId)&order=ASC"
												} else {
                            syncDataFormat = "&category_id=\(catId!)&customer_group_id=\(customerGroupId)"
                        }
                    } else {
                        syncDataFormat = "&manufacture_name=\(brandName)&category_id=\(catId!)&customer_group_id=\(customerGroupId)&language_id=\(languageId)"
                    }
    
                    SyncManager.syncOperation(operationType: .getProductsFromBrandNameData, info: syncDataFormat, completionHandler: { (response, error) in
                        if error == nil {
                            ProgressIndicatorController.dismissProgressView()
                            self.productsListInfo = []
                            if let productData = response as? [[String: AnyObject]] {
                                for product in productData {
                                    if let productId = product["product_id"] as? Bool {
                                        if productId == false {
                                            print("Invalid Product")
                                        }
                                    } else {
                                        self.productsListInfo.append(product)
                                    }
                                }
                                DispatchQueue.main.async {
                                    self.productsCollectionView.reloadData()
                                }
                            }
                        } else {
                            ProgressIndicatorController.dismissProgressView()
                            print("Response error: \(error)")
                        }
                    })
                }
            }
        }
    }
}


//MARK:- Cart Helper Methods:
extension ProductListViewController {
	
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
