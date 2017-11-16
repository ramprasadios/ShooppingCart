//
//  NetworkManager.swift
//  Alzahrani
//
//  Created by Hardwin on 05/05/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class NetworkManager: NSObject {
    
    //Static Members to do Network Operation
    static var defaultManger: SessionManager!
    static var token: String?
    static var securedManger: SessionManager!
    static var imageCache: ImageRequestCache!
    static var imageDownloadManager: ImageDownloader!
    
    private static let reachability = Reachability.reachabilityForInternetConnection()
    class var sharedReachability: Reachability {
        return reachability
    }
    
    class var connectionError: ResponseError {
        
        let error = ResponseError(error: Constants.alzahraniErrorDomain, localizedDescription: NSLocalizedString("ERROR_NO_INTERNET_CONNECTION",comment: ""), errorType: .noConnection)
        return error
        
    }
    
    class var authToken: String? {
        get {
            return token
        } set {
            if let newValue = newValue {
                var defaultHeaders = Alamofire.SessionManager.defaultHTTPHeaders
                defaultHeaders[Constants.keyAuthTokenHeader] = newValue
                let configuration = URLSessionConfiguration.default
                configuration.httpAdditionalHeaders = defaultHeaders
                configuration.timeoutIntervalForRequest = 10800
                configuration.requestCachePolicy = .reloadIgnoringCacheData
                
                self.securedManger = Alamofire.SessionManager(configuration: configuration)
            }
        }
    }
    
    class func configureManagers(token: String?) {
        
        var defaultHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        defaultHeaders["Accept"] = "application/json"
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = defaultHeaders
        self.defaultManger = Alamofire.SessionManager(configuration: configuration)
		
        
        self.authToken = token
    }
    
    class func configureURLCache() {
        imageCache = AutoPurgingImageCache(
            memoryCapacity: 100 * 1024 * 1024,
            preferredMemoryUsageAfterPurge: 60 * 1024 * 1024)
    }
}
