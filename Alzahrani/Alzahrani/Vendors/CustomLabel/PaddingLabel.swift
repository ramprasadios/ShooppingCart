//
//  PaddingLabel.swift
//  Alzahrani
//
//  Created by Ashok Kumar on 15/05/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class PaddingLabel: UILabel {

   
        
        @IBInspectable var topInset: CGFloat = 0
        @IBInspectable var bottomInset: CGFloat = 0
        @IBInspectable var leftInset: CGFloat = 20.0
        @IBInspectable var rightInset: CGFloat = 0
    override public var intrinsicContentSize: CGSize {
        get {
            var intrinsicSuperViewContentSize = super.intrinsicContentSize
            intrinsicSuperViewContentSize.height += topInset + bottomInset
            intrinsicSuperViewContentSize.width += leftInset + rightInset
            return intrinsicSuperViewContentSize
            
        }
    }
        override func drawText(in rect: CGRect) {
            let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
            super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
        }
   
    

}
