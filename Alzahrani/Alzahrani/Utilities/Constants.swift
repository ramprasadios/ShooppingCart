//
//  Constants.swift
//  Alzahrani
//
//  Created by Hardwin on 05/05/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

enum RootControllersState: Int {
    case Home
    case Login
    case Signup
    case LangaugeSelection
}

class Constants: NSObject {

   //Constants
    static let oneSignalAppId = "0fbc39b6-73df-48c0-a2ca-c6aec42baabd"
    static let alzahraniErrorDomain = "com.alzahrani.error"
    static let ParseError = "com.alzahrani.parseError"
    static let objectNotFoundCode = -1
    static let resizeWithToolbar = 100
    static let resizeWithoutToolbar = 0
    static let placeHolderImage     = "placeHolderImage"
    static let alertTitle = NSLocalizedString("Alzahrani", comment: "")
    static let alertAction = NSLocalizedString("OK", comment: "")
    static let noInternet = NSLocalizedString("No internet connection", comment: "")
    static let slowInternet = NSLocalizedString("Internet too slow", comment: "")
    static let cancelAction = NSLocalizedString("Cancel", comment: "")
    
    //NetworkKeys
    static let keyRecords = "records"
    
    //JSON Keys
    static let keyAuthTokenHeader = "Auth-Token"

    //Cell Identifiers:
    static let showSubCategories = "ShowSubCategories"
    
    //StoryBoard Segues:
    static let storyBoardMain       =       "Main"
    
    //NotificationNames:
    static let hambergerTappedNotification  = "hambergerTappedNotification"
    static let sliderMenuFieldTapNotification = "sliderMenuFieldTapNotification"
    static let timerFiredNotification = "timerFiredNotification"
    static let userLoggedOutNotification = "userLoggedOutNotification"
    static let loginSuccessNotification  = "loginSuccessNotification"
    static let signupSuccessNotification = "signupSuccessNotification"
    static let filteredBrandsDictNotification = "filteredBrandsDictNotification"
    
    //Dictionary keys:
    static let keyLogin = "keyLogin"
    static let selectedBrands = "SelectedBrandsList"
}
