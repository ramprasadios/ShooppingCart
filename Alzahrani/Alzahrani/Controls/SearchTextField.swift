//
//  SearchTextField.swift
//  Alzahrani
//
//  Created by Hardwin on 30/05/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation
import UIKit

protocol SearchTextFieldDelegate: NSObjectProtocol {
    func didTapVoiceSearchButton()
}

class SearchTextField: UITextField {
    
    //Properties:
    var searchByVoiceButton: UIButton?
    weak var searchFielddelegate: SearchTextFieldDelegate?
    //MARK:- Life Cycle:
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.rightViewRect(forBounds: bounds)
        rect.origin.x -= 5
        return rect
    }
    
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.leftViewRect(forBounds: bounds)
        rect.origin.x += 5
        return rect
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addLeftView()
        //self.addRightView()
    }
}

extension SearchTextField {
    
    func addLeftView() {
       self.leftViewMode = .always
        self.leftView = UIImageView(image: UIImage(named: "searchIcon"))
    }
    
    func addRightView() {
        
        self.rightViewMode = .always
        searchByVoiceButton = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: 25.0, height: 25.0))
        searchByVoiceButton?.setImage(UIImage(named: "microphone_icon"), for: .normal)
        searchByVoiceButton?.setImage(UIImage(named: "microphone_icon"), for: .highlighted)
        searchByVoiceButton?.addTarget(self, action: #selector(SearchTextField.searchByVoiceTapped), for: .touchUpInside)
        self.rightView = searchByVoiceButton
        self.rightView?.tintColor = UIColor.blue
    }
    
    func searchByVoiceTapped() {
        NotificationCenter.default.post(name: Notification.Name("VoiceSearchButtonTapped"), object: nil)
    }
}
