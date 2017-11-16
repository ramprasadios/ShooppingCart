//
//  ProgressIndicatorView.swift
//  ProgressIndicators
//
//  Created by Ramprasad A on 02/03/17.
//  Copyright © 2017 Softttrends Software Pvt. Ltd. All rights reserved.
//

import Foundation
import UIKit

class ProgressIndicatorView: UIView {
    
    @IBOutlet weak var progressContainer: UIView!
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    fileprivate var xib : UIView? {
        willSet {
            if self.xib != nil {
                self.xib?.removeFromSuperview()
            }
        } didSet {
            if self.xib != nil {
                self.addSubview(self.xib!)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadXib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadXib()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        roundViewCorner()
    }
}

extension ProgressIndicatorView {
    
    func loadXib() {
        xib = loadIndicatorViewFromNib(nibName: "ProgressIndicatorView")
    }

    fileprivate func loadIndicatorViewFromNib(nibName name : String) -> UIView {
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
    
    func roundViewCorner() {
        self.layer.cornerRadius = 10.0
        self.layer.masksToBounds = true
        
        self.progressView.layer.cornerRadius = 5.0
        self.progressView.clipsToBounds = true
    }
}
