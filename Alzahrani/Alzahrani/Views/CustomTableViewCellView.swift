//
//  CustomTableViewCellView.swift
//  Alzahrani
//
//  Created by Hardwin on 08/05/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class CustomTableViewCellView: UIView {
    
    //MARK:- IB Outlets
    @IBOutlet weak var productsCollectionView: UICollectionView!
    

    //MARK:- Life Cycle:
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
