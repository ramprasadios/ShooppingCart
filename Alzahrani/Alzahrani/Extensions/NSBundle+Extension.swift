//
//  NSBundle+Extension.swift
//  nHance
//
//  Created by Ramprasad A on 10/05/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation

extension Bundle {
    
    var releaseVersionNumber: String? {
        return self.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    var buildVersionNumber: String {
        return self.infoDictionary?["CFBundleVersion"] as! String
    }
    
    var appName: String {
        return self.infoDictionary?["CFBundleName"] as! String
    }
    
    func formattedVersion() -> String {
        var version = NSLocalizedString("Version: ", comment: "")
        version += releaseVersionNumber!
        version += "(\(buildVersionNumber))"
        
        return version
    }
    
    class func bundleID() -> String {
        return Bundle.main.bundleIdentifier!
    }
}

