//
//  WebserviceEngine.swift
//  Dr.Owl
//
//  Created by Hardwin on 04/12/16.
//  Copyright (c) 2016 hardwin. All rights reserved.
//

import UIKit

class WebserviceEngine: NSObject {
    var session:URLSession!
   
    func requestforAPI(service:String,method:String,token:String,body:String,productBody:NSData,completion:@escaping (_ result:NSDictionary?,_ error:AnyObject?) -> ())
    
    {
        
        let urlpath:String = "https://alzahrani-online.com/index.php?route=api/" + service
        
//              if productBody != NSData(){
//            let resultEncoded  = productBody.base64EncodedString(options: [])
//            urlpath = urlpath + "1/" + resultEncoded
        
                
//
//            //            request.setValue("application/json;charset=", forHTTPHeaderField: "Content-Type")
//        }
        
        
        
        
        let url:NSURL = NSURL(string:urlpath)!
        print("URL:\(url)")
        
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = method
        if token != ""
        {
        request.setValue("\(token)", forHTTPHeaderField: "Authorization")
        }
       
//        if body != ""
//        {
//            let bodydata = body.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
//            request.httpBody = bodydata
//            
//        }

        
        
        
        
        if productBody == NSData()
            
            
        {
            if body != ""
            {
            let bodydata = body.data(using: String.Encoding.utf8)
            request.httpBody = bodydata
            }
        }
        else
        {
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.httpBody = productBody as Data
        }

        
     
 
    
   /* let config = URLSessionConfiguration.default // Session Configuration
    let session = URLSession(configuration: config) // Load configuration into Session
    //let url = URL(string: "YOUR URL STRING")!
    
    let task = session.dataTask(with: url, completionHandler: {
        (data, response, error) in
        
        if error != nil {
            
            print(error!.localizedDescription)
            
        } else {
            
            do {
                
                if let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]
                {
                    
                    //Implement your logic
                    print(json)
                    
                }
                
            } catch {
                
                print("error in JSONSerialization")
                
            }
            
            
        }
        
        })
    task.resume()*/

        
        

 let config = URLSessionConfiguration.ephemeral
 self.session = URLSession(configuration: config)
  
 let task = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
 if let receivedData = data
 {

 do
 {
 let resultDic = try JSONSerialization.jsonObject(with: receivedData, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
//print("RESULt:\(resultDic)")
    completion(resultDic!,nil)
 }
 catch let error
 {
 NSLog("\(error)")
 }
 }
 else if let errorMessage = error
 {
 completion(nil,errorMessage as AnyObject?)
 }
 
 self.session.invalidateAndCancel()
 }

task.resume()
    
        
    }
    func requestforProductAPI(service:String,method:String,token:String,body:String,productBody:NSData,completion:@escaping (_ result:NSDictionary?,_ error:AnyObject?) -> ())
        
    {
        
        let urlpath:String = "http://alzahrani-online.com/index.php?route=product/" + service
        
        
        let url:NSURL = NSURL(string:urlpath)!
        print("URL:\(url)")
        
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = method
        if token != ""
        {
            request.setValue("\(token)", forHTTPHeaderField: "Authorization")
        }
        
        if productBody == NSData()
            
            
        {
            if body != ""
            {
                let bodydata = body.data(using: String.Encoding.utf8)
                request.httpBody = bodydata
            }
        }
        else
        {
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.httpBody = productBody as Data
        }
        
        
             let config = URLSessionConfiguration.ephemeral
        self.session = URLSession(configuration: config)
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            if let receivedData = data
            {
                
                do
                {
                    let resultDic = try JSONSerialization.jsonObject(with: receivedData, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                    //print("RESULt:\(resultDic)")
                    if let resultDataDict = resultDic {
                        completion(resultDataDict,nil)
                    }
                }
                catch let error
                {
                    NSLog("\(error)")
                }
            }
            else if let errorMessage = error
            {
                completion(nil,errorMessage as AnyObject?)
            }
            
            self.session.invalidateAndCancel()
        }
        
        task.resume()
        
        
    }

    func imageUpload(service:String,token:String,imagedata:Data,completion:@escaping (_ result:NSDictionary?,_ error:AnyObject?) -> ()){
        let boundaryConstant  = "----------V2y2HFg03eptjbaKO0j1"
        let params = NSMutableDictionary()
        params.setObject("truckdocuments", forKey:"bucket_type" as NSCopying)
        let urlpath:String = "http://trk.dev.viaetruck.com:8080/api/v0/" + service
        
        let url:NSURL = NSURL(string:urlpath)!
        print("URL:\(url)")
        
        var request = URLRequest(url: url as URL)
        request.httpMethod = "POST"
        
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData
        
        let contentType = "multipart/form-data; boundary=\(boundaryConstant)"
        
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        if token != ""
        {
            request.setValue("\(token)", forHTTPHeaderField: "Authorization")
        }
        let body = NSMutableData()
        for param in params {
            
            body.append("--\(boundaryConstant)\r\n" .data(using: String.Encoding.utf8,allowLossyConversion: false)! )
            body.append("Content-Disposition: form-data; name=\"\(param.key)\"\r\n\r\n" .data(using: String.Encoding.utf8,allowLossyConversion: false)!)
            body.append("\(param.value)\r\n" .data(using: String.Encoding.utf8,allowLossyConversion: false)!)
            
        }
        body.append("--\(boundaryConstant)\r\n".data(using: String.Encoding.utf8,allowLossyConversion: false)!)
        
        
        body.append("Content-Disposition: form-data;   name=\"\("file")\" ;  filename=\"image.jpg\"\r\n".data(using: String.Encoding.utf8,allowLossyConversion: false)!)
        
        
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: String.Encoding.utf8,allowLossyConversion: false)!)
        body.append(imagedata)
        
        body.append("\r\n".data(using: String.Encoding.utf8,allowLossyConversion: false)!)
        body.append("--\(boundaryConstant)--\r\n".data(using: String.Encoding.utf8,allowLossyConversion: false)!)
        request.httpBody  = body as Data
        let postLength = "\(body.length)"
        request.setValue(postLength, forHTTPHeaderField: "Content-Length")
        
        
        let config = URLSessionConfiguration.default
        self.session = URLSession(configuration: config)
        let task = session.dataTask(with: request) { (data, response, error) -> Void in
            
            if let receivedData = data{
                do
                {
                    let resultDic = try JSONSerialization.jsonObject(with: receivedData, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                    
                    completion(resultDic!,nil)
                }
                catch let error
                {
                    NSLog("\(error)")
                }
            }
            else if let errorMessage = error
            {
                completion(nil,errorMessage as AnyObject?)
            }
            
            self.session.invalidateAndCancel()
        }
        task.resume()
    }
    
    
}
