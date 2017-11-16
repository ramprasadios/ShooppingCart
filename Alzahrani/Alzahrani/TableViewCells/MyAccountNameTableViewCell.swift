//
//  MyAccountNameTableViewCell.swift
//  Alzahrani
//
//  Created by shilpa shree on 5/26/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class MyAccountNameTableViewCell: UITableViewCell {

    @IBOutlet weak var arrow: UIButton!
    @IBOutlet weak var headingLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        if AppManager.languageType() == .english {
            self.arrow.setImage(UIImage(named: "right_arrow_icon"), for: .normal)
            self.arrow.setImage(UIImage(named: "right_arrow_icon"), for: .highlighted)
        } else {
            self.arrow.setImage(UIImage(named: "left_arrow_icon"), for: .normal)
            self.arrow.setImage(UIImage(named: "left_arrow_icon"), for: .highlighted)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
