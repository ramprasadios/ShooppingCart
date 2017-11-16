//
//  UITextField+Extension.swift
//  nHance
//
//  Created by Ramprasad A on 31/01/17.
//  Copyright © 2017 Pradeep BM. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {
    
    func setBottomBorder(color:String) {
        self.borderStyle = .none;
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor(rgba: color).cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: self.frame.size.height)
        
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
    
    func addHideinputAccessoryView() {
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let item = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done,
                                   target: self, action: #selector(self.resignFirstResponder))
        toolbar.setItems([item], animated: true)
        
        self.inputAccessoryView = toolbar
    }
}
