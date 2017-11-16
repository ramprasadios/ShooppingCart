//
//  OrderDetailSecondTableViewCell.swift
//  Alzahrani
//
//  Created by shilpa shree on 5/31/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class OrderDetailSecondTableViewCell: UITableViewCell {

    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var productName: UILabel!
    
    @IBOutlet weak var quantityLabel: UILabel!
    
    @IBOutlet weak var cartButton: UIButton!
    
    @IBOutlet weak var returnButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
