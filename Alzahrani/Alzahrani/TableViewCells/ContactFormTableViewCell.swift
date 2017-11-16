//
//  ContactFormTableViewCell.swift
//  Alzahrani
//
//  Created by shilpa shree on 6/9/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class ContactFormTableViewCell: UITableViewCell {
    @IBOutlet weak var nameField: SkyFloatingLabelTextField!

    @IBOutlet weak var emailField: SkyFloatingLabelTextField!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var contactFromLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.nameField.placeholder = NSLocalizedString("NAME_FIELD", comment: "")
        self.emailField.placeholder = NSLocalizedString("Email", comment: "")
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
