//
//  MyorderTableViewCell.swift
//  Alzahrani
//
//  Created by shilpa shree on 5/16/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class MyorderTableViewCell: UITableViewCell {

    
    @IBOutlet weak var orderImageView: UIImageView!
    
    @IBOutlet weak var orderName: UILabel!
    
    @IBOutlet weak var orderNO: UILabel!
    
    @IBOutlet weak var placedOn: UILabel!
    
    @IBOutlet weak var qtyLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var deliveryLabel: UILabel!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
