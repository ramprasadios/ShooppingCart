//
//  MyAccountTableViewCell.swift
//  Alzahrani
//
//  Created by shilpa shree on 5/26/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class MyAccountTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
