//
//  BrandsViewController.swift
//  Alzahrani
//
//  Created by shilpa shree on 5/24/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class BrandsViewController: UIViewController {
    //MARK:- Outlets
    @IBOutlet weak var brandTableView: UITableView!
    @IBOutlet weak var currentBrandImageView: UIImageView!
    
    
    //MARK:- properties
    var brandCategoryArray = NSMutableArray()
    var sectionHeaderArray = [SectionHeaderInfo]()
    var selectedIndex: Int?
    var indexValue: Int = 0
    var selectedBrand: Brands?
    var selectedBrandId: String?
    var selectedBrandName: String?
    var selectedBrandImage: String?
    var subCategoriesData: [SubCategories]?
    var _nestedSubCatArray: [NestedSubCategory]?
    var nestedSubCategories: [NestedSubCategory]? {
        get {
            return _nestedSubCatArray
        } set {
            if let newValue = newValue {
                self._nestedSubCatArray = newValue
                self.brandTableView.reloadData()
            }
        }
    }
    
    var subCategoriesInfo = [[String: AnyObject]]()
    var nestedCategoriesInfo = [[String: AnyObject]]()
    var brandsListInfo = [[String: AnyObject]]()
    
    //MARK:- Life Cycle:
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setCurrentBrandImage()
        self.registerCustomTableCellNibs()
        initialSetup()
        getSubCategoryDataSource()
        self.downloadBrandSubCategories(withCategoryId: self.selectedBrandId)
        self.title = self.selectedBrandName
        self.setNavigationBarImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarImage()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.removeNavigationBarImage()
    }
}

//MARK:- Helper Methods
extension BrandsViewController {
    
    func removeNavigationBarImage() {
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .top, barMetrics: .default)
    }
    
    func getSubCategoryDataSource() {
        
        if let categoryId = self.selectedBrandId {
            self.subCategoriesData = SubCategories.getSubCategoriesBy(parentId: categoryId)
        }
    }
    
    func downloadBrandSubCategories(withCategoryId id: String?) {
        if let categoryId = id {
            
            let appLanguageId = (AppManager.languageType() == .english) ? "1" : "2"
            if AppManager.currentApplicationMode() == .online {
                let syncParam = id! + "&language_id=\(appLanguageId)"
                ProgressIndicatorController.showLoading()
                SyncManager.syncOperation(operationType: .getProductSubCategories, info: syncParam) { (response, error) in
                    ProgressIndicatorController.dismissProgressView()
                    if error == nil {
                        if let responseData = response as? [[String: AnyObject]] {
                            print("Response sub cat: \(responseData)")
                            DispatchQueue.main.async {
                                self.subCategoriesInfo = responseData
                                self.brandTableView.reloadData()
                            }
                        }
                    }
                }
            } else {
                if let subCategories = SubCategories.getSubCategoriesBy(parentId: categoryId), subCategories.count == 0 {
                    ProgressIndicatorController.showLoading()
                    if let languageType = LanguageType(rawValue: UserDefaultManager.sharedManager().selectedLanguageId!) {
                        switch languageType {
                        case .arabic:
                            let param = categoryId + "&language_id=\("2")"
                            DownloadManager.sharedDownloadManager.downloadSubCategories(withParams: param, completionhandler: { (success, result) in
                                ProgressIndicatorController.dismissProgressView()
                                if success {
                                    
                                    self.subCategoriesData = []
                                    self.subCategoriesData = SubCategories.getSubCategoriesBy(parentId: categoryId)
                                    self.brandTableView.reloadData()
                                }
                            })
                        case .english:
                            let param = categoryId + "&language_id=\("1")"
                            DownloadManager.sharedDownloadManager.downloadSubCategories(withParams: param, completionhandler: { (success, result) in
                                ProgressIndicatorController.dismissProgressView()
                                if success {
                                    self.subCategoriesData = []
                                    self.subCategoriesData = SubCategories.getSubCategoriesBy(parentId: categoryId)
                                    self.brandTableView.reloadData()
                                }
                            })
                        }
                    }
                }

            }
        }
    }
    
    func fetchNestedCategoryWith(parentId id: String) {
        
        if let productsArray = NestedSubCategory.getAllNestedCategoriesWith(parentId: id) {
            self.nestedSubCategories = productsArray
        }
    }
    
    func downloadImageForBrandWithId() {
        if let selectedBrand = Brands.getBrandWith(id: selectedBrandId!) {
            if let imageURL = selectedBrand.brandImage {
                let prorperURL = imageURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                SyncManager.syncOperation(operationType: .imageDownloadOperation, info: prorperURL,
                                          completionHandler: { (imageData, error) in
                                            if error == nil {
                                                DispatchQueue.main.async {
                                                    self.currentBrandImageView.image = UIImage(data: imageData as! Data)
                                                }
                                            }
                })
            }
        }
    }
    
    func setCurrentBrandImage() {
        if AppManager.currentApplicationMode() == .online {
            let prorperURL = self.selectedBrandImage?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            let imageURLStr = URLBuilder.getImageDownloadBaseURL() + prorperURL!
            
            UploadTaskHandler.sharedInstance.setImage(onImageView: (currentBrandImageView)!, withImageUrl: imageURLStr, placeHolderImage: nil)
        } else {
            if let currentBrand = Brands.getBrandWith(id: self.selectedBrandId!) {
                if let image = currentBrand.brandImageData {
                    if let brandImage = UIImage(data: image as Data) {
                        self.currentBrandImageView.image = brandImage
                    }
                }
            }
        }
   }
    
    func initialSetup() {
        brandCategoryArray = ["section1","section2","section3"]
        brandTableView.delegate = self
        brandTableView.dataSource = self
    }
    
    func registerCustomTableCellNibs() {

        let nib5 = UINib(nibName: "NewArrivalsTableViewCell", bundle: nil)
        self.brandTableView.register(nib5, forCellReuseIdentifier: "NewArrivalsTableViewCell")
        let nib6 = UINib(nibName: "MostCellingTableViewCell", bundle: nil)
        self.brandTableView.register(nib6, forCellReuseIdentifier: "MostCellingTableViewCell")
        
        let sectionHeaderNib = UINib(nibName: "ExpandableSectionsView", bundle: nil)
        self.brandTableView.register(sectionHeaderNib, forHeaderFooterViewReuseIdentifier: "ExpandableSectionsView")
    }
    
    func downloadNestedCategoriesWith(categoryId id: String, withCompletion completionHandler: DownloadCompletion? = nil) {
        let appLanguageId = (AppManager.languageType() == .english) ? "1" : "2"
        let syncFormat = id + "&language_id=\(appLanguageId)"
        ProgressIndicatorController.showLoading()
        SyncManager.syncOperation(operationType: .getNestedSubCategories, info: syncFormat) {
            (response, error) in
            ProgressIndicatorController.dismissProgressView()
            if error == nil {
                
                if let reponseData = response as? [[String: AnyObject]] {
                    DispatchQueue.main.async {
                        self.nestedCategoriesInfo = reponseData
                        completionHandler?(true)
                    }
                }
            } else {
                completionHandler?(false)
            }
        }
    }
    
    func setNavigationBarImage() {
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
    }
}

//MARK:- UITableViewDataSource
extension BrandsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if AppManager.currentApplicationMode() == .online {
            return subCategoriesInfo.count
        } else {
            return self.subCategoriesData!.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == self.selectedIndex {
            if AppManager.currentApplicationMode() == .online {
                return nestedCategoriesInfo.count
            } else {
                return self.nestedSubCategories!.count
            }
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BrandsCategoriesTableViewCell.selfName(), for: indexPath) as? BrandsCategoriesTableViewCell
        if AppManager.currentApplicationMode() == .online {
            
            let nestedSubCategoryObj = self.nestedCategoriesInfo[indexPath.row]
            if let name = nestedSubCategoryObj["name"] as? String {
                
                cell?.brandsCategoriesLabel?.text = name
            }
			
			if UIDevice.current.userInterfaceIdiom == .pad {
				cell?.brandsCategoriesLabel?.font = UIFont.systemFont(ofSize: 18.0)
				cell?.brandsCategoriesLabel?.textAlignment = .natural

			} else {
				cell?.brandsCategoriesLabel?.font = UIFont.systemFont(ofSize: 12.0)
				cell?.brandsCategoriesLabel?.textAlignment = .natural
			}
            return cell!
        } else  {
            cell?.brandsCategoriesLabel?.text = self.nestedSubCategories?[indexPath.row].name
			
			if UIDevice.current.userInterfaceIdiom == .pad {
				cell?.brandsCategoriesLabel?.font = UIFont.systemFont(ofSize: 18.0)
				cell?.brandsCategoriesLabel?.textAlignment = .natural
				
			} else {
				cell?.brandsCategoriesLabel?.font = UIFont.systemFont(ofSize: 12.0)
				cell?.brandsCategoriesLabel?.textAlignment = .natural
			}
            return cell!
        }
    }
}

//MARK:- UITableViewDelegate
extension BrandsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
		if UIDevice.current.userInterfaceIdiom == .pad {
			return 50.0
		} else {
			return 35.0
		}
    }
	
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let expenadbleSectionHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ExpandableSectionsView") as? ExpandableSectionsView
        expenadbleSectionHeader?.sectionDelegate = self
        expenadbleSectionHeader?.moreButton.tag = section
        
        if AppManager.currentApplicationMode() == .online {
            let subCategoryObj = self.subCategoriesInfo[section]
            if let sunCategoryName = subCategoryObj["name"] as? String {
                expenadbleSectionHeader?.subCategoryName.text = sunCategoryName
            }
        } else {
            expenadbleSectionHeader?.subCategoryName.text = self.subCategoriesData?[section].name
        }
        let sectionData = SectionHeaderInfo(withNumberOfRows: section, isTapped: false)
        self.sectionHeaderArray.append(sectionData)
		
		if UIDevice.current.userInterfaceIdiom == .pad {
			expenadbleSectionHeader?.subCategoryName.font = UIFont.boldSystemFont(ofSize: 24.0)
		} else {
			expenadbleSectionHeader?.subCategoryName.font = UIFont.boldSystemFont(ofSize: 14.0)
		}
		
        return expenadbleSectionHeader
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if UIDevice.current.userInterfaceIdiom == .pad {
			return 80.0
		} else {
			return 44.0
		}
    }
	
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let productListVc = self.storyboard?.instantiateViewController(withIdentifier: "ProductListViewController") as!  ProductListViewController
        if AppManager.currentApplicationMode() == .online {
            productListVc.selectedSubCategory = self.nestedCategoriesInfo[indexPath.row]["category_id"] as! String?
            productListVc.currentCategory = self.nestedCategoriesInfo[indexPath.row]["name"] as! String?
        } else {
            productListVc.selectedSubCategory = self.nestedSubCategories?[indexPath.row].nestedCategoryId
        }
        
        self.navigationController?.pushViewController(productListVc, animated: true)
    }
}

//MARK:- HandleSectionExpansionDelegate:
extension BrandsViewController: HandleSectionExpansionDelegate {
    
    func didTapSectionView(_ sectionHeaderView: ExpandableSectionsView?, atSectionIndex index: Int) {
        if self.selectedIndex == index {
            self.selectedIndex = nil

            self.brandTableView.reloadData()
        } else {
            for var sections in sectionHeaderArray {
                if (sections.currentSection == index) {
                    sections.isTapped = !sections.isTapped!
                    self.selectedIndex = index
                    self.indexValue = 0
                }
            }
            
            if AppManager.currentApplicationMode() == .online {
                if let selectedSubCategoryId = self.subCategoriesInfo[index]["category_id"] as? String {
                    self.downloadNestedCategoriesWith(categoryId: selectedSubCategoryId, withCompletion: { (success) in
                        
                        if success {
                            self.brandTableView.reloadData()
                        }
                    })
                }
            } else {
                let selectedSubCategoryId = subCategoriesData?[index].subCategoryId
                self.fetchNestedCategoryWith(parentId: selectedSubCategoryId!)
            }
        }
    }
    
    func didTapSectionHeaderView(atSection section: Int) {
        
        if AppManager.currentApplicationMode() == .online {
            
            if let selectedSubCategoryId = self.subCategoriesInfo[section]["category_id"] as? String {
                self.downloadNestedCategoriesWith(categoryId: selectedSubCategoryId, withCompletion: { (success) in
                    
                    if success {
                        if self.nestedCategoriesInfo.count == 0 {
                            let productListVc = self.storyboard?.instantiateViewController(withIdentifier: "ProductListViewController") as!  ProductListViewController
                            productListVc.selectedSubCategory = selectedSubCategoryId
                            self.navigationController?.pushViewController(productListVc, animated: true)
                        } else {
                            if self.selectedIndex == section {
                                self.selectedIndex = nil
                                
                                self.brandTableView.reloadData()
                            } else {
                                for var sections in self.sectionHeaderArray {
                                    if (sections.currentSection == section) {
                                        sections.isTapped = !sections.isTapped!
                                        self.selectedIndex = section
                                        self.indexValue = 0
                                    }
                                }
                            }
                        }
                        self.brandTableView.reloadData()
                    }
                })
            }
        } else {
            let selectedSubCategoryId = subCategoriesData?[section].subCategoryId
            
            let nestedCategories = NestedSubCategory.getAllNestedCategoriesWith(parentId: selectedSubCategoryId!)
            if nestedCategories?.count == 0 {
                let productListVc = self.storyboard?.instantiateViewController(withIdentifier: "ProductListViewController") as!  ProductListViewController
                productListVc.selectedSubCategory = selectedSubCategoryId
                self.navigationController?.pushViewController(productListVc, animated: true)
            }  else {
                
                if self.selectedIndex == section {
                    self.selectedIndex = nil
                    
                    self.brandTableView.reloadData()
                } else {
                    for var sections in sectionHeaderArray {
                        if (sections.currentSection == section) {
                            sections.isTapped = !sections.isTapped!
                            self.selectedIndex = section
                            self.indexValue = 0
                        }
                    }
                    let selectedSubCategoryId = subCategoriesData?[section].subCategoryId
                    self.fetchNestedCategoryWith(parentId: selectedSubCategoryId!)
                }
            }
        }
    }
}
