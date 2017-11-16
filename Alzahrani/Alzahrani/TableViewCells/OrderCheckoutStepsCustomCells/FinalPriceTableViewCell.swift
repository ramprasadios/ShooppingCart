//
//  FinalPriceTableViewCell.swift
//  Alzahrani
//
//  Created by Hardwin on 19/07/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class FinalPriceTableViewCell: UITableViewCell {

    @IBOutlet weak var productUnitPriceLabel: UILabel!
    @IBOutlet weak var productTotalPriceLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
