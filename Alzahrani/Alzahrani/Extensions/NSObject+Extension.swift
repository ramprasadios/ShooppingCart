//
//  UITableViewCell+Extension.swift
//  nHance
//
//  Created by Ramprasad A on 13/01/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation
import UIKit

extension NSObject {
    
    class func selfName() -> String {
        let clasName = NSStringFromClass(self).components(separatedBy: ".")
        if clasName.count > 1 {
            return clasName[1]
        } else {
            return clasName.first ?? ""
        }
    }
    
    class func nib(_ bundle : Bundle? = nil) -> UINib {
        return UINib(nibName: selfName(), bundle: bundle)
    }
}
