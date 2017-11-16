//
//  RecurringPaymentTableViewCell.swift
//  Alzahrani
//
//  Created by shilpa shree on 6/13/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class RecurringPaymentTableViewCell: UITableViewCell {

    
    @IBOutlet weak var viewButton: UIButton!
    @IBOutlet weak var profileIDLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    @IBOutlet weak var statusLabel: UILabel!
    
    
    @IBOutlet weak var productLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
