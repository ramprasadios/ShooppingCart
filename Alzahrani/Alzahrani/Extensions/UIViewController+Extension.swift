//
//  UIViewController+Extension.swift
//  nHance
//
//  Created by Ramprasad A on 20/01/17.
//  Copyright © 2017 Pradeep BM. All rights reserved.
//

import Foundation
import UIKit

enum DimStatus : Int {
    case ShowDim = 0, RemoveDim
}

typealias DropDownCompletion                 = ((_ tag : Int, _ value : String) -> Void)
typealias GestureCompletion                 = ((_ tapped : Bool) -> Void)
typealias overlayAnimationBlock             = () -> Void
typealias overlayCompletionBlock            = (Bool) -> Void

let DimViewTag = 100

//MARK:- Overlay extention
extension UIViewController {
    
    /**
     Add a overlay to reference View
     */
    func dimOverlay(direction: DimStatus, color: UIColor = UIColor.black, alpha: CGFloat = 0.0, duration : Double = 0.3, animationBlock : @escaping overlayAnimationBlock, dimGestureHandler : @escaping GestureCompletion, completionBlock : @escaping overlayCompletionBlock) {
        
        DispatchQueue.main.async
            {
            switch direction {
            case .ShowDim:
                
                // Create and add a overlayview
                if let _ = self.view.viewWithTag(DimViewTag) as? OverlayView {
                    
                } else {
                    let overlayView = OverlayView(frame: self.view.frame) { (tap) in
                        dimGestureHandler(tap)
                    }
                    overlayView.backgroundColor = color
                    overlayView.alpha = 0.0
                    overlayView.tag = DimViewTag;
                    self.view.addSubview(overlayView)
                    
                    // Update Auto Layout
                    overlayView.translatesAutoresizingMaskIntoConstraints = false
                    self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[overlayView]|", options: [], metrics: nil, views: ["overlayView": overlayView]))
                    self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[overlayView]|", options: [], metrics: nil, views: ["overlayView": overlayView]))
                    
                    //Animate a dim view with alpha value
                    UIView.animate(withDuration: duration, animations:  { () -> Void in
                        overlayView.alpha = alpha
                        animationBlock()
                        } , completion: { (complete) -> Void in
                            completionBlock(complete)
                    })
                }
                
            case .RemoveDim:
                UIView.animate(withDuration: duration, animations: { () -> Void in
                    animationBlock()
                    }, completion: { (complete) -> Void in
                        
                        //Remove dim view from superView
                        if let overlayView = self.view.viewWithTag(DimViewTag) as? OverlayView {
                            overlayView.removeFromSuperview()
                        }
                        
                        completionBlock(complete)
                })
            }
        }
    }
}
