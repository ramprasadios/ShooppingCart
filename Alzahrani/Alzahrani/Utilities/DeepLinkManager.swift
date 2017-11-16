//
//  DeepLinkManager.swift
//  Alzahrani
//
//  Created by Ashok Kumar on 29/08/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation

class DeepLinkManager: NSObject {
	
	class func handleDeepLinkURL(withPayload payload: [String: AnyObject]) {
		
		NotificationCenter.default.post(name: Notification.Name("ShowProductDetailsNotification"), object: payload)
	}
}
