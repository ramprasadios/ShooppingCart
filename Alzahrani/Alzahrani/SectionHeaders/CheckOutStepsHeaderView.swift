//
//  CheckOutStepsHeaderView.swift
//  Alzahrani
//
//  Created by Hardwin on 12/07/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

protocol SectionHeaderDelegate: NSObjectProtocol {
    func sectionTitleTapped(atSection section: Int)
}

class CheckOutStepsHeaderView: UITableViewHeaderFooterView {
    
    weak var sectionDelegate: SectionHeaderDelegate?
    
    @IBOutlet weak var chekoutHeaderStepTitleButton: UIButton!
    
    @IBAction func checkoutHeaderTapped(_ sender: Any) {
        self.sectionDelegate?.sectionTitleTapped(atSection: self.chekoutHeaderStepTitleButton.tag)
    }
}
