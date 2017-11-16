//
//  DefaultsManager.swift
//  Alzahrani
//
//  Created by Hardwin on 10/05/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

struct UserDefaultsKey {
    static let auThenticatedKey = "auThenticated"
    static let savedPayload     = "savedPayload"
    static let deviceToken      = "deviceToken"
    static let loginUserId      = "loginUserId"
    static let loginUserName    = "loginUserName"
    static let organizationId   = "organizationId"
    static let defaultIndexPath = "defaultIndexPath"
    static let selectedSection  = "selectedSection"
    static let customerGroupId  = "customerGroupId"
    static let selectedLanguage = "selectedLanguage"
    static let applicaitonMode  = "applicationMode"
    static let userEmailId      = "userEmailId"
    static let userMobileNumber = "userMobileNumber"
    static let userFirstName    = "userFirstName"
    static let userLastName     = "userLastName"
	static let isProductsDownloaded = "isProductsDownloaded"
}

class UserDefaultManager {
    
    init() {
        if isAuthenticated == nil {
            isAuthenticated = false
        }
    }
    
    open var isAuthenticated: Bool? {
        get {
            return UserDefaults.standard.object(forKey: UserDefaultsKey.auThenticatedKey) as? Bool
        } set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.auThenticatedKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    open var loginUserId : String? {
        get {
            return  UserDefaults.standard.object(forKey: UserDefaultsKey.loginUserId) as? String
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.loginUserId)
            UserDefaults.standard.synchronize()
        }
    }
    
    open var loginUserName : String? {
        get {
            return  UserDefaults.standard.object(forKey: UserDefaultsKey.loginUserName) as? String
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.loginUserName)
            UserDefaults.standard.synchronize()
        }
    }
    
    open var customerGroupId : String? {
        get {
            return  UserDefaults.standard.object(forKey: UserDefaultsKey.customerGroupId) as? String
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.customerGroupId)
            UserDefaults.standard.synchronize()
        }
    }
    
    open var customerEmail: String? {
        get {
            return UserDefaults.standard.object(forKey: UserDefaultsKey.userEmailId) as? String
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.userEmailId)
            UserDefaults.standard.synchronize()
        }
    }
    
    open var customerMobile: String? {
        get {
            return UserDefaults.standard.object(forKey: UserDefaultsKey.userMobileNumber) as? String
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.userMobileNumber)
            UserDefaults.standard.synchronize()
        }
    }
    
    open var userFirstName: String? {
        get {
            return UserDefaults.standard.object(forKey: UserDefaultsKey.userFirstName) as? String
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.userFirstName)
            UserDefaults.standard.synchronize()
        }
    }
    
    open var userLastName: String? {
        get {
            return UserDefaults.standard.object(forKey: UserDefaultsKey.userLastName) as? String
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.userLastName)
            UserDefaults.standard.synchronize()
        }
    }
    
    open var selectedLanguageId : String? {
        get {
            return  UserDefaults.standard.object(forKey: UserDefaultsKey.selectedLanguage) as? String
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.selectedLanguage)
            UserDefaults.standard.synchronize()
        }
    }
    
    open var currentAppMode: String? {
        get {
            return UserDefaults.standard.object(forKey: UserDefaultsKey.applicaitonMode) as? String
        } set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.applicaitonMode)
            UserDefaults.standard.synchronize()
        }
    }
	
	open var isProductDwonloaded: Bool? {
		get {
			return UserDefaults.standard.object(forKey: UserDefaultsKey.isProductsDownloaded) as? Bool
		} set {
			UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.isProductsDownloaded)
			UserDefaults.standard.synchronize()
		}
	}
	
	
    private struct Constants {
        static let sharedManager = UserDefaultManager()
    }
    
    class func sharedManager() -> UserDefaultManager {
        return Constants.sharedManager
    }

    func isUserAuthenticated() -> Bool {
        return isAuthenticated!
    }
	
	func isProductsDownloaded() -> Bool {
		return isProductDwonloaded!
	}
}

extension UserDefaultManager {
    
    func resetLogOutSettings() {
        self.isAuthenticated = false
        
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.loginUserId)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.loginUserName)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.customerGroupId)
        UserDefaults.standard.synchronize()
    }
}
