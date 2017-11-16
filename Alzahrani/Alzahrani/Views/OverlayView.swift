//
//  OverlayView.swift
//  nHance
//
//  Created by Pradeep BM on 01/09/16.
//  Copyright (c) 2017 Softtrends. All rights reserved.
//

import Foundation
import UIKit

/**
 Show a overlay background with alpha
 */
class OverlayView : UIView {

    //MARK:- Properties
    /**
     Gesture completion handler
     */
    var callBack : GestureCompletion?

    //MARK:- Life cycle
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    convenience init(frame: CGRect, tapHandler : GestureCompletion?) {
        self.init(frame: frame)
        self.callBack = tapHandler

        self.addTapGesture()
    }
}

//MARK:- Gesture handler
extension OverlayView {

    fileprivate func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(OverlayView.overlayViewTapped))
        tapGesture.numberOfTapsRequired = 1
        self.addGestureRecognizer(tapGesture)
    }

    func overlayViewTapped() {
        callBack?(true)
    }
}
