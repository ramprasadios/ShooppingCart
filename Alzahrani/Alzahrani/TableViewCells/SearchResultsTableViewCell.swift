//
//  SearchResultsTableViewCell.swift
//  Alzahrani
//
//  Created by Ashok Kumar on 01/09/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class SearchResultsTableViewCell: UITableViewCell {

	@IBOutlet weak var productImageView: UIImageView!
	@IBOutlet weak var productNameLabel: UILabel!
	@IBOutlet weak var productSpecialPriceLabel: UILabel!
	@IBOutlet weak var productPriceLabel: UILabel!
	
	
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
