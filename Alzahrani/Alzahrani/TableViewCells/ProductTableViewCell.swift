//
//  ProductTableViewCell.swift
//  Alzahrani
//
//  Created by Ashok Kumar on 12/05/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

protocol MyCartActionDelegate: NSObjectProtocol {
    func didTapDeleteButton(atCell cell: ProductTableViewCell)
    func didTapAddtoWishListButton(atCell cell: ProductTableViewCell)
    func didTapRefreshButton(atCell cell: ProductTableViewCell)
    func incrementProductCountTapped(atCell cell: ProductTableViewCell)
    func decrementProductCountTapped(atCell cell: ProductTableViewCell)
    func quantityTextFieldTapped(atCell cell: ProductTableViewCell)
    func quantityDoneButtonTapped(atCell cell: ProductTableViewCell)
}

class ProductTableViewCell: UITableViewCell {
    
    @IBOutlet weak var addwishList: UIButton!
    @IBOutlet weak var removeProduct: UIButton!
    @IBOutlet weak var refreshButton: UIButton!
    
    @IBOutlet weak var incrementQtyButton: UIButton!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var originalPriceLabel: UILabel!
    @IBOutlet weak var offerPriceLabel: UILabel!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var decrementQtyButton: UIButton!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var percentageLabel: UILabel!
    
    weak var cartDelegate: MyCartActionDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.quantityTextField.delegate = self
        self.addDoneButton()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.quantityTextField.delegate = self
        self.addDoneButton()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.layoutIfNeeded()
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
    }
    
    
    @IBAction func removeProductTap(_ sender: Any) {
        self.removeProduct.isEnabled = false
        self.cartDelegate?.didTapDeleteButton(atCell: self)
    }
    
    
    @IBAction func refreshProductTap(_ sender: Any) {
        self.refreshButton.isEnabled = false
        self.cartDelegate?.didTapRefreshButton(atCell: self)
    }
    

    @IBAction func wishlistProductTap(_ sender: Any) {
        self.addwishList.isEnabled = false
        self.updateConstraintsIfNeeded()
        self.layoutIfNeeded()
        self.cartDelegate?.didTapAddtoWishListButton(atCell: self)
    }
}

extension ProductTableViewCell {
    
    func addDoneButton() {
        let tooBar: UIToolbar = UIToolbar()
        tooBar.barStyle = UIBarStyle.blackTranslucent
        tooBar.items=[
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(ProductTableViewCell.doneButtonTapped))]
        tooBar.sizeToFit()
        self.quantityTextField.inputAccessoryView = tooBar
    }
    
    func doneButtonTapped() {
        self.cartDelegate?.quantityDoneButtonTapped(atCell: self)
        self.quantityTextField.resignFirstResponder()
    }
}

extension ProductTableViewCell: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.cartDelegate?.quantityTextFieldTapped(atCell: self)
        return true
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        return (textField.text?.characters.count ?? 0 ) + string.characters.count - range.length < 4
    }
}
