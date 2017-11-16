//
//  SpecificationsTableViewCell.swift
//  Alzahrani
//
//  Created by Hardwin on 18/06/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class SpecificationsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var specificationTitle: UILabel!
    
    @IBOutlet weak var specificationDetail: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
