//
//  PolicyViewController.swift
//  Alzahrani
//
//  Created by Hardwin on 04/08/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

protocol PolicyHandlerDelegate: NSObjectProtocol {
    func didPolicyCloseButtonTapped()
}

class PolicyViewController: UIViewController {
    
    @IBOutlet weak var policyTitleLabel: UILabel!
    @IBOutlet weak var policyDescriptionLabel: UILabel!
    
    
    weak var delegate: PolicyHandlerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.getPolicyData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.delegate?.didPolicyCloseButtonTapped()
        self.dismiss(animated: true, completion: nil)
    }
}

extension PolicyViewController {
    
    func getPolicyData() {
        let langId = (AppManager.languageType() == .arabic) ? "2" : "1"
        let syncParam = "&information_id=7&language_id=\(langId)"
        SyncManager.syncOperation(operationType: .getPolicyTermsData, info: syncParam) { (response, error) in
            if error == nil {
                
                if let policyData = response as? [String: AnyObject] {
                    if let policyDescrition = policyData["description"] as? String, let title = policyData["meta_title"] as? String {
                        self.policyTitleLabel.text = title
                        self.policyDescriptionLabel.attributedText = policyDescrition.htmlToAttributedString
                    }
                }
            } else {
            }
        }
    }
}
