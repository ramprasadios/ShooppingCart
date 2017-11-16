//
//  UIView+Extensions.swift
//  nHance
//
//  Created by Ramprasad A on 10/05/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation
import UIKit

//MARK:- NSBundle Nib load
extension UIView {
    
    /**
     Load a view from Nib bundle
     */
    class func loadNibNamed(nibName: String, nibOwner: AnyObject? = nil, nibOptions : [NSObject : AnyObject]? = nil) -> UIView? {
        let nibs = Bundle.main.loadNibNamed(nibName, owner: nibOwner, options: nibOptions)
        return nibs?.first as? UIView
    }
    
    /**
     Load a view from self owner xib bundle
     */
    func loadViewFromNib(nibName name : String) -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: name, bundle: bundle)
        
        // Assumes UIView is top level and only object in name.xib file
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        // use bounds not frame or it'll be offset
        view.frame = bounds
        
        // Make the view stretch with containing view
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        
        return view
    }
    
    func lookForSuperviewOfType<T: UIView>(type: T.Type) -> T? {
        return superview as? T ?? superview?.lookForSuperviewOfType(type: type)
    }
    
    /**
     Converts caller(including subclass) to circular
     */
    func circular() {
        layer.cornerRadius = self.bounds.size.width/2;
        layer.masksToBounds = true;
    }
    
    func parentView() -> UIView {
        var parentView = self
        while parentView.superview != nil {
            parentView = parentView.superview!
        }
        return parentView
    }
}
