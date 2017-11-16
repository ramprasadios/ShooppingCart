//
//  SubCategoriesOffersTableViewCell.swift
//  Alzahrani
//
//  Created by Hardwin on 08/05/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class SubCategoriesOffersTableViewCell: UITableViewCell {

    //MARK:- Properties:
    
    @IBOutlet weak var categoryImageView: UIImageView!
    
    
    //MARK:- Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
}
