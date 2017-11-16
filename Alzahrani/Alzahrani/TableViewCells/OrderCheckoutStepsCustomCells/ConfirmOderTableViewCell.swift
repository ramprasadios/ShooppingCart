//
//  ConfirmOderTableViewCell.swift
//  Alzahrani
//
//  Created by Hardwin on 19/07/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

protocol ConfirmOrderDelegate: NSObjectProtocol {
    func confirmOrderButtonTapped(atCell cell: ConfirmOderTableViewCell)
}

class ConfirmOderTableViewCell: UITableViewCell {

    @IBOutlet weak var confirmOrderButton: UIButton!
    
    weak var confirmOrderDelegate: ConfirmOrderDelegate?
    
    //MARK:- Life Cycle:
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func confirmOrderButtonTapped(_ sender: Any) {
        self.confirmOrderButton.isEnabled = false
        self.confirmOrderDelegate?.confirmOrderButtonTapped(atCell: self)
    }
}
