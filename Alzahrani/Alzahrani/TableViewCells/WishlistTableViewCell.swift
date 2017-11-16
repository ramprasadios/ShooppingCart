//
//  WishlistTableViewCell.swift
//  Alzahrani
//
//  Created by shilpa shree on 5/16/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

protocol WishListProductDelegeate: NSObjectProtocol {
    func didTapAddToCartButton(atCell cell: WishlistTableViewCell)
    func didTapRemoveButton(atCell cell: WishlistTableViewCell)
}

class WishlistTableViewCell: UITableViewCell {

    @IBOutlet weak var removeButton: UIButton!
    
    @IBOutlet weak var ordername: UILabel!
    @IBOutlet weak var wishlistImageView: UIImageView!
    @IBOutlet weak var actualPriceLabel: UILabel!
    @IBOutlet weak var discountPriceLabel: UILabel!
    
    @IBOutlet weak var addToCartButton: UIButton!
    weak var wishListDelegate: WishListProductDelegeate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.removeButton.setTitle(NSLocalizedString("Remove", comment: ""), for: .normal)
        self.addToCartButton.setTitle("ADD TO CART", for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func addToCartTapped(_ sender: Any) {
        self.addToCartButton.isEnabled = false
        self.wishListDelegate?.didTapAddToCartButton(atCell: self)
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        self.wishListDelegate?.didTapRemoveButton(atCell: self)
    }
}
