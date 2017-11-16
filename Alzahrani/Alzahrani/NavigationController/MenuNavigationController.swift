//
//  MenuNavigationController.swift
//  Alzahrani
//
//  Created by Hardwin on 10/05/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

enum MenuMaster : Int {
    case Home = 0, MyWishlist, OrderHistory, Cart, Profile
    
    func toString() -> String {
        switch  self {
        case .Home:
            return "Home"
        case .MyWishlist:
            return "MyWishlist"
        case .OrderHistory:
            return "OrderHistory"
        case .Cart:
            return "Cart"
        case .Profile:
            return "Profile"
        }
    }
}

protocol ProgramMenuDelegate : NSObjectProtocol {
    func handleSlideOperation(menuState master : MenuMaster , slideState state : SlideMasterState)
}

class MenuNavigationController: UINavigationController {

//    weak var sliderDelegate: ProgramMenuDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
