//
//  OffersListTableViewCell.swift
//  Alzahrani
//
//  Created by Hardwin on 03/05/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit
import MagicalRecord
typealias OffCellTapHandler = ((_ success: Bool, _ id: String,_ menuType: String,_ brandName: String) -> Void)
class OffersListTableViewCell: UITableViewCell {
    
    //MARK:- Properties:
    var images = ["offer", "promotions", "products3", "products4"]
    var bannerImageData = [BannerImage]()
    
    var offersList: [OfferZone]? {
        didSet {
            self.offersCollectionView.reloadData()
        }
    }
    var cellTapHandler: OffCellTapHandler?
    
    //MARK:- IB-Outlets:
    @IBOutlet weak var offersCollectionView: UICollectionView!
    
    //MARK:- Designated Initilizers:
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override func awakeFromNib() {
        self.contentView.backgroundColor = UIColor(rgba: "EBEBF1")
        super.awakeFromNib()
        self.downloadOfferImages()
        self.setupCollectionView()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

//MARK:- Helper Methods:
extension OffersListTableViewCell {
    
    func reloadUI() {
        if self.offersList?.count == 0 {
            self.offersList = OfferZone.getAllOffersList()
        }
        self.offersCollectionView.reloadData()
    }
    
    func setupCollectionView() {
        let nib = UINib(nibName: "OffersCollectionViewCell", bundle: nil)
        self.offersCollectionView.register(nib, forCellWithReuseIdentifier: "OffersCollectionViewCell")
        self.offersCollectionView.backgroundColor = UIColor.clear
        self.offersCollectionView.dataSource = self
        self.offersCollectionView.delegate = self
    }
    
    func downloadOfferImages() {
        if let offersListData = OfferZone.getAllOffersList() {
            self.offersList = offersListData
        }
        if self.offersList?.count == 0 {
            SyncManager.syncOperation(operationType: .getHomeBannersList, info: "") { (response, error) in
                if error == nil {
                    if let imageResponse = response as? [[String: AnyObject]] {
                        for (index,banner) in imageResponse.enumerated() {
                            if let bannerData = banner["module_data"] as? String {
                                if let JSONObject = bannerData.parseJSONString as? [String: AnyObject] {
                                    print("JSON Object: \(JSONObject)")
                                    var offerProduDict = [String: AnyObject]()
                                    if let imagesSection = JSONObject["sections"] as? [[String: AnyObject]] {
                                        for imageObject in imagesSection {
                                            if let imageData = imageObject["image"] as? [String: AnyObject] {
                                                if let imageURL = imageData["1"] as? String {
                                                    offerProduDict["image"] = imageURL as AnyObject?
                                                    print("Image URL: \(imageURL)")
                                                    let prorperURL = imageURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                                                    let bannerImageData = BannerImage(atIndex: index, iwthImageURL: prorperURL!, isDoanloaded: false, withImage: UIImage())
                                                    self.bannerImageData.append(bannerImageData)
                                                }
                                            }
                                            
                                            if let imageURLStr = offerProduDict["image"] as? String {
                                                let prorperURL = imageURLStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                                                SyncManager.syncOperation(operationType: .imageDownloadOperation, info: prorperURL, completionHandler: { (imageData, error) in
                                                    if error == nil {
                                                        offerProduDict["imageData"] = imageData as AnyObject?
                                                        
                                                        if let linkId = imageObject["link"] as? [String: AnyObject] {
                                                            offerProduDict["menuType"]=linkId["menu_type"] as AnyObject
                                                            if let item = linkId["menu_item"] as? [String: AnyObject] {
                                                                
                                                                if let linkImageId = item["id"] as? String, let offerImageNam = item["name"] as? String {
                                                                    offerProduDict["categoryId"] = linkImageId as AnyObject?
                                                                    self.checkAndDownloadCategories(withId: linkImageId)
                                                                    offerProduDict["name"] = offerImageNam as AnyObject?
                                                                }
                                                            }
                                                        }
                                                        
                                                        MagicalRecord.save(blockAndWait: { context in
                                                            let _ = OfferZone.mr_import(from: offerProduDict, in: context)
                                                            self.offersList = OfferZone.getAllOffersList()
                                                            
                                                            DispatchQueue.main.async {
                                                                self.offersCollectionView.reloadData()
                                                            }
                                                        })
                                                    }
                                                    DispatchQueue.main.async {
                                                        self.offersCollectionView.reloadData()
                                                    }
                                                })
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        DispatchQueue.main.async {
                            self.offersCollectionView.reloadData()
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.offersCollectionView.reloadData()
                    }
                }
            }
        }
    }
    
    func setBannerImageTo(indexValue index: Int, cell: OffersCollectionViewCell, withImageURL url: String) {
        
        cell.firstOfferImageView.image = UIImage(named: Constants.placeHolderImage)
        
        SyncManager.syncOperation(operationType: .imageDownloadOperation, info: url, completionHandler: { (imageData, error) in
            if error == nil {
                //                self.bannerImages.append(imageData as! Data)
                DispatchQueue.main.async {
                    if let bannerImage = UIImage(data: imageData as! Data) {
                        cell.firstOfferImageView.image = bannerImage
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.offersCollectionView.reloadData()
                }
            }
        })
    }
    
    func checkAndDownloadCategories(withId catId: String?) {
        
        if let _ = ProductCategory.getCategoryWith(categoryId: catId!) {
            
        } else {
            if let categoryId = catId {
                if let languageType = LanguageType(rawValue: UserDefaultManager.sharedManager().selectedLanguageId!) {
                    switch languageType {
                    case .arabic:
                        let param = categoryId.description + "&language_id=\("2")"
                        DownloadManager.sharedDownloadManager.downloadSubCategories(withParams: param)
                    case .english:
                        let param = categoryId.description + "&language_id=\("1")"
                        DownloadManager.sharedDownloadManager.downloadSubCategories(withParams: param)
                    }
                }
            }
        }
    }
}

//MARK:- UICollectionViewDataSource:
extension OffersListTableViewCell: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
		self.offersCollectionView.collectionViewLayout.invalidateLayout()
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.offersList?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OffersCollectionViewCell", for: indexPath) as? OffersCollectionViewCell
        
        if let image = self.offersList?[indexPath.row].imageData {
            if let offerImage = UIImage(data: image as Data) {
                cell?.firstOfferImageView.image = offerImage
            }
        }
        return cell!
    }
}

//MARK:- UICollectionViewDelegate:
extension OffersListTableViewCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if AppManager.currentApplicationMode() == .online {
			print("Item selected at 11111 \(indexPath.row)")
			
			let tapppedSlide = self.offersList?[indexPath.row]
			if let produId = tapppedSlide?.linkId,let brandName=tapppedSlide?.name,let menuType=tapppedSlide?.menuType {
				print("produId \(produId)")
				print("brandName \(brandName)")
				print("menuType \(menuType)")
				
				self.cellTapHandler!(true, produId,menuType,brandName)
			} else {
				self.cellTapHandler!(false, "","","")
			}
		}
    }
}

//MARK:- UICollectionViewDelegateFlowLayout:
extension OffersListTableViewCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.frame.size.width * 0.4, height: self.frame.size.height)
    }
}
