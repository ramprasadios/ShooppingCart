//
//  OrderHistoryTableViewCell.swift
//  Alzahrani
//
//  Created by shilpa shree on 5/26/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class OrderHistoryTableViewCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var orderid: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var orderstatusLbel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
