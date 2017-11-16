//
//  LanguageManager.swift
//  Alzahrani
//
//  Created by Hardwin on 09/06/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation
import UIKit

class LanguageManager: NSObject {
    
    let APPLE_LANGUAGE_KEY = "AppleLanguages"
    
    class func currentAppleLanguage() -> String{
        let userdef = UserDefaults.standard
        let langArray = userdef.object(forKey: "AppleLanguages") as! NSArray
        let current = langArray.firstObject as! String
        return current
    }
    
    class func setAppleLAnguageTo(lang: String) {
        let userdef = UserDefaults.standard
        userdef.set([lang,currentAppleLanguage()], forKey: "AppleLanguages")
        userdef.synchronize()
    }
}
