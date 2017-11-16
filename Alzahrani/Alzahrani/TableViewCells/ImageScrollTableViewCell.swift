//
//  ImageScrollTableViewCell.swift
//  Alzahrani
//
//  Created by Hardwin on 02/05/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit
import Alamofire
import MagicalRecord

typealias CellTapHandler = ((_ success: Bool, _ id: String,_ menuType: String,_ brandName: String) -> Void)

struct BannerImage {
    var index: Int?
    var imageURL: String
    var isDownloaded: Bool?
    var bannerImage: UIImage?
    
    init(atIndex index: Int, iwthImageURL url: String, isDoanloaded status: Bool, withImage image: UIImage) {
        self.index = index
        self.imageURL = url
        self.isDownloaded = status
        self.bannerImage = image
    }
}

struct BannerInfoData {
	
	let bannerImage: String
	let link: String?
	let menuType: String?
	let name: String?

	init(withBannerImage image: String, andLink link: String?, withMenuType type: String?, andName name: String?) {
		self.bannerImage = image
		self.link = link
		self.menuType = type
		self.name = name
	}
}

class ImageScrollTableViewCell: UITableViewCell {
    
    //MARK:- IB-Outlet:
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var imageDownloadIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var imagePageControl: UIPageControl!
    
    var productInfo=[String: AnyObject]()
    //MARK:- Properties:
    var images = ["image1", "image2", "image3", "image4"]
    var bannerImages = [Data]()
    var bannerImageURL = [String]()
    weak var delegate: CellTapHandlerProtocol?
    var imageScrollTimer = Timer()
    var initialIndexValue: IndexPath?
    var maxScrollableRange: Int? = 0
    var bannerImageData = [BannerImage]()
    var bannerInfo: [Banners]? {
        didSet {
            self.imageCollectionView.reloadData()
        }
    }
	
	var bannerOfflineData = [Banners]()
	var bannerData = [BannerInfoData]()
    var cellTappedCallback: CellTapHandler?
    //MARK:- Life Cycle:
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override func awakeFromNib() {
        self.contentView.backgroundColor = UIColor(rgba: "EBEBF1")
        super.awakeFromNib()
        self.setupCollectionView()
        self.addNotificationObserver()
        //self.downloadBannerImages()
		if AppManager.currentApplicationMode() == .online {
			//self.downloadSlidersData()
		} else {
			if let bannerData = Banners.getAllBannersData() {
					self.bannerOfflineData = bannerData
			}
		}
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

//MARK:- Helper Methods:
extension ImageScrollTableViewCell {
    
    func setupCollectionView() {
        let nib = UINib(nibName: "ImageCollectionViewCell", bundle: nil)
        self.imageCollectionView.register(nib, forCellWithReuseIdentifier: "ImageCollectionViewCell")
        self.imageCollectionView.dataSource = self
        self.imageCollectionView.delegate = self
    }
    
    func scrollCollectionView() {
        let collectionViewBounds = self.imageCollectionView.bounds
        var contentOffset: CGFloat?
        if ((self.maxScrollableRange! < self.images.count) && (self.maxScrollableRange! >= 0))  {
            self.maxScrollableRange = self.maxScrollableRange! + 1
            contentOffset = CGFloat(floor(self.imageCollectionView.contentOffset.x + collectionViewBounds.size.width))
        } else {
            contentOffset = 0.0
            self.maxScrollableRange = 0
        }
        self.moveToFrame(contentOffset: contentOffset!)
    }
    
    func moveToFrame(contentOffset: CGFloat) {
        let frame = CGRect(
            x: contentOffset,
            y: self.imageCollectionView.contentOffset.y,
            width: self.imageCollectionView.frame.width,
            height: self.imageCollectionView.frame.height)
        self.imageCollectionView.scrollRectToVisible(frame, animated: true)
    }
    
    func addNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(ImageScrollTableViewCell.scrollCollectionView), name: Notification.Name(Constants.timerFiredNotification), object: nil)
    }
    
	func reloadUIData() {
		
	  //self.downloadSlidersData()
		if AppManager.currentApplicationMode() == .offline {
			if self.bannerOfflineData.count <= 0 {
				if let bannersData = Banners.getAllBannersData() {
					self.bannerOfflineData = bannersData
				}
			}
		} else {
			
		}
		self.imageCollectionView.reloadData()
	}
	
    func downloadBannerImages() {
        if let bannersData = Banners.getAllBannersData() {
            self.bannerInfo = bannersData
            self.imagePageControl.numberOfPages = (self.bannerInfo?.count)!
        }
        
        if bannerInfo?.count == 0 {
            SyncManager.syncOperation(operationType: .getSliderImages, info: "") { (response, error) in
                print("response====: \(response)")
                if error == nil {
                    if let imageResponse = response as? [[String: AnyObject]] {
                        for (index, bannerImage) in imageResponse.enumerated() {
                            if let sliderImageInfo = bannerImage["module_data"] as? String {
                                if let JSONObject = sliderImageInfo.parseJSONString as? [String: AnyObject] {
                                    print("JSON Object: \(JSONObject)")
                                    if let imageSection = JSONObject["slides"] as? [[String: AnyObject]] {
                                        for imageObject in imageSection {
                                            var bannerDict = [String: AnyObject]()
                                            if let imageData = imageObject["image"] as? [String: AnyObject] {
                                                if let imageURL = imageData["1"] as? String {
                                                    print("Image URL: \(imageURL)")
                                                    let prorperURL = imageURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                                                    bannerDict["image"] = imageURL as AnyObject
                                                    let sliderImageData = BannerImage(atIndex: index, iwthImageURL: prorperURL!, isDoanloaded: false, withImage: UIImage())
                                                    self.bannerImageData.append(sliderImageData)
                                                }
                                            }
                                            if let imageURLStr = bannerDict["image"] as? String {
                                                let prorperURL = imageURLStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                                                SyncManager.syncOperation(operationType: .imageDownloadOperation, info: prorperURL, completionHandler: { (imageData, error) in
                                                    if error == nil {
                                                        bannerDict["imageData"] = imageData as AnyObject?
                                                       

                                                        
                                                        if let productLink = imageObject["link"] as? [String: AnyObject] {
                                                            bannerDict["menuType"]=productLink["menu_type"] as AnyObject
                                                            
                                                             print("Image menuType: \(bannerDict["menuType"])")
                                                            if let menuItem = productLink["menu_item"] as? [String: AnyObject] {
                                                                bannerDict["id"] = menuItem["id"] as AnyObject
                                                                bannerDict["name"] = menuItem["name"] as AnyObject
                                                                self.checkAndDownloadCategories(withId: menuItem["id"] as! String?)
                                                            }
                                                        }
                                                        
                                                        MagicalRecord.save(blockAndWait: { context in
                                                            let _ = Banners.mr_import(from: bannerDict, in: context)
                                                            self.bannerInfo = Banners.getAllBannersData()
                                                            self.imagePageControl.numberOfPages = (self.bannerInfo?.count)!
                                                            
                                                            DispatchQueue.main.async {
                                                                self.imageCollectionView.reloadData()
                                                            }
                                                        })
                                                    }
                                                    DispatchQueue.main.async {
                                                        self.imageCollectionView.reloadData()
                                                    }
                                                })
                                            }
                                            
                                            DispatchQueue.main.async {
                                                self.imageCollectionView.reloadData()
                                            }
                                        }
                                        DispatchQueue.main.async {
                                            self.imageCollectionView.reloadData()
                                        }
                                    }
                                }
                            }
                        }
                        DispatchQueue.main.async {
                            self.imageCollectionView.reloadData()
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.imageCollectionView.reloadData()
                    }
                }
            }
        }
    }
	
	func downloadSlidersData() {
		self.bannerData = []
			SyncManager.syncOperation(operationType: .getSliderImages, info: "") { (response, error) in
				print("response====: \(response)")
				if error == nil {
					if let imageResponse = response as? [[String: AnyObject]] {
						for bannerImage in imageResponse {
							if let sliderImageInfo = bannerImage["module_data"] as? String {
								if let JSONObject = sliderImageInfo.parseJSONString as? [String: AnyObject] {
									print("JSON Object: \(JSONObject)")
									if let imageSection = JSONObject["slides"] as? [[String: AnyObject]] {
										for imageObject in imageSection {
											var bannerDict = [String: AnyObject]()
											if let imageData = imageObject["image"] as? [String: AnyObject], let productLink = imageObject["link"] as? [String: AnyObject] {
												
												var imageURLStr = ""
												if let imageURL = imageData["1"] as? String {
													
													imageURLStr = imageURL
												}
												
												bannerDict["menuType"] = productLink["menu_type"] as AnyObject
												
												print("Image menuType: \(bannerDict["menuType"])")
												if let menuItem = productLink["menu_item"] as? [String: AnyObject], let menuType = productLink["menu_type"] as? String {
													if let linkId = menuItem["id"] as? String, let name = menuItem["name"] as? String {
														let bannnerInfo = BannerInfoData(withBannerImage: imageURLStr, andLink: linkId, withMenuType: menuType, andName: name)
														
														self.bannerData.append(bannnerInfo)
													}
												} else {
													let bannnerInfo = BannerInfoData(withBannerImage: imageURLStr, andLink: "", withMenuType: "custom", andName: "")
													
													self.bannerData.append(bannnerInfo)
												}
											}
										}
									}
								}
							}
						}
						DispatchQueue.main.async {
							self.imageCollectionView.reloadData()
						}
					}
				}
			}
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
	
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		let pageWidth = self.imageCollectionView.frame.size.width
		let currentPage = self.imageCollectionView.contentOffset.x / pageWidth
		
		if (0.0 != fmodf(Float(currentPage), 1.0)) {
			imagePageControl.currentPage = Int(currentPage) + 1
		} else {
			imagePageControl.currentPage = Int(currentPage)
		}
	}
}

//MARK:- UICollectionViewDataSource
extension ImageScrollTableViewCell: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
		self.imageCollectionView.collectionViewLayout.invalidateLayout()
        return 1
    }
    
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if AppManager.currentApplicationMode() == .online {
			return self.bannerData.count
		} else {
			return self.bannerOfflineData.count
		}
	}
	
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		self.imagePageControl.numberOfPages = self.bannerData.count
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as? ImageCollectionViewCell
		if AppManager.currentApplicationMode() == .online {
			if self.bannerData.count != 0 {
				let imageURL = self.bannerData[indexPath.row].bannerImage
				let prorperURL = imageURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
				let imageURLStr = URLBuilder.getImageDownloadBaseURL() + prorperURL!
				
				UploadTaskHandler.sharedInstance.setImage(onImageView: (cell?.collectionImageView)!, withImageUrl: imageURLStr, placeHolderImage: nil)
			}
	  
		} else {
			if self.bannerOfflineData.count > 0 {
				if let imageData = self.bannerOfflineData[indexPath.row].imageData {
					if let image = UIImage(data: imageData as Data) {
						cell?.collectionImageView.image = image
					}
				}
			}
		}
		return cell!
    }
}

//MARK:- UICollectionViewDelegate
extension ImageScrollTableViewCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if AppManager.currentApplicationMode() == .online {
			print("Item selected at \(indexPath.row)")
			
			print("Item self.bannerInfo at \(self.bannerData[indexPath.row])")
			
			let tapppedSlide = self.bannerData[indexPath.row]
			
			if let produId = tapppedSlide.link, let brandName = tapppedSlide.name, let menuType=tapppedSlide.menuType  {
				self.cellTappedCallback!(true, produId, menuType, brandName)
			} else {
				
				self.cellTappedCallback!(false, "","","")
			}
		}
    }
}


//MARK:- UICollectionViewDelegateFlowLayout
extension ImageScrollTableViewCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
         print("Item selected at .....")
        return CGSize(width: self.frame.size.width, height: self.frame.size.height)
    }
}




