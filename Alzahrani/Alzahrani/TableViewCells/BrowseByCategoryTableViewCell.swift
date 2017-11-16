//
//  BrowseByCategoryTableViewCell.swift
//  Alzahrani
//
//  Created by Hardwin on 03/05/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit
import CoreData

protocol BBCTapHandlerProtocol: NSObjectProtocol {
    func collectionCellTapped(at indexPath: IndexPath, ofCell cell: UITableViewCell)
}

typealias CellTapCallBack = ((_ success: Bool, _ id: String, _ product: [String: AnyObject]?) -> Void)

class BrowseByCategoryTableViewCell: UITableViewCell {
    
    //MARK:- IB-Outlets:-
    @IBOutlet weak var BBCCollectionView: UICollectionView!
    
    
    //MARK:- Properties:-
    //    weak var delegate: BBCTapHandlerProtocol?
    var cellTapCallback: CellTapCallBack?
    var productCategories = [ProductCategory]()
    var categoriesInfo = [[String: AnyObject]]()
    
    //MARK:- Life Cycle:-
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = UIColor(rgba: "EBEBF1")
        //self.getCategoriesList()
		
        self.addNotificationObservers()
        self.setupCollectionView()
        //self.handleOnlineProductDownload()
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
extension BrowseByCategoryTableViewCell {
    
    func addNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(BrowseByCategoryTableViewCell.reloadUI), name: Notification.Name("CategoryDownloadSuccessNotification"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(BrowseByCategoryTableViewCell.reloadUI), name: Notification.Name("ProductCategorySaveSuccessNotification"), object: nil)
    }
    
    func reloadUI() {
        if self.productCategories.count == 0 {
            self.productCategories = []
            self.productCategories = ProductCategory.getAllProducts()!
        }
        self.sortCategories()
        self.BBCCollectionView.reloadData()
    }
    
    func setupCollectionView() {
        let nib = UINib(nibName: "BrowseByCategoryCollectionViewCell", bundle: nil)
        self.BBCCollectionView.register(nib, forCellWithReuseIdentifier: "BrowseByCategoryCollectionViewCell")
        self.BBCCollectionView.backgroundColor = UIColor.clear
        self.BBCCollectionView.dataSource = self
        self.BBCCollectionView.delegate = self
    }
    
    func getCategoriesList() {
        let productsCount = ProductCategory.mr_findAll()?.count
        if productsCount! <= 0 {
            //            ProgressIndicatorController.showLoading()
            DownloadManager.sharedDownloadManager.getAllProductCategories(param: "", completionHandler: { (success, result) in
                if success {
                    DispatchQueue.main.async {
                        self.BBCCollectionView.reloadData()
                    }
                }
            })
        }
    }
    
    func handleOnlineProductDownload() {
        
        if AppManager.currentApplicationMode() == .offline {
            self.getAllCategories()
        } else {
            self.downloadAllCategories(withSuccesshandler: { (success) in
                DispatchQueue.main.async {
                    self.BBCCollectionView.reloadData()
                }
            })
        }
    }
    
    func downloadAllCategories(withSuccesshandler successHandler: DownloadCompletion? = nil) {
        let appLanguageId = (AppManager.languageType() == .english) ? "1" : "2"
        
        SyncManager.syncOperation(operationType: .getProductsList, info: appLanguageId) { (response, error) in
            if error == nil {
                
                successHandler?(true)
                if let responseData = response as? [[String: AnyObject]] {
                    DispatchQueue.main.async {
                        self.categoriesInfo = responseData
                    }
                }
            } else {
                successHandler?(false)
            }
        }
    }

    func getAllCategories() {
        if let categories = ProductCategory.getAllProducts() {
           self.productCategories = categories
            self.sortCategories()
        }
    }
    
    func sortCategories() {
        var tempArray = [ProductCategory]()
       
        for categories in self.productCategories {
            if categories.categoryId == "94" {
                tempArray.append(categories)
            } else {
                continue
            }
        }
        for categories in self.productCategories {
            if categories.categoryId != "94" {
                tempArray.append(categories)
            } else {
                continue
            }
        }
        self.productCategories = tempArray
    }
    
    func downloadImageForCells(cell: BrowseByCategoryCollectionViewCell?, withIndexPath indexPath: IndexPath) {
        var categoryImageURL : String = ""
        if AppManager.currentApplicationMode() == .online {
            
            let currentCategory = self.categoriesInfo[indexPath.row]
            if let imageURL = currentCategory["image"] as? String {
                categoryImageURL = imageURL
            }
        } else {
            let currentCategory = self.productCategories[indexPath.row]
			if let imageURL = currentCategory.imageURL {
					categoryImageURL = imageURL
			}
        }
        
        let prorperURL = categoryImageURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            
        let imageURLStr = URLBuilder.getImageDownloadBaseURL() + prorperURL!
            //let url = URL(string: imageURLStr)
        
        UploadTaskHandler.sharedInstance.setImage(onImageView: (cell?.productImageView1)!, withImageUrl: imageURLStr, placeHolderImage: nil)
        
//            cell?.productImageView1.af_setImage(withURL: url!, placeholderImage: nil, filter: nil, imageTransition: .crossDissolve(0.5), runImageTransitionIfCached: true, completion: nil)
    }
    
    func setScrollDirection() {
        let indexPath = IndexPath(item: 0, section: 0)
        if AppManager.languageType() == .arabic {
			
            self.BBCCollectionView.scrollToItem(at: indexPath, at: .right, animated: true)
        } else {
            self.BBCCollectionView.scrollToItem(at: indexPath, at: .left, animated: true)
        }
    }
    
    func setDataSource(withData data: [[String: AnyObject]]) {
        self.categoriesInfo = data
    }
}

//MARK:- UICollectionViewDataSource:
extension BrowseByCategoryTableViewCell: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
		self.BBCCollectionView.collectionViewLayout.invalidateLayout()
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if AppManager.currentApplicationMode() == .online {
            return self.categoriesInfo.count
        } else {
            return self.productCategories.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //collectionView.semanticContentAttribute = .forceRightToLeft
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BrowseByCategoryCollectionViewCell", for: indexPath) as? BrowseByCategoryCollectionViewCell
        
        if AppManager.currentApplicationMode() == .online {
            let mainCategory = self.categoriesInfo[indexPath.row]
            if let categoryName = mainCategory["name"] as? String, let categoryId = mainCategory["category_id"] as? String, let imageURL = mainCategory["image"] as? String {
                cell?.prodcutNameLebel1.text = categoryName
                self.downloadImageForCells(cell: cell, withIndexPath: indexPath)
            }
            
            return cell!
        } else {
            let mainCategoriesData = self.productCategories[indexPath.row]
            cell?.prodcutNameLebel1.text = mainCategoriesData.name
			if let productImageData = mainCategoriesData.imageData {
				if let categoryImage = UIImage(data: productImageData as Data) {
					cell?.productImageView1.image = categoryImage
				} else {
					cell?.productImageView1.image = #imageLiteral(resourceName: "placeHolderImage")
				}
			}
            self.downloadImageForCells(cell: cell, withIndexPath: indexPath)
            return cell!
        }
    }
}

//MARK:- UICollectionViewDelegate:
extension BrowseByCategoryTableViewCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Item selected at \(indexPath.row)")
        if AppManager.currentApplicationMode() == .online {
            let category = self.categoriesInfo[indexPath.row]
            if let categoryId = category["category_id"] as? String {
                if self.cellTapCallback != nil {
                    self.cellTapCallback?(true, categoryId, category)
                }
            }
        } else {
            let selectedCategory = self.productCategories[indexPath.row]
            print("Selected Category is \(selectedCategory.categoryId)")
            
            if self.cellTapCallback != nil {
                self.cellTapCallback?(true, selectedCategory.categoryId!, nil)
            }
        }
    }
}

//MARK:- UICollectionViewDelegateFlowLayout:
extension BrowseByCategoryTableViewCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		
        if indexPath.item == 0 {
            return CGSize(width: (self.frame.size.width) / 2, height: self.frame.size.height)
        } else {
            return CGSize(width: (self.frame.size.width) / 2, height: (self.frame.size.height) / 2)
        }
    }
}
