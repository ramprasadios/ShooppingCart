//
//  SubCategoriesViewController.swift
//  Alzahrani
//
//  Created by Ramprasad A on 05/05/17.
//  Copyright © 2017 Hardwin. All rights reserved.
//

import UIKit

struct SectionHeaderInfo {
    var isTapped: Bool?
    var currentSection: Int?
    
    init(withNumberOfRows items: Int, isTapped tapped: Bool) {
        self.isTapped = tapped
        self.currentSection = items
    }
}

class SubCategoriesViewController: UIViewController {
    
    //IB_Outlet:
    @IBOutlet weak var subCategoriesTableView: UITableView!
    
    //Properties :
    var sectionHeaderArray = [SectionHeaderInfo]()
    var selectedIndex: Int? = 0
    var subCategoriesData: [SubCategories]?
    var parentId: String?
    var selectedCategory: [String: AnyObject]?
    var indexValue: Int = 0
    var _nestedSubCatArray: [NestedSubCategory]?
    var nestedSubCategories: [NestedSubCategory]? {
        get {
            return _nestedSubCatArray
        } set {
            if let newValue = newValue {
                self._nestedSubCatArray = newValue
                self.subCategoriesTableView.reloadData()
            }
        }
    }
    var compoundFilterPredicate: NSCompoundPredicate?
    var subCategoriesInfo = [[String: AnyObject]]()
    var nestedCategories = [[String: AnyObject]]()
    var brandsListInfo = [[String: AnyObject]]()
     var categoryInfo = [[String: AnyObject]]()
     let myGroup = DispatchGroup()
    
    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerCustomTableCellNibs()
        self.downloadSubCategories()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.getBrandsOfCurrentCategory()
        self.setNavBarTitle()
        self.removeNavigationBarImage()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.removeNavigationBarImage()
        self.handleViewMirroring()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let navbarImageView = UIImage(named: "NavBarLogo")
        self.navigationController?.navigationBar.setBackgroundImage(navbarImageView?.resizableImage(withCapInsets: UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0), resizingMode: .stretch), for: .top, barMetrics: .default)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
    }
}

//MARK:- Helper Methods
extension SubCategoriesViewController {
    
    func registerCustomTableCellNibs() {
        let nib4 = UINib(nibName: "OurBrandsTableViewCell", bundle: nil)
        self.subCategoriesTableView.register(nib4, forCellReuseIdentifier: "OurBrandsTableViewCell")
        let nib5 = UINib(nibName: "NewArrivalsTableViewCell", bundle: nil)
        self.subCategoriesTableView.register(nib5, forCellReuseIdentifier: "NewArrivalsTableViewCell")
        let nib6 = UINib(nibName: "MostCellingTableViewCell", bundle: nil)
        self.subCategoriesTableView.register(nib6, forCellReuseIdentifier: "MostCellingTableViewCell")
        
        let sectionHeaderNib = UINib(nibName: "ExpandableSectionsView", bundle: nil)
        self.subCategoriesTableView.register(sectionHeaderNib, forHeaderFooterViewReuseIdentifier: "ExpandableSectionsView")
        
        let sectionHeaderNib2 = UINib(nibName: HomeSectionHeader.selfName(), bundle: nil)
        self.subCategoriesTableView.register(sectionHeaderNib2, forHeaderFooterViewReuseIdentifier: HomeSectionHeader.selfName())
    }
    
    func downloadSubCategories() {
        let appLanguageId = (AppManager.languageType() == .english) ? "1" : "2"
        if AppManager.currentApplicationMode() == .online {
            let syncParam = self.parentId! + "&language_id=\(appLanguageId)"
            ProgressIndicatorController.showLoading()
            SyncManager.syncOperation(operationType: .getProductSubCategories, info: syncParam) { (response, error) in
                ProgressIndicatorController.dismissProgressView()
                if error == nil {
                    if let responseData = response as? [[String: AnyObject]] {
                        print("Response sub cat: \(responseData)")
                        DispatchQueue.main.async {
                            self.subCategoriesInfo = responseData
                            self.subCategoriesTableView.reloadData()
                            self.createSubCategoryDataSource()
                        }
                    }
                }
            }
        } else {
            self.getSubCategoryDataSource()
            self.handleBrandsFiltering()
        }
    }
    
    func createSubCategoryDataSource() {
        var tempDict = [String: AnyObject]()
        tempDict["name"] = "Temp" as AnyObject?
        var tempArray = [[String: AnyObject]]()
        tempArray.append(tempDict)
        tempArray.append(tempDict)
        
        for subCategoryData in self.subCategoriesInfo {
            tempArray.append(subCategoryData)
        }
        self.subCategoriesInfo = tempArray
        self.subCategoriesTableView.reloadData()
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
                        self.nestedCategories = reponseData
                        completionHandler?(true)
                    }
                }
            } else {
                completionHandler?(false)
            }
        }
    }
    
    func getSubCategoryDataSource() {

        self.subCategoriesData = SubCategories.getSubCategoriesBy(parentId: self.parentId!)
        var tempArray = [SubCategories]()
        for _ in 0..<2 {
            if let subCategory = SubCategories.getSubCategoriesBy(parentId: self.parentId!)?.first {
                tempArray.append(subCategory)
            } else {
                
            }
        }
        for subCategoryObject in self.subCategoriesData! {
            tempArray.append(subCategoryObject)
        }
        
        self.subCategoriesData = tempArray
    }
    
    func fetchNestedCategoryWith(parentId id: String) {
        
        if let productsArray = NestedSubCategory.getAllNestedCategoriesWith(parentId: id) {
            self.nestedSubCategories = productsArray
        }
    }
    
    func handleBrandsFiltering() {
		
		var predicateArray = [NSPredicate]()
		if let brands = BrandsCategory.getAllBrands(ofCategoryId: self.parentId!) {
			for brand in brands {
				let predicate = NSPredicate(format: "manufactureId = %@", brand.manufactureId!)
				predicateArray.append(predicate)
			}
		}
		self.compoundFilterPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicateArray)

		/* Testing
        if let allSubCategories = SubCategories.getSubCategoriesBy(parentId: self.parentId!) {
            for subSubCat in allSubCategories {
                if let nestedObjects = NestedSubCategory.getAllNestedCategoriesWith(parentId: subSubCat.subCategoryId!) {
                    for nestedCat in nestedObjects {
                        if let products = Product.getProductWith(categoryId: nestedCat.nestedCategoryId!) {
                            let predicate = NSPredicate(format: "manufactureId = %@", products.manufacturerId.description)
                            predicateArray.append(predicate)
                        }
                    }
                }
            }
            self.compoundFilterPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicateArray)
            self.subCategoriesTableView.reloadData()
        } Testing */
    }
    
    func downloadProductImage(withURL url: String?, atCell cell: SubCategoriesOffersTableViewCell) {
        
        if let imageURL = url {
            let prorperURL = imageURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            SyncManager.syncOperation(operationType: .imageDownloadOperation, info: prorperURL,
                                      completionHandler: { (imageData, error) in
                                        if error == nil {
                                            DispatchQueue.main.async {
                                                cell.categoryImageView.image = UIImage(data: imageData as! Data)!
                                            }
                                        }
            })
        }
    }
   
    func handleViewMirroring() {
        
        if LanguageManager.currentAppleLanguage() == "en" {
            
        } else {
            self.self.loopThroughSubViewAndFlipTheImageIfItsAUIImageView(subviews: self.view.subviews)
            
        }
    }
    
    func getBrandsOfCurrentCategory() {
        SyncManager.syncOperation(operationType: .getBrandsOfCategory, info: self.parentId) { (response, error) in
            if error == nil {
                print("Brands Response: \(response)")
                if let brandsResponse = response as? [[String: AnyObject]] {
                    self.brandsListInfo = brandsResponse
                    self.subCategoriesTableView.reloadData()
                }
            }
        }
    }
    
    func setNavBarTitle() {
        if AppManager.currentApplicationMode() == .online {
            if let categoryName = self.selectedCategory?["name"] as? String {
                self.title = categoryName
            }
        } else {
            if let currentCategory = ProductCategory.getCategoryWith(categoryId: self.parentId!) {
                if let categoryName = currentCategory.name {
                    self.title = categoryName
                }
            }
        }
    }
    
    func removeNavigationBarImage() {
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
    }
}

//MARK:- UITableViewDataSource
extension SubCategoriesViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if AppManager.currentApplicationMode() == .online {
            return self.subCategoriesInfo.count
        } else {
            return self.subCategoriesData!.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !((section == 0) || (section == 1)) {
            if section == self.selectedIndex {
                if AppManager.currentApplicationMode() == .online {
                    return self.nestedCategories.count
                } else {
                    return self.nestedSubCategories!.count
                }
            } else {
                return 0
            }
        } else {
            return 1
        }
    }
    
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		if indexPath.section == 0 {
			
			let cell = tableView.dequeueReusableCell(withIdentifier: "SubCategoriesOffersTableViewCell", for: indexPath) as? SubCategoriesOffersTableViewCell
			
			if AppManager.currentApplicationMode() == .online {
				if let categoryImage = self.selectedCategory?["image"] as? String {
					self.downloadProductImage(withURL: categoryImage, atCell: cell!)
				}
			} else {
				if let currentCategory = ProductCategory.getCategoryWith(categoryId: self.parentId!) {
					if let imageData = currentCategory.imageData {
						if let image = UIImage(data: imageData as Data) {
							cell?.categoryImageView.image = image
						}
					}
				}
			}
			
			return cell!
		} else if indexPath.section == 1 {
			let cell = tableView.dequeueReusableCell(withIdentifier: "OurBrandsTableViewCell", for: indexPath) as? OurBrandsTableViewCell
			if AppManager.currentApplicationMode() == .online {
				cell?.isFormOtherVc = true
				cell?.brandsListInfo = self.brandsListInfo
				cell?.reloadUI()
			} else {
				
				let predicate = self.compoundFilterPredicate
				cell?.updateFetchRequest(withPridicate: predicate)
				cell?.reloadUI()
			}
			
			cell?.cellTappedHandler = { (success, id, name, image) in
				if success {
					/*let brandvc = self.storyboard?.instantiateViewController(withIdentifier: "BrandViewController") as?  BrandsViewController
					brandvc?.selectedBrandId = id
					brandvc?.selectedBrandName = name
					self.navigationController?.pushViewController(brandvc!, animated: true)
					*/
					/*
					self.myGroup.enter()
					
					self.downloadProductFromBrandName(category_id: id, brandName: name)
					
					self.myGroup.notify(queue: DispatchQueue.main) {
					//print("===category==\(self.categoryInfo)")
					
					var finalCatList=[[String:AnyObject]]()
					
					for newcat in self.categoryInfo
					{
					var singleCat=[String:AnyObject]()
					
					let name=newcat["name"]
					let description=newcat["description"]
					singleCat=newcat
					singleCat["arName"]=name
					singleCat["arDescription"]=description
					
					
					finalCatList.append(singleCat)
					
					}
					
					print("===finalCatList==\(finalCatList)")
					
					
					} */
					
					let productListVc = self.storyboard?.instantiateViewController(withIdentifier: "ProductListViewController") as!  ProductListViewController
					//productListVc.productsListInfo=finalCatList
					productListVc.brandsId = id
					productListVc.brandName = name
					productListVc.fromScreenType = .brands
					productListVc.subCategory=false
					self.navigationController?.pushViewController(productListVc, animated: true)
				}
			}
			cell?.selectionStyle = .none
			return cell!
		} else {
			let cell = tableView.dequeueReusableCell(withIdentifier: "NormalCell", for: indexPath) as? SubCategoriesTableViewCell
			
			if AppManager.currentApplicationMode() == .online {
				
				let nestedSubCategoryObj = self.nestedCategories[indexPath.row]
				if let name = nestedSubCategoryObj["name"] as? String {
					cell?.subCategoryName?.text = name
					if UIDevice.current.userInterfaceIdiom == .pad {
						cell?.subCategoryName?.font = UIFont.systemFont(ofSize: 18.0)
					} else {
						cell?.subCategoryName?.font = UIFont.systemFont(ofSize: 12.0)
					}
					
					cell?.subCategoryName?.textAlignment = .natural
				}
				cell?.selectionStyle = .none
				return cell!
			} else {
				cell?.subCategoryName?.text = self.nestedSubCategories?[indexPath.row].name
				if UIDevice.current.userInterfaceIdiom == .pad {
					cell?.subCategoryName?.font = UIFont.systemFont(ofSize: 18.0)
				} else {
					cell?.subCategoryName?.font = UIFont.systemFont(ofSize: 12.0)
				}
				cell?.subCategoryName?.textAlignment = .natural
				cell?.selectionStyle = .none
				return cell!
			}
		}
	}
}

//MARK:- UITableViewDelegate
extension SubCategoriesViewController: UITableViewDelegate {
	
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 0) {
			if UIDevice.current.userInterfaceIdiom == .pad {
				return 175.0
			} else {
				return 126.0
			}
        } else if indexPath.section == 1 {
			
			if UIDevice.current.userInterfaceIdiom == .pad {
				return 140.0
			} else {
				return 80.0
			}
        } else {
			if UIDevice.current.userInterfaceIdiom == .pad {
				return 50.0
			} else {
				return 35.0
			}
        }
    }
	
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		
        if !(section == 1)  {
			
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
            
        } else {
            
            let sectionHeaderView = tableView.dequeueReusableHeaderFooterView(withIdentifier: HomeSectionHeader.selfName()) as? HomeSectionHeader
            sectionHeaderView?.contentView.backgroundColor = UIColor(rgba: "EBEBF1")
            sectionHeaderView?.sectionHeaderName.font = UIFont.systemFont(ofSize: 10.0)
            
            switch section {
            case 1:
                sectionHeaderView?.sectionHeaderName.text = NSLocalizedString("Our Brands", comment: "")
            default:
                sectionHeaderView?.sectionHeaderName.text = ""
            }
			
			if UIDevice.current.userInterfaceIdiom == .pad {
				sectionHeaderView?.sectionHeaderName.font = UIFont.boldSystemFont(ofSize: 24.0)
			} else {
				sectionHeaderView?.sectionHeaderName.font = UIFont.boldSystemFont(ofSize: 14.0)
			}
			
            return sectionHeaderView
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return 0.0
        } else {
			if UIDevice.current.userInterfaceIdiom == .pad {
				return 80.0
			} else {
				return 44.0
			}
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let productListVc = self.storyboard?.instantiateViewController(withIdentifier: "ProductListViewController") as!  ProductListViewController
        if indexPath.section != 0 {
            if AppManager.currentApplicationMode() == .online {
                productListVc.selectedSubCategory = self.nestedCategories[indexPath.row]["category_id"] as! String?
                productListVc.currentCategory = self.nestedCategories[indexPath.row]["name"] as! String?
            } else {
                productListVc.selectedSubCategory = self.parentId
            }
            self.navigationController?.pushViewController(productListVc, animated: true)
        }
    }
}

//MARK:- HandleSectionExpansionDelegate:
extension SubCategoriesViewController: HandleSectionExpansionDelegate {
    
    func didTapSectionView(_ sectionHeaderView: ExpandableSectionsView?, atSectionIndex index: Int) {
        
        if self.selectedIndex == index {
            self.selectedIndex = nil
            self.subCategoriesTableView.reloadData()
        } else {
            for var sections in sectionHeaderArray {
                if (sections.currentSection == index) {
                    sections.isTapped = !sections.isTapped!
                    self.selectedIndex = index
                    self.indexValue = 0
                }
            }
        }
        
        if AppManager.currentApplicationMode() == .online {
            if let selectedSubCategoryId = self.subCategoriesInfo[index]["category_id"] as? String {
                self.downloadNestedCategoriesWith(categoryId: selectedSubCategoryId, withCompletion: { (success) in
                    
                    if success {
                        self.subCategoriesTableView.reloadData()
                    }
                })
            }
        } else {
            let selectedSubCategoryId = subCategoriesData?[index].subCategoryId
            self.fetchNestedCategoryWith(parentId: selectedSubCategoryId!)
        }
    }
    
    func downloadProductFromBrandName(category_id:String,brandName:String)
    {
        
        let catId=Int(category_id)
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
                    let syncDataFormat = "&manufacture_name=\(brandName)&category_id=\(catId!)&customer_group_id=\(customerGroupId)&language_id=\(languageId)"
                    
                    SyncManager.syncOperation(operationType: .getProductsFromBrandNameData, info: syncDataFormat, completionHandler: { (response, error) in
                        if error == nil {
                            //print("new Response response: \(response)")
                            if let responseData = response as? [[String: AnyObject]] {
                                DispatchQueue.main.async {
                                    // print("new Response response1: \(responseData)")
                                    self.categoryInfo = responseData
                                    
                                    
                                    self.myGroup.leave()
                                    
                                }
                            }
                        }
                        else
                        {
                            print("Response error: \(error)")
                        }
                    })
                }
            }
        }
    }
    
    func didTapSectionHeaderView(atSection section: Int) {
        
        if AppManager.currentApplicationMode() == .online {
            
            if let selectedSubCategoryId = self.subCategoriesInfo[section]["category_id"] as? String {
                self.downloadNestedCategoriesWith(categoryId: selectedSubCategoryId, withCompletion: { (success) in
                    
                    if success {
                        if self.nestedCategories.count == 0 {
                            let productListVc = self.storyboard?.instantiateViewController(withIdentifier: "ProductListViewController") as!  ProductListViewController
                            productListVc.selectedSubCategory = selectedSubCategoryId
                            self.navigationController?.pushViewController(productListVc, animated: true)
                        } else {
                            if self.selectedIndex == section {
                                self.selectedIndex = nil
                                
                                self.subCategoriesTableView.reloadData()
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
                        self.subCategoriesTableView.reloadData()
                    }
                })
            }
        } else {
            let selectedSubCategoryId = subCategoriesData?[section].subCategoryId
            
            let nestedCategories = NestedSubCategory.getAllNestedCategoriesWith(parentId: selectedSubCategoryId!)
            if nestedCategories?.count == 0 {
                let productListVc = self.storyboard?.instantiateViewController(withIdentifier: "ProductListViewController") as!  ProductListViewController
					productListVc.selectedSubCategory = self.parentId
//                productListVc.selectedSubCategory = selectedSubCategoryId
                self.navigationController?.pushViewController(productListVc, animated: true)
            }  else {
                
                if self.selectedIndex == section {
                    self.selectedIndex = nil
                    
                    self.subCategoriesTableView.reloadData()
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
