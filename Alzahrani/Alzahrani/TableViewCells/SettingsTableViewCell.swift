//
//  SettingsTableViewCell.swift
//  Alzahrani
//
//  Created by Hardwin on 27/06/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

protocol SwitchStateHandlerDelegate: NSObjectProtocol {
	func switchStateChanged(withState state: Bool, atCell cell: SettingsTableViewCell)
}

class SettingsTableViewCell: UITableViewCell {
	
	weak var switchStateDelegate: SwitchStateHandlerDelegate?

    //MARK:- IB-Outlets:
    
    @IBOutlet weak var appModeTypeLabel: UILabel!
    @IBOutlet weak var appModeTypeSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
	
	@IBAction func switchStateChanged(_ sender: Any) {
		
		if let offlineSwitch = sender as? UISwitch {
			if offlineSwitch.isOn {
				UserDefaultManager.sharedManager().currentAppMode = "Offline"
				self.switchStateDelegate?.switchStateChanged(withState: true, atCell: self)
			} else {
				UserDefaultManager.sharedManager().currentAppMode = "Online"
				self.switchStateDelegate?.switchStateChanged(withState: false, atCell: self)
			}
		}
	}
}
