//
//  FIlterMenuCollectionViewCell.swift
//  Alzahrani
//
//  Created by Hardwin on 05/06/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class FIlterMenuCollectionViewCell: UICollectionViewCell {
    
    //MARK:- IB-Outlets
    @IBOutlet weak var menuLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.lightGray.cgColor
    }
}
