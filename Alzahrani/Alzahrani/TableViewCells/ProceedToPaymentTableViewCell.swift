//
//  ProceedToPaymentTableViewCell.swift
//  Alzahrani
//
//  Created by Hardwin on 20/07/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

protocol PaymentActionDelegate: NSObjectProtocol {
    
    func didTapProceedToPaymentButton(atCell cell: ProceedToPaymentTableViewCell)
}

class ProceedToPaymentTableViewCell: UITableViewCell {

    weak var paymentDelegate: PaymentActionDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func proceedToPaymentButtonTapped(_ sender: Any) {
        print("payment acction")
        
        self.paymentDelegate?.didTapProceedToPaymentButton(atCell: self)
    }
}
