//
//  ReviewsecondTableViewCell.swift
//  Alzahrani
//
//  Created by shilpa shree on 5/17/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class ReviewsecondTableViewCell: UITableViewCell {

    
    
    @IBOutlet weak var qtyLabel: UITextField!
    
    
    @IBOutlet weak var productNameLabel: UITextField!
    
    @IBOutlet weak var modelLabel: UITextField!
    
    @IBOutlet weak var serialNo: UITextField!
    
    
    
    @IBOutlet weak var unitprice: UITextField!
    
    
    
    @IBOutlet weak var totalprice: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
