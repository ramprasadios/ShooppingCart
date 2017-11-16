//
//  OrderCheckoutAddressTableViewCell.swift
//  Alzahrani
//
//  Created by shilpa shree on 6/1/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

protocol OrderCheckoutButtonDelegate: NSObjectProtocol {
    func newAddressButtonTapped(withCell cell: OrderCheckoutAddressTableViewCell)
    func existingAddressTapped(withCell cell: OrderCheckoutAddressTableViewCell)
}

class OrderCheckoutAddressTableViewCell: UITableViewCell {

    @IBOutlet weak var headinLabel: UILabel!
    @IBOutlet weak var newAddressButton: ISRadioButton!
    @IBOutlet weak var addressView: UITextView!
    
    
    weak var delegate: OrderCheckoutButtonDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let nameLayer = CALayer()
        nameLayer.frame = CGRect(x:0,y:addressView.frame.size.height
            - 1,width:addressView.frame.width,height:1)
        nameLayer.backgroundColor = UIColor.gray.cgColor
        nameLayer.shadowColor = UIColor.gray.cgColor
        nameLayer.shadowOpacity = 1
        nameLayer.shadowOffset = CGSize.init(width: 3, height: 4)
       nameLayer.shadowRadius = 5
        nameLayer.shadowPath = UIBezierPath(rect: nameLayer.bounds).cgPath
        addressView.layer.addSublayer(nameLayer)
    }
    
    @IBAction func existingAddressTapped(_ sender: Any) {
        delegate?.existingAddressTapped(withCell: self)
    }
    
    @IBAction func newAddressTapped(_ sender: Any) {
        delegate?.newAddressButtonTapped(withCell: self)
    }
}
