//
//  NewArrivalsCollectionViewCell.swift
//  Alzahrani
//
//  Created by Hardwin on 04/05/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

protocol CellButtonActionProtocol: NSObjectProtocol {
    func didTapShareButton(atCell cell: NewArrivalsCollectionViewCell)
    func didTapCartButton(atCell cell: NewArrivalsCollectionViewCell)
    func didTapWishlistButton(atCell cell: NewArrivalsCollectionViewCell)
}

class NewArrivalsCollectionViewCell: UICollectionViewCell {
    
    //MARK:- IB-Outlets:
    
    @IBOutlet weak var outOfStockImageView: UIImageView!
    
    @IBOutlet weak var outOfStockArabicImageView: UIImageView!
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productOfferLabel: UILabel!
    @IBOutlet weak var discountProductPrice: UILabel!
    
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var wishListButton: UIButton!
    @IBOutlet weak var cartButton: UIButton!
    @IBOutlet weak var imageDownloadIndicator: UIActivityIndicatorView!
    
    @IBOutlet var goToProductDetailPageBtn: UIButton!
    
    //MARK:- Properties:
    weak var cellActionHandlerDelegate: CellButtonActionProtocol?
    var isValidTouch: Bool = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        self.layer.borderWidth = 1.0
//        self.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let point = touch.location(in: self.contentView)
            let validTouchPoint = self.contentView.bounds.height - (productNameLabel.frame.origin.y)
            if point.y < validTouchPoint {
                isValidTouch = true
            } else {
                isValidTouch = false
            }
        }
        super.touchesBegan(touches, with: event)
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        self.cellActionHandlerDelegate?.didTapShareButton(atCell: self)
    }
    
    @IBAction func cartButtonTapped(_ sender: Any) {
        self.cartButton.isEnabled = false
        self.cellActionHandlerDelegate?.didTapCartButton(atCell: self)
    }
    
    @IBAction func wishListButtonTapped(_ sender: Any) {
        self.wishListButton.isEnabled = false
        self.cellActionHandlerDelegate?.didTapWishlistButton(atCell: self)
    }
    
  
    
}
