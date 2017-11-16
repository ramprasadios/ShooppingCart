//
//  FullScreenImageViewController.swift
//  Alzahrani
//
//  Created by Ramprasad A on 17/08/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class FullScreenImageViewController: UIViewController {
	
	@IBOutlet weak var imageCollectionView: UICollectionView!
	@IBOutlet weak var pageControl: UIPageControl!
	@IBOutlet weak var doneButton: UIButton!
	
	var productImages = [String]()
	var imageData: Data?
	
    override func viewDidLoad() {
        super.viewDidLoad()
			self.doneButton.setTitle(NSLocalizedString("DONE", comment: ""), for: .normal)
			self.doneButton.setTitle(NSLocalizedString("DONE", comment: ""), for: .highlighted)
			self.pageControl.numberOfPages = self.productImages.count
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
	@IBAction func doneButtonTapped(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
}

//MARK:- UICollectionViewDataSource:
extension FullScreenImageViewController: UICollectionViewDataSource {
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if AppManager.currentApplicationMode() == .online {
			return productImages.count
		} else {
			return 1
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FullScreenCollectionViewCell", for: indexPath) as? FullScreenCollectionViewCell
		if AppManager.currentApplicationMode() == .online {
			let imageURL = self.productImages[indexPath.row]
			let prorperURL = imageURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
			let imageURLStr = URLBuilder.getImageDownloadBaseURL() + prorperURL!
			UploadTaskHandler.sharedInstance.setImage(onImageView: (cell?.productImageView)!, withImageUrl: imageURLStr, placeHolderImage: nil)
		} else {
			if let imageData = self.imageData {
				if let image = UIImage(data: imageData) {
					cell?.productImageView.image = image
				}
			}
		}
		
		return cell!
	}
}

//MARK:- UICollectionViewDelegateFlowLayout:
extension FullScreenImageViewController: UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: self.imageCollectionView.frame.size.width, height: self.imageCollectionView.frame.size.height)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 0
	}
}

extension FullScreenImageViewController {
	
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		let pageWidth = self.imageCollectionView.frame.size.width
		let currentPage = self.imageCollectionView.contentOffset.x / pageWidth
		
		if (0.0 != fmodf(Float(currentPage), 1.0)) {
			pageControl.currentPage = Int(currentPage) + 1
		} else {
			pageControl.currentPage = Int(currentPage)
		}
	}
}
