//
//  PaymentMethodTableViewCell.swift
//  Alzahrani
//
//  Created by Hardwin on 13/07/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class PaymentMethodTableViewCell: UITableViewCell {

    var nextStep: NextStepHandler?
    
    @IBOutlet weak var paymentMethodButton: ISRadioButton!
    @IBOutlet weak var paymentMethodTypeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
