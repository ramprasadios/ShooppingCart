//
//  RecurringTableViewCell.swift
//  Alzahrani
//
//  Created by shilpa shree on 6/13/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class RecurringTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var profileLabel: UILabel!
    
    
    @IBOutlet weak var statusLabel: UILabel!
    
    
    @IBOutlet weak var paymentLabel: UILabel!
    
    
    @IBOutlet weak var productLabel: UILabel!
    
    @IBOutlet weak var quantityLabel: UILabel!
    
    @IBOutlet weak var orderID: UILabel!
    
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    @IBOutlet weak var referenceLabel: UILabel!
    
    @IBOutlet weak var dateTransactionLabel: UILabel!
        @IBOutlet weak var typeLabel: UILabel!
       
    @IBOutlet weak var amountLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
