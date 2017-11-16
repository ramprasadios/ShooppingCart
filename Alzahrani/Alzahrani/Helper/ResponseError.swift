//
//  ResponseError.swift
//  Alzahrani
//
//  Created by Hardwin on 10/05/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation

public enum ErrorType: String {
    case noConnection = "NoConnection Error"
    case objectNotFound = "ObjectNotFound Error"
    case noCategoryListExist = "noCategoryListExist"
    case serverError = "Server Error"
    case uplaodError = "Upload Error"
}

enum ErrorCode : String {
    case missingParameter = "MISSING_PARAMETERS"
    case invalidDataFormat = "INVALID_DATE_FORMAT"
    case userAlreadyExist = "USER_ALREADY_EXISTS"
    case organizationNotFound = "ORGANIZATION_NOT_FOUND"
    case organizationNotSupported = "ORG_SIGNUP_NOT_SUPPORTED" /*Org SignUp Not supported*/
    case requestTimedOut = "The request timed out."
    case none = "None"
}

class ResponseError: Error {
    
    open var errorCode: String = ""
    
    open var localizedDescription: String = ""
    
    open var errorType: ErrorType = .noConnection
    
    open var request: URLRequest?
    
    open var JSON: Any?
    
    open var statusCode: Int = 0
    
    public init(error: String, localizedDescription: String = "", errorType: ErrorType = .serverError) {
        self.errorCode = error
        self.localizedDescription = localizedDescription.isEmpty ? NSLocalizedString(errorCode, comment: "") : localizedDescription
        self.errorType = errorType
    }
    
    open var description: String {
        return String(format: "%@: %@ Description: %@ status \(statusCode)", errorType.rawValue, errorCode, localizedDescription)
    }
}
