//
//  OffersCollectionViewCell.swift
//  Alzahrani
//
//  Created by Hardwin on 03/05/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class OffersCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var firstOfferImageView: UIImageView!
    
    @IBOutlet weak var imageDownloadIndicator: UIActivityIndicatorView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor(rgba: "EBEBFF").cgColor
    }
}

