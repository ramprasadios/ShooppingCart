    //
    //  AppDelegate.swift
    //  Alzahrani
    //
    //  Created by Hardwin on 28/04/17.
    //  Copyright © 2017 Ramprasad A. All rights reserved.
    //
    
    import UIKit
    import CoreData
    import UserNotifications
    import OneSignal
    import Branch
    
    @UIApplicationMain
    class AppDelegate: UIResponder, UIApplicationDelegate {
        
        var window: UIWindow?
        var isInitialDownload: Bool? = false
        var isOnlinePaymentInitiated: Bool = false
        
        func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
            LanguageLocalizer.DoTheSwizzling()
            AppManager.initialSetup()
            
            let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
            
            // Replace '11111111-2222-3333-4444-0123456789ab' with your OneSignal App ID.
            OneSignal.initWithLaunchOptions(launchOptions,
                                            appId: Constants.oneSignalAppId,
                                            handleNotificationAction: nil,
                                            settings: onesignalInitSettings)
            
            
            OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
            
            // Recommend moving the below line to prompt for push after informing the user about
            //   how your app will use them.
            OneSignal.promptForPushNotifications(userResponse: { accepted in
                print("User accepted notifications: \(accepted)")
            })
            
            OneSignal.initWithLaunchOptions(launchOptions, appId: Constants.oneSignalAppId, handleNotificationReceived: nil, handleNotificationAction: { (result) in
                
                let payLoad: OSNotificationPayload = (result?.notification.payload)!
                var fullMessage = payLoad.body
                
                if let additionalData = payLoad.additionalData, let actionSelected = additionalData["actionSelected"] as? String {
                    fullMessage =  fullMessage! + "\nPressed ButtonId:\(actionSelected)"
                }
                print("fullMessage = \(fullMessage)")
                print("Reveived additional data \(result)")
                
                let additionalJSONData = result?.notification.payload.additionalData
                if let JSONDict = additionalJSONData as? [String: AnyObject] {
                    print("JSON \(JSONDict)")
                    APNSManager.handlePushNotification(withPayload: JSONDict)
                }
                
            }, settings: onesignalInitSettings)
            
            /* OneSignal.initWithLaunchOptions(launchOptions, appId: Constants.oneSignalAppId, handleNotificationReceived: { (result) in
             
             let payLoad: OSNotificationPayload = (result?.payload)!
             var fullMessage = payLoad.body
             
             if let additionalData = payLoad.additionalData, let actionSelected = additionalData["actionSelected"] as? String {
             fullMessage =  fullMessage! + "\nPressed ButtonId:\(actionSelected)"
             }
             print("fullMessage = \(fullMessage)")
             print("Reveived additional data \(result)")
             
             let additionalJSONData = result?.payload.additionalData
             if let JSONDict = additionalJSONData as? [String: AnyObject] {
             print("JSON \(JSONDict)")
             }
             
             }, handleNotificationAction: nil, settings: onesignalInitSettings) */
            
            //self.registerForPushNotification()
            AppManager.setAppLaunchingOptions()
			
			 return true
        }
		
        func applicationWillResignActive(_ application: UIApplication) {
            // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
            // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        }
        
        func applicationDidEnterBackground(_ application: UIApplication) {
            // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
            // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        }
        
        func applicationWillEnterForeground(_ application: UIApplication) {
            // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        }
        
        func applicationDidBecomeActive(_ application: UIApplication) {
            // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        }
        
        func applicationWillTerminate(_ application: UIApplication) {
            // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
            // Saves changes in the application's managed object context before the application terminates.
        }
        
        func application(_ application: UIApplication,
                         didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
            let tokenParts = deviceToken.map { data -> String in
                return String(format: "%02.2hhx", data)
            }
            
            let token = tokenParts.joined()
            print("Device Token: \(token)")
        }
        
        func application(_ application: UIApplication,
                         didFailToRegisterForRemoteNotificationsWithError error: Error) {
            print("Failed to register: \(error)")
        }
		
		func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
			// pass the url to the handle deep link call
			Branch.getInstance().application(app,
			                                 open: url,
			                                 options:options
			)
			
			// do other deep link routing for the Facebook SDK, Pinterest SDK, etc
			return true
		}
	  }
    
    //MARK:- Helper Methods:
    extension AppDelegate {
        
        class func delegate() -> AppDelegate {
            return UIApplication.shared.delegate as! AppDelegate
        }
        
        class func rootController() -> UIViewController? {
            return topMostController(viewController: AppDelegate.delegate().window?.rootViewController)
        }
        
        class func currentController() -> UIViewController? {
            return AppDelegate.delegate().window?.currentViewController()
        }
        
        class func canAppOpenURL(urlString : String) -> Bool {
            return UIApplication.shared.canOpenURL(NSURL(string: urlString)! as URL)
        }
    }
    
    
    //MARK:- Push Notification:
    extension AppDelegate {
        
        func registerForPushNotification() {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (success, error) in
                print("Permission granted for Push Notification \(success)")
                
                guard success else { return }
                self.getNotificationSettings()
            }
        }
        
        func getNotificationSettings() {
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                print("Notification settings: \(settings)")
                
                guard settings.authorizationStatus == .authorized else { return }
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
	
	//Deep - Linking:
	extension AppDelegate {
		
		func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
			//return Branch.getInstance().continue(userActivity)
			var productDict = [String: AnyObject]()
			guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
					let url = userActivity.webpageURL,
					let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
					return false
			}
			
			if url.host == "alzahrani-online.com" {
				if let newlinkId = url.absoluteString.components(separatedBy: "=").last {
					if let produId = Int16(newlinkId) {
						productDict["product_id"] = produId as AnyObject?
						DeepLinkManager.handleDeepLinkURL(withPayload: productDict)
						return true
					} else {
						return false
					}
					
				} else {
					return false
				}
			} else {
				return false
			}
			
			// 2
//			if let computer = ItemHandler.sharedInstance.items.filter({ $0.path == components.path}).first {
//				self.presentDetailViewController(computer)
//				return true
//			}
			
			// 3
//			let webpageUrl = URL(string: "https://alzahrani-online.com")!
			//application.openURL(webpageUrl)
			
			return false
		}
		
		func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
			var productDict = [String: AnyObject]()
			if url.host == "products" {
				let productId = url.lastPathComponent
				if url.path == "/productDetails" + "\(productId)" {
					productDict["product_id"] = productId as AnyObject?
					DeepLinkManager.handleDeepLinkURL(withPayload: productDict)
					return true
				} else {
					return false
				}
			} else {
				return false
			}
		}
	}
	
	extension AppDelegate {
		
		func presentDetailViewController() {
			
			let storyboard = UIStoryboard(name: "Main", bundle: nil)
			
			let detailVC = storyboard.instantiateViewController(withIdentifier: "ProductDetailViewController")
				as! ProductDetailViewController
			
			let navigationVC = storyboard.instantiateViewController(withIdentifier: "UserRegisterNavigationController")
				as! UINavigationController
			navigationVC.modalPresentationStyle = .formSheet
			
			navigationVC.pushViewController(detailVC, animated: true)
		}
	}
	
