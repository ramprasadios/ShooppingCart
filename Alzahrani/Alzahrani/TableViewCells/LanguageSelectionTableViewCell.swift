//
//  LanguageSelectionTableViewCell.swift
//  Alzahrani
//
//  Created by Hardwin on 09/06/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class LanguageSelectionTableViewCell: UITableViewCell {
    
    //MARK:- IB-Outlets:
    
    @IBOutlet weak var languageImageView: UIImageView!
    @IBOutlet weak var languageNameLabel: UILabel!
    @IBOutlet weak var checkMarkImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
