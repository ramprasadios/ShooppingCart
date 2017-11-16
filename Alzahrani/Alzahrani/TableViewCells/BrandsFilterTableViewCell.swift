//
//  BrandsFilterTableViewCell.swift
//  Alzahrani
//
//  Created by Hardwin on 06/06/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class BrandsFilterTableViewCell: UITableViewCell {

    //MARK:- IB-Outlet
    @IBOutlet weak var brandImageView: UIImageView!
    @IBOutlet weak var brandNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension BrandsFilterTableViewCell {
    
}
