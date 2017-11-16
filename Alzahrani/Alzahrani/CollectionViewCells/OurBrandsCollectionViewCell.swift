//
//  OurBrandsCollectionViewCell.swift
//  Alzahrani
//
//  Created by Hardwin on 03/05/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class OurBrandsCollectionViewCell: UICollectionViewCell {
    
    //MARK:- IBO-utlets:
    @IBOutlet weak var ourBrandsImageView: UIImageView!
    @IBOutlet weak var brandLable: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()        
        self.layer.borderWidth = 1.0
        //UIColor(rgba: "EBEBFF").cgColor
        self.layer.borderColor = UIColor(rgba: "EBEBFF").cgColor
        self.layer.cornerRadius = 6.0
        self.layer.masksToBounds = true
    }
}
