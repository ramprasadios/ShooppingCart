//
//  BankTransferDetailsCell.swift
//  Alzahrani
//
//  Created by Hardwin on 23/07/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

protocol BankDetailsDelegate: NSObjectProtocol {
    func didTapBankDetailsButton()
}
class BankTransferDetailsCell: UITableViewCell {
    
    //MARK:- Properties
    weak var delegate: BankDetailsDelegate?
    
    @IBOutlet weak var bankDetailsLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func bankTransferTapped(_ sender: Any) {
        self.delegate?.didTapBankDetailsButton()
    }
}
