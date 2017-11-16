//
//  OrderDetailTableViewCell.swift
//  Alzahrani
//
//  Created by shilpa shree on 6/2/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class OrderDetailTableViewCell: UITableViewCell {

 
    @IBOutlet weak var orderIDLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var paymentLabel: UILabel!
    
    
    
    @IBOutlet weak var cashLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
