//
//  UIWindow+Extension.swift
//  nHance
//
//  Created by Pradeep BM on 1/24/17.
//  Copyright © 2017 Pradeep BM. All rights reserved.
//

import Foundation
import UIKit

func topMostController(viewController : UIViewController? = nil) -> UIViewController? {
    var topController = viewController
    while topController?.presentedViewController != nil {
        topController = topController?.presentedViewController
    }
    return topController
}

extension UIWindow {
    
    func currentViewController() -> UIViewController? {
        var currentViewController = topMostController(viewController: self.rootViewController)
        
        if let navControl = currentViewController as? UINavigationController {
            if navControl.topViewController != nil {
                currentViewController = topMostController(viewController: navControl.topViewController)
            }
        } else if let tabControl = currentViewController as? UITabBarController {
            if tabControl.selectedViewController != nil {
                currentViewController = topMostController(viewController: tabControl.selectedViewController)
            }
        }
        
        return currentViewController
    }
}
