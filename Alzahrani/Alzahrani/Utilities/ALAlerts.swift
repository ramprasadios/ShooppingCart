//
//  ALAlerts.swift
//  Alzahrani
//
//  Created by Abhisek on 02/07/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation
import UIKit


class ALAlerts: NSObject {
    
    class func showToast(message: String) {
        let rootVC = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController
        rootVC?.view.makeToast(message, duration: 1.0, position: .bottom)
    }
    
}
