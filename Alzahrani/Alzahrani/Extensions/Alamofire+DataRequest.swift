//
//  Alamofire+DataRequest.swift
//  Alhzarani
//
//  Created by Ramprasad A on 10/05/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation
import Alamofire

typealias ResponseCompletionHandler = ((ResponseData) -> Void)

extension DataRequest {
    
    func generateResponseSerialization(completion : ResponseCompletionHandler?) {
        responseJSON(/*options: .mutableContainers*/) { (DataResponse) in
            let resp = formatURLResponse(DataResponse.request, response: DataResponse.response, JSON: DataResponse.result.value, error: DataResponse.result.error)
            completion?(resp)
        }
    }
}

func formatURLResponse(_ request: URLRequest?, response: HTTPURLResponse?, JSON: Any?, error: Error?) -> ResponseData {
    
    let _response = ResponseData(URLRequest: request, response: response)
    
    if let status = response?.statusCode {
        
        _response.statusCode = status
        
        switch status {
        case 200...300 :
            _response.JSON = JSON
            if let jsonResponse = JSON as? [String: AnyObject] {
                _response.JSON = jsonResponse[Constants.keyRecords]
            }
            
            if let jsonResponse = JSON as? [String: AnyObject] {
                let errorCode = jsonResponse["errorCode"] as? String
                if errorCode?.isEmpty == false {
                    _response.error = getError(JSON)
                    _response.error?.statusCode = status
                }
            }
            return _response
            
        case 400, 404, 500, 401, 403:
            _response.error = getError(JSON)
            _response.error?.statusCode = status
            return _response
        default:
            break
        }
    }
    
    if let _nsError = error {
        _response.error = ResponseError(
            error: _nsError.localizedDescription,
            localizedDescription: _nsError.localizedDescription
        )
    } else if _response.error == nil {
        _response.error = ResponseError(
            error: Constants.ParseError,
            localizedDescription: "Unknown \(response?.statusCode)"
        )
    }
    
    _response.error?.statusCode = response?.statusCode ?? 0
    
    return _response
}

func getError(_ json: Any?) -> ResponseError? {
    
    var error = "", errorDescription = ""
    
    if let json = json as? [String: Any] {
        if let rawError = json["error"] as? String {
            error = rawError
        } else if let rawErrorCode = json["errorCode"] as? String {
            error = rawErrorCode
        }
        
        if let rawErrorDescription = json["errorDescription"] as? String {
            errorDescription = rawErrorDescription
        } else if let rawErrorMessage = json["errorMessage"] as? String {
            errorDescription = rawErrorMessage
        }
    }
    
    let e = ResponseError(error: error, localizedDescription: errorDescription)
    e.JSON = json
    
    return e
}

