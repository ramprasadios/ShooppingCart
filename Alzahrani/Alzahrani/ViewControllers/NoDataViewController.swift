//
//  NoDataViewController.swift
//  Alzahrani
//
//  Created by Hardwin on 02/07/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

protocol NoDataDisplayDelegate: NSObjectProtocol {
    func didTapContinueShopping()
}

class NoDataViewController: UIViewController {
    
    @IBOutlet weak var noDataImageView: UIImageView!
    @IBOutlet weak var noDataTextLabel: UILabel!
    @IBOutlet weak var noDataMessageButton: UIButton!
    
    var noDataText: String = ""
    var noDataMsgButton: String = ""
    weak var delegate: NoDataDisplayDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.noDataTextLabel.text = noDataText
        self.noDataMessageButton.setTitle(noDataMsgButton, for: .normal)
        self.noDataMessageButton.setTitle(noDataMsgButton, for: .highlighted)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func continueShoppingTapped(_ sender: Any) {
        self.showHomePage()
    }
    
    func showHomePage() {
        self.delegate?.didTapContinueShopping()
        self.dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: Notification.Name(Constants.sliderMenuFieldTapNotification), object: nil, userInfo: nil)
        })
    }
}
