//
//  CustomTextField.swift
//  Alzahrani
//
//  Created by Hardwin on 09/05/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

protocol FloatingTextFieldDelegate: NSObjectProtocol {
    func textFieldStartedEditing()
}

import Foundation
import UIKit

@IBDesignable
class CustomTextField: UITextField {
    
    //MARK:- Properties:
    var floatingLabel = UILabel()
    weak var floatTextFieldDelegate: FloatingTextFieldDelegate?
    
    @IBInspectable var placeHolderText: String? {
        didSet {
            self.setAttributedPlaceholder()
        }
    }
    
    //MARK:- Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialSetup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialSetup()
    }
}

extension CustomTextField {
    
    func initialSetup() {
        self.floatingLabel = UILabel(frame: CGRect(x: self.frame.origin.x, y: self.frame.origin.y - 15.0, width: self.frame.size.width, height: self.frame.size.height))
        setBorderToTextField()
    }
    
    func setBorderToTextField() {
        self.setBottomBorder(color: "#33B5E5")
        self.borderStyle = .none
    }
    
    func setAttributedPlaceholder() {
        let placeHolderString = self.placeHolderText
        
        var attributes = [String: AnyObject]()
        attributes[NSForegroundColorAttributeName] = UIColor(rgba: "#33B5E5")
        attributes[NSFontAttributeName] = UIFont.boldSystemFont(ofSize: 12)
        
        let attributedString = NSMutableAttributedString(string: placeHolderString!, attributes: attributes)
        self.attributedPlaceholder = attributedString
    }
}

extension CustomTextField: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.floatingLabel.text = self.placeHolderText
    }

}

extension CustomTextField: FloatingTextFieldDelegate {
    
    func textFieldStartedEditing() {
        
    }
}
