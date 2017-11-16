//
//  CheckBox.swift
//  DrOwl
//
//  Created by Sireesha V on 4/13/16.
//  Copyright © 2016 hardwin. All rights reserved.
//

import UIKit
protocol CheckboxDelegate
{
    func checkBoxClicked(_ checked:Bool, withTag tag: Int)
}

class CheckBox: UIButton {
    var delegate:CheckboxDelegate?
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    let checkedImage = UIImage(named: "checked")! as UIImage
    let uncheckedImage = UIImage(named: "unChecked")! as UIImage
    
    // Bool property
    var isChecked: Bool = false {
        didSet{
            if isChecked == true {
                self.setImage(checkedImage, for: UIControlState())
            } else {
                self.setImage(uncheckedImage, for: UIControlState())
            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
       self.addTarget(self, action: #selector(CheckBox.buttonClicked(_:)), for: UIControlEvents.touchUpInside)
//        self.userInteractionEnabled = true
//        self.isChecked = false
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
            self.addTarget(self, action: #selector(CheckBox.buttonClicked(_:)), for: UIControlEvents.touchUpInside)
    }
    override func awakeFromNib() {
        
        self.isUserInteractionEnabled = true
        self.isChecked = false
    }
    
    func buttonClicked(_ sender: UIButton) {
        if sender == self {
            if isChecked == true {
                isChecked = false
                
            } else {
                isChecked = true
            }
            delegate?.checkBoxClicked(isChecked, withTag: self.tag)
        }
    }

}
