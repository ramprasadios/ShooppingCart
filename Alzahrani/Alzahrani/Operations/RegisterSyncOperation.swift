//
//  RegisterSyncOperation.swift
//  Alzahrani
//
//  Created by Hardwin on 05/05/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit
import Alamofire

class RegisterSyncOperation: BaseSyncOperation {
    
}

extension RegisterSyncOperation {
    
    override func startProcessing() {
        switch (self.operationType) {
        case .Register:
            self.registerNewUser()
        case .Login:
            self.loginUser()
        case .forgotPassword:
            self.sendNewPasswordRequest()
        case .getCitiesList:
            self.downloadCitiesList()
        case .getCountiesList:
            self.downloadCountriesList()
        case .addNewAddress:
            self.addNewAddress()
        case .getUserExistingAddress:
            self.downloadUserExistingAddress()
        case .getCitiesBasedOnZoneId:
            self.getCitiesBasedOnZoneId()
        case .getBankDetails:
            self.downloadBankTransferDetails()
		case .getMyProfileData:
			 self.downloadUserProfileData()
		case .generateSDKToken:
			self.getSDKToken()
        default:
            break
        }
    }
}

extension RegisterSyncOperation {
    
    
    
    func registerNewUser() {
        
        if let userInfo = userInfo {
            NetworkManager.defaultManger.request(URLBuilder.getUserRegisterURL(), method: .post, parameters: [:], encoding: userInfo).validate().responseJSON(completionHandler: { (response) in
                
                print("Signup \(response)")
                
                if let generatedError = response.error as? ResponseError {
                    self.completionHandler?(response.result, generatedError)
                } else {
                    self.completionHandler?(response.result, nil)
                }
            })
        }
    }
    
    func loginUser() {
        
        if let userInfo = userInfo {
            NetworkManager.defaultManger.request(URLBuilder.getLoginURL(), method: .post, parameters: [:], encoding: userInfo).validate().responseJSON(completionHandler: { (loginResponse) in
                
                if loginResponse.error == nil {
                    self.completionHandler?(loginResponse.result.value, nil)
                }
                if let generatedError = loginResponse.error as? ResponseError {
                    self.completionHandler?(loginResponse.result, generatedError)
                } else {
                    
                }
            })
        }
    }
    
    func sendNewPasswordRequest() {
        if let userInfo = userInfo {
            NetworkManager.defaultManger.request(URLBuilder.getForgotPasswordURL(), method: .post, parameters: [:], encoding: userInfo).validate().responseJSON(completionHandler: { (Response) in
                if Response.error == nil {
                    print(Response.result)
                    self.completionHandler?(Response.result, nil)
                } else {
                    print("Error: \(Response.error)")
                    
                    self.completionHandler?(nil, nil)
                }
            })
        }
    }
    
    func downloadCitiesList() {
        if let userInfo = userInfo {
            let url = URLBuilder.getCitiesListURL() + userInfo
            NetworkManager.defaultManger.request(url, method: .get, parameters: [:], encoding: URLEncoding.methodDependent).validate().responseJSON(completionHandler: { (response) in
                if response.error == nil {
                    self.completionHandler?(response.result.value, nil)
                } else {
                    print("Error Downloading cities List")
                }
            })
        }
    }
    
    func downloadCountriesList() {
        NetworkManager.defaultManger.request(URLBuilder.getCountriesListURL(), method: .get, parameters: [:], encoding: URLEncoding.methodDependent).validate().generateResponseSerialization { (Response) in
            if Response.error == nil {
                self.completionHandler?(Response.JSON, Response.error)
            } else {
                self.completionHandler?(nil, Response.error)
            }
        }
    }
    
    func addNewAddress() {
        if let userInfo = userInfo {
            NetworkManager.defaultManger.request(URLBuilder.getAddAddressURL(), method: .post, parameters: [:], encoding: userInfo).validate().responseJSON(completionHandler: { (response) in
                if response.error == nil {
                    self.completionHandler?(response.result.value, nil)
                }
            })
        }
    }
    
    func downloadUserExistingAddress() {
        if let userInfo = userInfo {
            let url = URLBuilder.getUserExistingAddressURL() + userInfo
            NetworkManager.defaultManger.request(url,
                                                 method: .get,
                                                 parameters: [:],
                                                 encoding: URLEncoding.methodDependent)
                .validate().generateResponseSerialization { (Response) in
                    if Response.error == nil {
                        print("Existing Address: \(Response.JSON)")
                        self.completionHandler?(Response.JSON, nil)
                    } else {
                        self.completionHandler?(nil, Response.error)
                    }
            }
        }
    }
    
    func getCitiesBasedOnZoneId() {
        if let userInfo = userInfo {
            let url = URLBuilder.getCitiesBasedOnZoneId() + userInfo
            NetworkManager.defaultManger.request(url,
                                                 method: .get,
                                                 parameters: [:],
                                                 encoding: URLEncoding.methodDependent)
                .validate().generateResponseSerialization { (Response) in
                    if Response.error == nil {
                        print("Cities list of ZoneID: \(Response.JSON)")
                        self.completionHandler?(Response.JSON, nil)
                    } else {
                        self.completionHandler?(nil, Response.error)
                    }
            }
        }
    }
    
    func downloadBankTransferDetails() {
        NetworkManager.defaultManger.request(URLBuilder.getBankDetailsURL(),
                                             method: .get,
                                             parameters: [:],
                                             encoding: URLEncoding.methodDependent)
            .validate().generateResponseSerialization { (Response) in
                if Response.error == nil {
                    //print("Bank Details Response: \(Response.JSON)")
                    self.completionHandler?(Response.JSON, nil)
                    if let htmlContent = Response.JSON as? [String: AnyObject] {
                        
                        //print("Bank Details: \(htmlContent)")
                        let englishDetails = htmlContent["bank_transfer_bank1"]
                        let aranicDetails = htmlContent["bank_transfer_bank2"]
                        
                        print("English Bank Details: \(englishDetails)")
                        print("English Bank Details: \(aranicDetails)")
                    }
                } else {
                    self.completionHandler?(nil, Response.error)
                }
        }
    }
	
	func downloadUserProfileData() {
		if let userInfo = userInfo {
			let url = URLBuilder.getMyProfileData() + userInfo
			
			NetworkManager.defaultManger.request(url, method: .get, parameters: [:], encoding: URLEncoding.methodDependent).validate().generateResponseSerialization(completion: { (Response) in
				if Response.error == nil {
					self.completionHandler?(Response.JSON, nil)
				} else {
					self.completionHandler?(nil, Response.error)
				}
			})
		}
		
	}
	
	func getSDKToken() {
		if let userInfo = userInfo {
			
			NetworkManager.defaultManger.request(URLBuilder.payfortTokenGeneration(), method: .post, parameters: [:], encoding: userInfo).responseJSON(completionHandler: { (Response) in
				if Response.error == nil {
					print("Response: \(Response.result.value)")
					self.completionHandler?(Response.result.value, nil)
				} else {
					self.completionHandler?(nil, ResponseError(error: Response.error.debugDescription))
				}
			})
		}
	}
}
