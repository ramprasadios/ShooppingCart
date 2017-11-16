//
//  ProductFilterViewController.swift
//  Alzahrani
//
//  Created by Hardwin on 05/06/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit
import MagicalRecord

struct BrandsData {
    var isSelected: Bool?
    var brandName: String?
    var brandImage: String?
    var manufactureID: String?
    
    init(withName name: String, isSelected selected: Bool, brandImage image: String, withManufacturerId id: String) {
        self.isSelected = selected
        self.brandName = name
        self.brandImage = image
        self.manufactureID = id
    }
}

class ProductFilterViewController: UIViewController {
    
    //MARK:- IB-Outlets
    @IBOutlet weak var filterMenuCollectionView: UICollectionView!
    
    @IBOutlet weak var filterOptionsTableView: UITableView!
    @IBOutlet weak var filterResultsTableView: UITableView!
    
    //MARK:- Properties
    let filterMenuArray = ["Brands", "Show Only", "Price Range", "Color"]
    var filterResultsArray = [Brands]()
    var selectedBrandsArray = [BrandsData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        self.registerNibs()
        self.setupNavigationItems()
        //self.getBrandsListArray()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

//MARK:- Helper Methods:
extension ProductFilterViewController {
    
    func setupNavigationItems() {
        let barButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(ProductFilterViewController.dismissFilterViewController))
        
        self.navigationItem.leftBarButtonItem = barButtonItem
        
    }
    
    func dismissFilterViewController() {
        NotificationCenter.default.post(name: Notification.Name(Constants.filteredBrandsDictNotification), object: self.getSelectedBrands())
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func getBrandsListArray() {
        if let brandsListArray = Brands.getAllBrands() {
            for brand in brandsListArray {
                self.filterResultsArray.append(brand)
            }
        }
    }
    
    func downloadImageForCells(cell: BrandsFilterTableViewCell?, withIndexPath indexPath: IndexPath) {
        let currentBrand = self.filterResultsArray[indexPath.row]
            if let imageURL = currentBrand.brandImage {
                let prorperURL = imageURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                SyncManager.syncOperation(operationType: .imageDownloadOperation, info: prorperURL,
                                          completionHandler: { (imageData, error) in
                                            if error == nil {
                                                DispatchQueue.main.async {
                                                    cell?.brandImageView.image = UIImage(data: imageData as! Data)
                                                }
                                            }
                })
            }
    }
    
    func getSelectedBrands() -> [String: AnyObject] {
        var selectedBrandsDict = [String: AnyObject]()
        
        var selectedBrandsList = [BrandsData]()
        for filteredBrands in selectedBrandsArray {
            if filteredBrands.isSelected! {
                selectedBrandsList.append(filteredBrands)
            }
        }
        selectedBrandsDict[Constants.selectedBrands] = selectedBrandsList as AnyObject?
        return selectedBrandsDict
    }
    
}

//MARK:- UITableViewDataSource
extension ProductFilterViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return filterResultsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterResultsCell", for: indexPath) as? BrandsFilterTableViewCell
        let brand = self.filterResultsArray[indexPath.row]
        cell?.brandNameLabel.text = brand.brandName
        self.downloadImageForCells(cell: cell, withIndexPath: indexPath)
        if let name = brand.brandName, let image = brand.brandImage, let manufacurerId = brand.manufactureId {
            let brandsData = BrandsData(withName: name, isSelected: false, brandImage: image, withManufacturerId: manufacurerId)
            self.selectedBrandsArray.append(brandsData)
        } else {
            let brandsData = BrandsData(withName: "", isSelected: false, brandImage: "", withManufacturerId: "")
            self.selectedBrandsArray.append(brandsData)
        }
        
        if self.selectedBrandsArray[indexPath.row].isSelected! {
            cell?.accessoryType = .checkmark
        } else {
            cell?.accessoryType = .none
        }

        return cell!
    }
}

extension ProductFilterViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.selectedBrandsArray[indexPath.row].isSelected! {
            self.selectedBrandsArray[indexPath.row].isSelected! = false
        } else {
            self.selectedBrandsArray[indexPath.row].isSelected! = true
        }
        self.filterResultsTableView.reloadData()
    }
}
