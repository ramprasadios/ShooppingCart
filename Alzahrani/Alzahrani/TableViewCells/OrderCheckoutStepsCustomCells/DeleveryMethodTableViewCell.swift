//
//  DeleveryMethodTableViewCell.swift
//  Alzahrani
//
//  Created by Hardwin on 13/07/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

protocol DeleveryStepDelegate: NSObjectProtocol {
    func didTapDeleveryContinueButton(atCell cell: DeleveryMethodTableViewCell)
}

class DeleveryMethodTableViewCell: UITableViewCell {
    
    @IBOutlet weak var shippingRadioButton: ISRadioButton!
    @IBOutlet weak var shippingTypeLabel: UILabel!
    @IBOutlet weak var shippingChargesLabel: UILabel!
    @IBOutlet weak var shippingPriceLabel: UILabel!
    
    @IBOutlet weak var commentsTextView: UITextView!
    
    
    weak var delegate: DeleveryStepDelegate?
    var deleveryAddress: [String]?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initialUISetup()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func continueButtonTapped(_ sender: Any) {
        self.delegate?.didTapDeleveryContinueButton(atCell: self)
    }
}

extension DeleveryMethodTableViewCell {
    
    func initialUISetup() {
//        self.commentsTextView.layer.borderWidth = 2.0
//        self.commentsTextView.layer.borderColor = UIColor.lightGray.cgColor
    }
}
