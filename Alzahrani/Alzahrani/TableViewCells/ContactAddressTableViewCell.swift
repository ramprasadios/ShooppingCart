//
//  ContactAddressTableViewCell.swift
//  Alzahrani
//
//  Created by shilpa shree on 6/9/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class ContactAddressTableViewCell: UITableViewCell {
    
    @IBOutlet weak var toolFreeNumberLabel: UILabel!
    
    @IBOutlet weak var whatsappNumberLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.toolFreeNumberLabel.semanticContentAttribute = .forceLeftToRight
        //self.whatsappNumberLabel.semanticContentAttribute = .forceLeftToRight
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
