//
//  CouponCodeApplyTableViewCell.swift
//  Alzahrani
//
//  Created by Hardwin on 26/07/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

protocol CouponHandlerDelegate: NSObjectProtocol {
    func applyCouponButtonTapped(atCell cell: CouponCodeApplyTableViewCell, withCouponCode code: String)
}

class CouponCodeApplyTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var couponCodeTextField: UITextField!
    
    weak var delegate: CouponHandlerDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.couponCodeTextField.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func applyCouponTapped(_ sender: Any) {
        if couponCodeTextField.text != "" {
            self.delegate?.applyCouponButtonTapped(atCell: self, withCouponCode: couponCodeTextField.text!)
        }
    }
}

extension CouponCodeApplyTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
