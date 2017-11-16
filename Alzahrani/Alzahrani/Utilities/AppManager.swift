//
//  AppManager.swift
//  Alzahrani
//
//  Created by Hardwin on 04/05/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit
import MagicalRecord

typealias DownloadCompletion = ((_ success: Bool) -> Void)

class AppManager: NSObject {
    
    //MARK:- Helper Methods:
    
    class var isUserLoggedIn: Bool {
        return UserDefaultManager.sharedManager().isUserAuthenticated()
    }
	
	class var isProductsDownloaded: Bool {
		return UserDefaultManager.sharedManager().isProductsDownloaded()
	}
    
    class func languageType() -> LanguageType? {
        var currentLanguageType: LanguageType?
        if let languageType = UserDefaultManager.sharedManager().selectedLanguageId {
            if let type = LanguageType(rawValue: languageType) {
                switch type {
                case .english:
                    currentLanguageType = .english
                case .arabic:
                    currentLanguageType = .arabic
                }
            }
        }
        return currentLanguageType
    }
    
    class func currentApplicationMode() -> AppMode {
        var currentMode: AppMode? = .online
        if let currentWorkingMode = UserDefaultManager.sharedManager().currentAppMode {
            if let type = AppMode(rawValue: currentWorkingMode) {
                switch type {
                case .offline:
                    currentMode = .offline
                case .online:
                    currentMode = .online
                }
            }
        }
        return currentMode!
    }
	
    class func getLoggedInUserType() -> UserLoginType {
        
        let userDefaults = UserDefaultManager.sharedManager()
        if let customerGroupId = userDefaults.customerGroupId {
            if customerGroupId == "1" {
                return .endUser
            } else if customerGroupId == "17" {
                return .employee
            } else {
                return .salesExecutive
            }
        } else {
            return .endUser
        }
    }
    
    class var isLanguageSelected: Bool {
        return UserDefaultManager.sharedManager().selectedLanguageId != nil
    }
    
    class func initialSetup() {
        //getDeviceID()
        setDefaultAppearance()
        printAppDirectoryPath()
        NetworkManager.configureManagers(token: nil)
        NetworkManager.configureURLCache()
    
        //Set up DB
        DBManager.sharedManager().setupDB()
		
//		//FIXME:- New Change on 27/10/2017
//		if self.currentApplicationMode() == .offline {
//			if !self.isProductsDownloaded {
//				UserDefaultManager.sharedManager().currentAppMode = "Online"
//			} else {
//				UserDefaultManager.sharedManager().currentAppMode = "Offline"
//			}
//		}
		//FIXME:- New Change on 27/10/2017
    }
    
    class func appName() -> String {
        return Bundle.main.infoDictionary!["CFBundleName"] as! String
    }
    
    class func dbStore() -> String {
        return "DB/\(self.bundleID()).sqlite"
    }
    
    class func bundleID() -> String {
        return Bundle.main.bundleIdentifier!
    }
    
    class func isSimulator() -> Bool {
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            return true
        #else
            return false
        #endif
    }
    
    class func appBarTintColor() -> UIColor {
        return UIColor(rgba: "#272E83")
    }
    
    class func appTintColor() -> UIColor {
        return UIColor.black
    }
    
    class func setDefaultAppearance() {
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.barTintColor = appBarTintColor()
        navigationBarAppearance.tintColor = appTintColor()
        navigationBarAppearance.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    class func printAppDirectoryPath() {
        let path = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)[0]
        print("App path: \(path)")
    }
    
    class func getCustId() -> String {
        if let userId = UserDefaultManager.sharedManager().loginUserId {
            return userId
        } else {
            return ""
        }
    }
    
    class func getCustGroupId() -> String {
        
        if let custGrpId = UserDefaultManager.sharedManager().customerGroupId {
            return custGrpId
        } else {
            return "1"
        }
    }
    
    class func logoutUser() {
        UserDefaultManager.sharedManager().loginUserId = nil
        UserDefaultManager.sharedManager().customerGroupId = "1"
        WishLists.removeAllWishListData()
        MyCart.removeAllMyCartListData()
	     UserDefaultManager.sharedManager().currentAppMode = "Online"
		  UserDefaultManager.sharedManager().isProductDwonloaded = false
    }
}

extension AppManager {
    
    class func setAppLaunchingOptions() {
        if (isUserLoggedIn == true) {
            setDefaultRootViewController(state: .Home)
        } else {
            if (isLanguageSelected == true) {
//                setDefaultRootViewController(state: .Login)
                setDefaultRootViewController(state: .Home)
            } else {
                setDefaultRootViewController(state: .LangaugeSelection)
            }
        }
    }
    
    class func setDefaultRootViewController(state: RootControllersState) {
        let storyBoard = UIStoryboard(name: Constants.storyBoardMain, bundle: nil)
        var newRootVc: UIViewController?
        
        switch state {
        case .LangaugeSelection:
            newRootVc = storyBoard.instantiateViewController(withIdentifier: "LanguageSelectionNavigationController") as? LanguageSelectionNavigationController
            setAppRootViewController(newRootVc: newRootVc!)
            
        case .Login:
            newRootVc = storyBoard.instantiateViewController(withIdentifier: "UserRegisterNavigationController") as? UserRegisterNavigationController
            setAppRootViewController(newRootVc: newRootVc!)
        
        case .Signup:
            newRootVc = storyBoard.instantiateViewController(withIdentifier: "RegistrationViewController") as? RegistrationViewController
            setAppRootViewController(newRootVc: newRootVc!)
            
        case .Home:
			   SyncManager.startObservingReachability()
            newRootVc = storyBoard.instantiateViewController(withIdentifier: "AlhzaraniPannelViewController") as! AlhzaraniPannelViewController
            setAppRootViewController(newRootVc: newRootVc!)
        }
    }
    
    class func setAppRootViewController(newRootVc: UIViewController) {
        let window = AppDelegate.delegate().window
        window?.rootViewController = newRootVc
    }
}

extension AppManager {
    
    class func setupDB() {
        let dataBaseUrl = URL(fileURLWithPath: self.dbStore())
        MagicalRecord.setupCoreDataStackWithAutoMigratingSqliteStore(at: dataBaseUrl)
        
        if isSimulator() {
            let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            print("App Path: \(dirPaths)")
        }
    }
    
    class func getDeviceID() -> String? {
        let deviceId = UIDevice.current.identifierForVendor?.uuidString
        print("Device UUID: \(deviceId)")
        return UIDevice.current.identifierForVendor?.uuidString
    }
}
