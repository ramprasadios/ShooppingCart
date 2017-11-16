//
//  BillingDetailsTableViewCell.swift
//  Alzahrani
//
//  Created by Hardwin on 13/07/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

protocol BillingStepDelegate: NSObjectProtocol {
    func didTapContinueButton(atCell cell: BillingDetailsTableViewCell, withUserAddressInfo addressInfo: AddressCellData)
    func didTapNewAddressButton(atCell cell: BillingDetailsTableViewCell)
}

typealias NextStepHandler = ((_ success: Bool) -> Void)

enum AddressType {
    case delevery
    case billing
}

enum DeleveryType {
    case existing
    case new
}

struct AddressCellData {
    let addressType: AddressType
    let deleveryType: DeleveryType
    
    init(withAddressType addrType: AddressType, andDeleveryType deleveryType: DeleveryType) {
        self.addressType = addrType
        self.deleveryType = deleveryType
    }
}

class BillingDetailsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var billingAddressDropdown: DropDownMenuView!
    @IBOutlet weak var addressSelectionButton: ISRadioButton!
    
    
    @IBOutlet weak var existingAddressButton: ISRadioButton!
    @IBOutlet weak var newAddressButton: ISRadioButton!
    
    var billingAddressInfo: AddressCellData?
    var deleveryAddressInfo: AddressCellData?
    var addressInfo: AddressCellData?
    var billingCurrentAddressType: DeleveryType? = .existing
    var existingCurrentAddressType: DeleveryType? = .existing
    var cellType: AddressType?
    weak var delegate: BillingStepDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.existingAddressButton.isSelected = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func existingAddressTapped(_ sender: Any) {
        if self.cellType == .billing {
            self.addressInfo = AddressCellData(withAddressType: .billing, andDeleveryType: .existing)
            self.existingAddressButton.isSelected = true
            self.newAddressButton.isSelected = false
        } else {
            self.addressInfo = AddressCellData(withAddressType: .delevery, andDeleveryType: .existing)
            self.existingAddressButton.isSelected = true
            self.newAddressButton.isSelected = false
        }
    }
    
    @IBAction func newAddressTapped(_ sender: Any) {
		if AppManager.currentApplicationMode() == .online {
			if self.cellType == .delevery {
				self.addressInfo = AddressCellData(withAddressType: .delevery, andDeleveryType: .new)
				self.existingAddressButton.isSelected = false
				self.newAddressButton.isSelected = true
			} else {
				self.addressInfo = AddressCellData(withAddressType: .billing, andDeleveryType: .new)
				self.existingAddressButton.isSelected = false
				self.newAddressButton.isSelected = true
			}
			
			self.delegate?.didTapNewAddressButton(atCell: self)
		} else {
			self.existingAddressButton.isSelected = true
			self.newAddressButton.isSelected = false
			self.delegate?.didTapNewAddressButton(atCell: self)
		}
		
    }
	
    @IBAction func continueBurronTapped(_ sender: Any) {
        
        if self.addressInfo != nil {
            if self.cellType == .delevery {
                self.delegate?.didTapContinueButton(atCell: self, withUserAddressInfo: self.addressInfo!)
            } else {
                self.delegate?.didTapContinueButton(atCell: self, withUserAddressInfo: self.addressInfo!)
            }
        } else {
            self.existingAddressButton.isSelected = true
            if self.cellType == .delevery {
                self.addressInfo = AddressCellData(withAddressType: .delevery, andDeleveryType: .existing)
                self.delegate?.didTapContinueButton(atCell: self, withUserAddressInfo: self.addressInfo!)
            } else {
                self.addressInfo = AddressCellData(withAddressType: .billing, andDeleveryType: .existing)
                self.delegate?.didTapContinueButton(atCell: self, withUserAddressInfo: self.addressInfo!)
            }
        }
        self.addressInfo = nil
    }
}

extension BillingDetailsTableViewCell {
    
    func setCellInfo(withAddressType type: AddressType) {
        switch type {
        case .delevery:
            break
        case .billing:
            break
        }
    }
    
}
 
