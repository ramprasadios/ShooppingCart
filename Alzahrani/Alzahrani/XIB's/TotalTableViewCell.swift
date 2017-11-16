//
//  TotalTableViewCell.swift
//  Alzahrani
//
//  Created by Hardwin on 22/07/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class TotalTableViewCell: UITableViewCell {
    
    @IBOutlet weak var fieldTitleLabel: UILabel!
    
    @IBOutlet weak var fieldValueLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
