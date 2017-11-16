//
//  ImageCollectionViewCell.swift
//  Alzahrani
//
//  Created by Hardwin on 02/05/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var collectionImageView: UIImageView!
    @IBOutlet weak var imageDownloadIndicator: UIActivityIndicatorView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
