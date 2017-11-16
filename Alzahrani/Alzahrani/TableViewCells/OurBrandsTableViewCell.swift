//
//  OurBrandsTableViewCell.swift
//  Alzahrani
//
//  Created by Hardwin on 03/05/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit
import CoreData
import AlamofireImage


typealias OurBrandsTapCallBack = ((_ success: Bool, _ id: String, _ name: String, _ image: String) -> Void)
class OurBrandsTableViewCell: UITableViewCell {
    
    //MARK:- Properties:
    var images = ["Lefheit", "Sarayli", "Soehnle", "tescoma"]
    var isFormOtherVc: Bool = false
    weak var delegate: CellTapHandlerProtocol?
    var cellTappedHandler: OurBrandsTapCallBack?
    var brandsListInfo = [[String: AnyObject]]()
    var brandsFRC : NSFetchedResultsController<NSFetchRequestResult>?
    
    var featchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? {
        return getFetchResultController()
    }
    var blockOperations: [BlockOperation] = []
    var shouldReloadCollectionView: Bool = false
    
    
    //MARK:- IB-Oulets:
    @IBOutlet weak var ourBrandsCollectionView: UICollectionView!
    
    //MARK:- Life Cycle:-
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addNotificationObservers()
        self.contentView.backgroundColor = UIColor(rgba: "EBEBF1")
        if !isFormOtherVc {
            self.handleOnlineModeProductDownload()
        }
        self.setupCollectionView()
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
extension OurBrandsTableViewCell {
    
    func addNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(OurBrandsTableViewCell.reloadUI), name: Notification.Name("BrandsDownloadSuccessNotification"), object: nil)
    }
    
    func reloadUI() {
        self.ourBrandsCollectionView.reloadData()
    }

    
    func getBrandsList() {
        let brandsList = Brands.mr_findAll()?.count
        if brandsList! <= 0 {
            SyncManager.syncOperation(operationType: .getBrandsList, info: "") { (response, error) in
                if error == nil {
                    DispatchQueue.main.async {
                        self.ourBrandsCollectionView.reloadData()
                    }
                }
            }
        }
    }
    
    func setupCollectionView() {
        let nib = UINib(nibName: "OurBrandsCollectionViewCell", bundle: nil)
        self.ourBrandsCollectionView.register(nib, forCellWithReuseIdentifier: "OurBrandsCollectionViewCell")
        self.ourBrandsCollectionView.backgroundColor = UIColor.clear
        self.ourBrandsCollectionView.dataSource = self
        self.ourBrandsCollectionView.delegate = self
    }
    
    func handleOnlineModeProductDownload() {
        if AppManager.currentApplicationMode() == .offline {
            self.updateFetchRequest()
        } else {
            self.downloadAllBrandsData(withSuccesshandler: { (success) in
                if success {
                    DispatchQueue.main.async {
                        self.ourBrandsCollectionView.reloadData()
                    }
                }
            })
        }
    }
    
    func downloadAllBrandsData(withSuccesshandler successHandler: DownloadCompletion? = nil) {
        let custGrpId = (AppManager.isUserLoggedIn) ? UserDefaultManager.sharedManager().customerGroupId : "1"
        SyncManager.syncOperation(operationType: .getBrandsList, info: custGrpId) { (response, error) in
            
            if error == nil {
                successHandler?(true)
                
                print("New Arrival Response: \(response)")
                
                if let newArrivalsInfo = response as? [[String: AnyObject]] {
                    DispatchQueue.main.async {
                        if !self.isFormOtherVc {
                            self.brandsListInfo = newArrivalsInfo
                        }
                    }
                }
            } else {
                successHandler?(false)
            }
        }
    }
    
    func updateFetchRequest(withPridicate predicate: NSPredicate? = nil) {
        
        if let predicate = predicate {
            self.brandsFRC = Brands.mr_fetchAllSorted(by: "brandName",
                                                      ascending: true,
                                                      with: predicate,
                                                      groupBy: nil,
                                                      delegate: self)
        } else {
            self.brandsFRC = Brands.mr_fetchAllSorted(by: "brandName",
                                                      ascending: true,
                                                      with: nil,
                                                      groupBy: nil,
                                                      delegate: self)

        }
    }
    
    func getFetchResultController() -> NSFetchedResultsController<NSFetchRequestResult>? {
        return self.brandsFRC
    }
    
    func downloadImageForCells(cell: OurBrandsCollectionViewCell?, withIndexPath indexPath: IndexPath) {
        if let currentCategory = self.featchedResultsController?.fetchedObjects?[indexPath.row] as? Brands {
            if let imageURL = currentCategory.brandImage {
                let prorperURL = imageURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                SyncManager.syncOperation(operationType: .imageDownloadOperation, info: prorperURL,
                                          completionHandler: { (imageData, error) in
                                            if error == nil {
                                                DispatchQueue.main.async {
                                                    cell?.ourBrandsImageView.image = UIImage(data: imageData as! Data)
                                                }
                                            }
                })
            }
        }
    }
}

//MARK:- UICollectionViewDataSource:
extension OurBrandsTableViewCell: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if AppManager.currentApplicationMode() == .online {
            return self.brandsListInfo.count
        } else {
            return self.featchedResultsController?.sections![section].objects?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OurBrandsCollectionViewCell", for: indexPath) as? OurBrandsCollectionViewCell
        
        if AppManager.currentApplicationMode() == .online {
			if self.brandsListInfo.count > 0 {
				let brandObj = self.brandsListInfo[indexPath.row]
				if let brandImage = brandObj["image"] as? String {
					
					let prorperURL = brandImage.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
					let imageURLStr = URLBuilder.getImageDownloadBaseURL() + prorperURL!
					
					UploadTaskHandler.sharedInstance.setImage(onImageView: (cell?.ourBrandsImageView)!, withImageUrl: imageURLStr, placeHolderImage: nil)
			}
		}
            return cell!
        } else {
            if let brandObject = self.featchedResultsController?.fetchedObjects?[indexPath.row] as? Brands {
                if let brandImage = brandObject.brandImageData {
                    if let image = UIImage(data: brandImage as Data) {
                        cell?.ourBrandsImageView.image = image
                    }
                }
            }
            DispatchQueue.main.async {
                self.downloadImageForCells(cell: cell, withIndexPath: indexPath)
            }
            return cell!
        }
    }
}

//MARK:- UICollectionViewDelegate:
extension OurBrandsTableViewCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if AppManager.currentApplicationMode() == .online {
            let selectedBrand = self.brandsListInfo[indexPath.row]
            if let brandCategoryId = selectedBrand["category_id"] as? String, let name = selectedBrand["name"] as? String, let image = selectedBrand["image"] as? String {
                self.cellTappedHandler?(true, brandCategoryId, name, image)
            } else {
                self.cellTappedHandler?(true, "", "", "")
            }
        } else {
            print("Item selected at \(indexPath.row)")
            if let selectedBrand = self.featchedResultsController?.fetchedObjects?[indexPath.row] as? Brands {
                if let categoryId = selectedBrand.manufactureId, let brandName = selectedBrand.brandName {
                    self.cellTappedHandler?(true, categoryId, brandName, "")
                } else {
                    self.cellTappedHandler?(false, "", "", "")
                }
            }
        }
    }
}

//MARK:- UICollectionViewDelegateFlowLayout:
extension OurBrandsTableViewCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.frame.size.width * 0.25, height: 75.0)
    }
}

//MARK:- NSFetchedResultsControllerDelegate:
extension OurBrandsTableViewCell: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.ourBrandsCollectionView.reloadData()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        
        switch type {
        case .delete:
            if self.ourBrandsCollectionView.numberOfItems(inSection: indexPath!.section) == 1 {
                self.shouldReloadCollectionView = true
            } else {
                blockOperations.append(
                    BlockOperation(block: { [weak self] in
                        if let timerVc = self {
                            DispatchQueue.main.async {
                                timerVc.ourBrandsCollectionView.deleteItems(at: [indexPath!])
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
                            timerVc.ourBrandsCollectionView.moveItem(at: indexPath!, to: newIndexPath!)
                        }
                    }
                })
            )
        case .update:
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let timerVc = self {
                        DispatchQueue.main.async {
                            timerVc.ourBrandsCollectionView.reloadItems(at: [indexPath!])
                        }
                    }
                })
            )
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if self.shouldReloadCollectionView {
            DispatchQueue.main.async {
                self.ourBrandsCollectionView.reloadData()
            }
        } else {
            
            DispatchQueue.main.async {
                self.ourBrandsCollectionView.performBatchUpdates({
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

