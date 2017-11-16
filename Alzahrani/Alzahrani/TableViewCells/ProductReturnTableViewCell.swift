//
//  ProductReturnTableViewCell.swift
//  Alzahrani
//
//  Created by shilpa shree on 6/9/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class ProductReturnTableViewCell: UITableViewCell {

    @IBOutlet weak var returnidLabel: UILabel!
    
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
    
   
    @IBOutlet weak var orderIdLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
