//
//  OrderDetailFourthTableViewCell.swift
//  Alzahrani
//
//  Created by shilpa shree on 5/31/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class OrderDetailFourthTableViewCell: UITableViewCell {

    @IBOutlet weak var headingLabel: UILabel!
    
    @IBOutlet weak var addresssTextView: UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override func layoutSubviews()
    {
        super.layoutSubviews()
        let layer2 = CALayer()
        layer2.frame = CGRect(x:0,y: addresssTextView.frame.size.height - 1,width: addresssTextView.frame.size.width,height:1)
        layer2.backgroundColor = UIColor.gray.cgColor
        
        layer2.shadowColor = UIColor.gray.cgColor
        layer2.shadowOpacity = 1
        layer2.shadowOffset = CGSize.init(width: 3, height: 4)
        layer2.shadowRadius = 10
        layer2.shadowPath = UIBezierPath(rect: layer2.bounds).cgPath
        
         addresssTextView.layer.addSublayer(layer2)
        

}
}
