//
//  RewardsHistoryTableViewCell.swift
//  Alzahrani
//
//  Created by shilpa shree on 6/16/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class RewardsHistoryTableViewCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var piontLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
