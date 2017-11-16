//
//  MenuHeaderTableViewCell.swift
//  Yachtzap
//
//  Created by Ashok Kumar on 10/10/16.
//  Copyright © 2016 hardwin. All rights reserved.
//

import UIKit

class MenuHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var userName: UILabel!

    @IBOutlet weak var userImage: UIImageView!
    
    
    @IBOutlet weak var usermobile: UILabel!
    
    @IBOutlet weak var useremail: UILabel!
    
    @IBOutlet weak var dismissButton: UIButton!
    
    
    @IBOutlet weak var welcomeMessageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
