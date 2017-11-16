//
//  CouponCodeTableViewSection.swift
//  Alzahrani
//
//  Created by Hardwin on 26/07/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

protocol CouponSectionDelegate: NSObjectProtocol {
    func didTapCouponSection()
}

class CouponCodeTableViewSection: UITableViewHeaderFooterView {

    weak var delegate: CouponSectionDelegate?
    //MARK:- Life Cycle:
    
    
    @IBAction func useCouponButtonTapped(_ sender: Any) {
        self.delegate?.didTapCouponSection()
    }
}
