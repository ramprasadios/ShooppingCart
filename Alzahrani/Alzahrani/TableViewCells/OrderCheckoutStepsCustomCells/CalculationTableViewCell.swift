//
//  CalculationTableViewCell.swift
//  Alzahrani
//
//  Created by Hardwin on 18/07/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class CalculationTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productModelLabel: UILabel!
    @IBOutlet weak var productQtyLabel: UILabel!
    
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

//
//cell?.productNameLabel.text = ""
//cell?.productModelLabel.text = ""
//cell?.productQtyLabel.text = ""
//cell?.productUnitPriceLabel.text = "480.0"
//cell?.productTotalPriceLabel.text = "480.0"
