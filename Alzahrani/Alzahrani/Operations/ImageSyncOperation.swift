//
//  ImageSyncOperation.swift
//  Alzahrani
//
//  Created by Hardwin on 19/05/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage

class ImageSyncOperation: BaseSyncOperation {
    
}

extension ImageSyncOperation {
    
    override func startProcessing() {
        switch (self.operationType) {
        case .imageDownloadOperation:
            self.downloadImage()
        case .getHomeBannersList:
            self.downloadBannerImages()
        case .getSliderImages:
            self.downloadSliderImage()
        case .downloadCartImage:
            self.downloadCartImage()
        default:
            break
        }
    }
}

//MARK:- Image Downloading.
extension ImageSyncOperation {
    
    func downloadImage() {
        print("userInfo: \(userInfo)")
        let url = URLBuilder.getImageDownloadBaseURL() + userInfo!
        print("URL: \(url)")
        NetworkManager.defaultManger.request(url,
                                             method: .get,
                                             parameters: [:],
                                             encoding: URLEncoding.methodDependent)
            .validate().responseData { (imageResponseData) in
                
               if imageResponseData.error == nil {
                    self.completionHandler?(imageResponseData.data, nil)
                } else {
                    print("Error: \(imageResponseData.error)")
                }
        }
    }
    
    func downloadCartImage() {
        if let userInfo = userInfo {
            NetworkManager.defaultManger.request(userInfo,
                                                 method: .get,
                                                 parameters: [:],
                                                 encoding: URLEncoding.methodDependent)
                .validate().responseData { (imageResponseData) in
                    if imageResponseData.error == nil {
                        self.completionHandler?(imageResponseData.data, nil)
                    } else {
                        print("Error: \(imageResponseData.error)")
                    }
            }
            
        }
    }
    
    func downloadBannerImages() {
        NetworkManager.defaultManger.request(URLBuilder.getBannerImagesURL(),
                                             method: .get,
                                             parameters: [:],
                                             encoding: URLEncoding.methodDependent)
            .validate().generateResponseSerialization { (Response) in
                if Response.error == nil {
                    print("Banner Response: \(Response.JSON)")
                    self.completionHandler?(Response.JSON, Response.error)
                } else {
                    print("Error: \(Response.error)")
                    self.completionHandler?(nil, Response.error)
                }
        }
    }
    
    func downloadSliderImage() {
        NetworkManager.defaultManger.request(URLBuilder.getSliderImages(),
                                             method: .get,
                                             parameters: [:],
                                             encoding: URLEncoding.methodDependent)
            .validate().generateResponseSerialization { (Response) in
                if Response.error == nil {
                    self.completionHandler?(Response.JSON, Response.error)
                } else {
                    print("Error: \(Response.error)")
                    self.completionHandler?(nil, Response.error)
                }
        }
    }
}
