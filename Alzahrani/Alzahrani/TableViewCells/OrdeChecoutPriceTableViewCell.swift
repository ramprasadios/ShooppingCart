//
//  OrdeChecoutPriceTableViewCell.swift
//  Alzahrani
//
//  Created by shilpa shree on 6/1/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class OrdeChecoutPriceTableViewCell: UITableViewCell {

    @IBOutlet weak var codeField: UITextField!
    @IBOutlet weak var subTotalLabel: UILabel!
    @IBOutlet weak var shippingChargesLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var couponDiscoubtLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
