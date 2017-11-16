//
//  OrderDetailThirdTableViewCell.swift
//  Alzahrani
//
//  Created by shilpa shree on 5/31/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class OrderDetailThirdTableViewCell: UITableViewCell {

    @IBOutlet weak var codchargeLabel: UILabel!
    
    @IBOutlet weak var subTotalLabel: UILabel!
    
    
    @IBOutlet weak var shippingChargeLabel: UILabel!
    
    @IBOutlet weak var totalLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
