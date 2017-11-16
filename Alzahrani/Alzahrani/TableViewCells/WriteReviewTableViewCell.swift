//
//  WriteReviewTableViewCell.swift
//  Alzahrani
//
//  Created by shilpa shree on 5/25/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class WriteReviewTableViewCell: UITableViewCell {

   //@Mark - IBoutlets
    
   
    
    @IBOutlet weak var reviewHeadingLabel: UILabel!
    
   
   
    @IBOutlet weak var reviewHeadLabel: UILabel!
    
    @IBOutlet weak var starImageOne: UIImageView!
    
    @IBOutlet weak var starImageTwo: UIImageView!
    
    
    @IBOutlet weak var starImageThree: UIImageView!
    
    
    @IBOutlet weak var starImageFour: UIImageView!
    
    @IBOutlet weak var starImageFive: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
