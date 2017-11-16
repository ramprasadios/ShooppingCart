//
//  CircleLoader.swift
//  nHance
//
//  Created by Ramprasad A on 3/2/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation
import UIKit

class CircleLoader : UIView {
    
    //Properties
    fileprivate var isAnimating : Bool = true
    fileprivate let lineWidth : CGFloat = 3.0
    fileprivate let progressValue : Double = 0.1
    fileprivate let trackColor = UIColor.white
    fileprivate let progressColor = UIColor(rgba: "#31408A")
    
    //Controls
    fileprivate var centerImageView : UIImageView?
    fileprivate var trackLayer = CAShapeLayer()
    fileprivate var progressLayer = CAShapeLayer()
    
    //MARK:- Life cycle
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(frame : CGRect, centreImage image : UIImage, isAnimating animate : Bool? = true) {
        self.init(frame: frame)
        
        self.centerImageView = UIImageView(image: image)
        self.isAnimating = animate ?? false
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.trackLayer.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        self.trackLayer.lineWidth = self.lineWidth;
        self.trackLayer.strokeColor = self.trackColor.cgColor;
        self.trackLayer.fillColor = self.backgroundColor?.cgColor;
        self.trackLayer.lineCap = kCALineCapRound;
        self.layer.addSublayer(self.trackLayer)
        
        self.progressLayer.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        self.progressLayer.lineWidth = self.lineWidth;
        self.progressLayer.strokeColor = self.progressColor.cgColor;
        self.progressLayer.fillColor = self.backgroundColor?.cgColor;
        self.progressLayer.lineCap = kCALineCapRound;
        self.layer.addSublayer(self.progressLayer)
        
        if let ctrImageView = self.centerImageView {
            ctrImageView.frame = CGRect(x: self.lineWidth, y: self.lineWidth, width: (self.frame.size.width ) - (self.lineWidth * 2), height: self.frame.size.height - (self.lineWidth * 2))
            ctrImageView.layer.cornerRadius = ctrImageView.frame.size.width / 2
            ctrImageView.clipsToBounds = true
            self.layer.addSublayer(ctrImageView.layer)
        }
        
        self.startLoader()
    }
}

extension CircleLoader {
    
    func startLoader() {
        self.drawCircle()
        
        if self.isAnimating {
            let animation = CABasicAnimation(keyPath: "transform.rotation.z")
            animation.toValue = NSNumber(value: M_PI * 2.0)
            animation.duration = 1
            animation.isCumulative = true
            animation.repeatCount = Float.infinity
            self.progressLayer.add(animation, forKey: "rotationAnimation")
        }
    }
    
    func drawCircle() {
        let startAngle = M_PI / 2
        var endAngle = (2 * M_PI) + -(M_PI / 8)
        let center = CGPoint(x: self.bounds.size.width / 2, y: self.bounds.size.height / 2)
        let radius = (self.bounds.size.width - self.lineWidth) / 2
        
        let trackBezPath = UIBezierPath()
        let progressBexPath = UIBezierPath()
        
        if self.isAnimating {
            endAngle = (self.progressValue * 2 * M_PI) + startAngle
        } else {
            endAngle = (0.1 * 2 * M_PI) + startAngle;
        }
        
        progressBexPath.addArc(withCenter: center, radius: radius, startAngle: CGFloat(startAngle), endAngle: CGFloat(endAngle), clockwise: true)
        trackBezPath.addArc(withCenter: center, radius: radius, startAngle: 0, endAngle: CGFloat(2 * M_PI), clockwise: true)
        
        self.progressLayer.path = progressBexPath.cgPath
        self.trackLayer.path = trackBezPath.cgPath
    }
    
    func stopLoader() {
        self.progressLayer.removeAllAnimations()
    }
}
