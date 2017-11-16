//
//  ReviewsecondTableViewCell.swift
//  Alzahrani
//
//  Created by shilpa shree on 5/17/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class ReviewTableViewCell: UITableViewCell {

     @IBOutlet weak var serialNoLabel: UILabel!
     @IBOutlet weak var productNameLabel: UILabel!
     @IBOutlet weak var productModelLabel: UILabel!
     @IBOutlet weak var productQtyLabel: UILabel!
     @IBOutlet weak var productUnitPriceLabel: UILabel!
    @IBOutlet weak var productTotalPriceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
