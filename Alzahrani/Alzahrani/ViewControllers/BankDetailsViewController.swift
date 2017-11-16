//
//  BankDetailsViewController.swift
//  Alzahrani
//
//  Created by Hardwin on 23/07/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class BankDetailsViewController: UIViewController {
    
    
    @IBOutlet weak var bankDetailsLabel: UILabel!

    //MARK:- Life Cycle:
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialUISetup()
        self.downloadBankDetails()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

//MARK:- Helper Methods:
extension BankDetailsViewController {
    
    func initialUISetup() {
        self.title = "Bank Details"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    func downloadBankDetails() {
        SyncManager.syncOperation(operationType: .getBankDetails, info: "") { (response, error
        ) in
            if error == nil {
                if let htmlContent = response as? [String: AnyObject] {
                    
                    //print("Bank Details: \(htmlContent)")
                    let englishDetails = htmlContent["bank_transfer_bank1"]
                    let aranicDetails = htmlContent["bank_transfer_bank2"]
                    
//                    print("English Bank Details: \(englishDetails)")
//                    print("English Bank Details: \(aranicDetails)")
                    self.bankDetailsLabel.text = englishDetails as! String?
                }

            }
        }
    }
}

