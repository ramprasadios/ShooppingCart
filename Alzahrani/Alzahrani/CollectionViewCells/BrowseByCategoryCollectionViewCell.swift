//
//  BrowseByCategoryCollectionViewCell.swift
//  Alzahrani
//
//  Created by Hardwin on 03/05/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class BrowseByCategoryCollectionViewCell: UICollectionViewCell {
    
    //IB-Outlets:
    @IBOutlet weak var prodcutNameLebel1: UILabel!
    @IBOutlet weak var productNameLabel2: UILabel!
    @IBOutlet weak var productNameLabel3: UILabel!
    
    @IBOutlet weak var productImageView1: UIImageView!
    @IBOutlet weak var productImageView2: UIImageView!
    @IBOutlet weak var productImageView3: UIImageView!
    
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    
    //MARK:- Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if AppManager.languageType() == .english {
            //visualEffectView.transform = CGAffineTransform(scaleX: 1.0, y: -1.0)
        } else {
			productImageView1.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
			productImageView1.semanticContentAttribute = .forceLeftToRight
            visualEffectView.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        }
    }
}
