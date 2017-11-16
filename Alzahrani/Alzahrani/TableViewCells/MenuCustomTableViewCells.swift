//
//  MenuCustomTableViewCells.swift
//  Alzahrani
//
//  Created by Hardwin on 09/05/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class MenuCustomTableViewCells: UITableViewCell {
    
    //MARK:- IB-Outlets:
    @IBOutlet weak var menuFieldImageView: UIImageView!
    @IBOutlet weak var menuFieldNameLabel: UILabel!
    
    //MARK:- Life Cycle:
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
