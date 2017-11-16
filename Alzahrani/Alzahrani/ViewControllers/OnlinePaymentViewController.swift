//
//  OnlinePaymentViewController.swift
//  Alzahrani
//
//  Created by Hardwin on 15/06/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class OnlinePaymentViewController: UIViewController {
    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var cardNumber: UITextField!
    @IBOutlet weak var yearLabel: UITextField!
    @IBOutlet weak var monthLabel: UITextField!
    @IBOutlet weak var cvvTextField: UITextField!
    
    
    var deleveryAddressType: UserAddressType = .existingAddress
    var billingAddressType: UserAddressType = .existingAddress
    var cartPaymentData = [CartProductData]()
    var totalPrice = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func placeOrderButtonTapped(_ sender: Any) {
       // self.getPostParameters()
        print("Testing")
        /*let PayFort = PayFortController.init(enviroment:KPayFortEnviromentSandBox)
        PayFort?.setPayFortCustomViewNib("PayFortView2")
        
        let request = NSMutableDictionary.init()
        request.setValue("1000", forKey: "amount")
        request.setValue("AUTHORIZATION", forKey: "command")
        request.setValue("USD", forKey: "currency")
        request.setValue("email@domain.com", forKey: "customer_email")
        request.setValue("en", forKey: "language")
        request.setValue("mzZGyHy1OIoweMCHUZf1", forKey: "merchant_reference")
        request.setValue("Dwp78q3" , forKey: "sdk_token")
        
        PayFort?.callPayFort(withRequest: request, currentViewController: self,
                                  success: { (requestDic, responeDic) in
                                    print("success")
        },
                                  canceled: { (requestDic, responeDic) in
                                    print("canceled")
        },
                                  faild: { (requestDic, responeDic, message) in
                                    print("faild")
                                    
        })*/
        let str="KFUPMaccess_code=RuEmXiToxlHnq4OvqXG9language=enmerchant_identifier=StMMQqrnmerchant_reference=MyReference0001service_command=TOKENIZATIONKFUPM"
        
        let signature=self.digest(input: str.data(using: String.Encoding.utf8)!)
        print("sha256 val is \(signature)")
        let signaturestring = getHexString(fromData: signature)
       // self.createTokenId(signature: signature)
        print("sha256 val string is \(signaturestring)")
        
        
        
    }
    
   /* func get_sha256_String(shaValue:String) -> String {
        guard let data = shaValue.data(using: .utf8) else {
            print("Data not available")
            return ""
        }
        return getHexString(fromData: digest(input: data as NSData))
    }*/
    
    private func digest(input : Data) -> Data {
        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
        var hashValue = [UInt8](repeating: 0, count: digestLength)
        input.withUnsafeBytes {
            _ = CC_SHA256($0, CC_LONG(input.count), &hashValue)
        }
        //CC_SHA256(input.bytes, UInt32(input.length), &hashValue)
        //return NSData(bytes: hashValue, length: digestLength)
        return Data(bytes: hashValue)
    }

  func getHexString(fromData data: Data) -> String {
    var bytes = [UInt8](repeating: 0, count: data.count)
    data.copyBytes(to: &bytes, count: data.count)
    
    var hexString = ""
    for byte in bytes {
        hexString += String(format:"%02x", UInt8(byte))
    }
    return hexString
     }
    
    func createTokenId(signature:String)
    {
        
        /*let request = NSMutableURLRequest(url: NSURL(string: "http://httpstat.us/200")! as URL)
        let session = URLSession.shared
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        /*String jsonRequestString = "{\"query_command\" : \"CHECK_STATUS\" \"access_code\" : \"zx0IPmPy5jp1vAz8Kpg7\", \"merchant_identifier\" : \"CycHZxVj\","
            + "\"merchant_reference\" : \"XYZ9239-yu898\", \"language\" : \"en\", "
            + "\"signature\" : \"7cad05f0212ed933c9a5d5dffa31661acf2c827a\"}";
        */
        var body=[String:AnyObject]()
        
        body["access_code"]="mzZGyHy1OIoweMCHUZf1" as AnyObject?
         body["merchant_identifier"]="ypMdLuMV" as AnyObject?
        body["merchant_reference"]="MyReference0001" as AnyObject?
        body["language"]="en" as AnyObject?
        body["signature"]=signature as AnyObject?
        
        do {
            // Set the POST body for the request
          
        } catch {
            // Create your personal error
            //onCompletion(nil, nil)
        }*/
        
        let syncDataFormat = "&query_command=CHECK_STATUS&access_code=mzZGyHy1OIoweMCHUZf1&merchant_identifier=ypMdLuMV&merchant_reference=MyReference0001&language=en&signature=\(signature)"
        
        print("url==\(URLBuilder.payFortTokenUrl())");
        
        NetworkManager.defaultManger.request(URLBuilder.payFortTokenUrl(), method: .post, parameters: [:], encoding: syncDataFormat).validate().generateResponseSerialization(completion: { (Response) in
            if Response.error == nil {
                print("payfort token id \(Response.JSON)")
                //self.completionHandler?(Response.JSON, nil)
            } else {
                print("payfort token id  error=\(Response)")
                //self.completionHandler?(nil, Response.error)
            }
        })
 
    }
}

extension OnlinePaymentViewController {
    
    func getPostParameters() {
        let deleveryTypeAddress: UserAddressData!
        let billingTypeAddress: UserAddressData!
        
        switch self.billingAddressType {
            
        case .existingAddress:
            billingTypeAddress = UserShipppingAddress.sharedInstance.userDefaultAddress
        case .newAddress:
            billingTypeAddress = UserShipppingAddress.sharedInstance.userAddressData[0]
        }
        
        switch self.deleveryAddressType {
        case .existingAddress:
            deleveryTypeAddress = UserShipppingAddress.sharedInstance.userDefaultAddress
        case .newAddress:
            if self.billingAddressType == .newAddress {
                deleveryTypeAddress = UserShipppingAddress.sharedInstance.userAddressData[1]
            } else {
                deleveryTypeAddress = UserShipppingAddress.sharedInstance.userAddressData[0]
            }
        }
        
        func getSubTotal() -> String {
            var locVal: Int = 0
            for cartData in cartPaymentData {
                if let price = Int(cartData.totalPrice!) {
                    locVal = locVal + price
                }
            }
            self.totalPrice = locVal.description
            return locVal.description
        }
        
        var fName = ""
        var lName = ""
        var userEmail = ""
        var userPhone = ""
        
        if let firstName = UserDefaultManager.sharedManager().userFirstName {
            fName = firstName
        }
        if let lastName =  UserDefaultManager.sharedManager().userLastName {
            lName = lastName
        }
        if let userEmailId = UserDefaultManager.sharedManager().customerEmail {
            userEmail = userEmailId
        }
        if let userPhoneNum = UserDefaultManager.sharedManager().customerMobile {
            userPhone = userPhoneNum
        }
        
        let languageId = (AppManager.languageType() == .arabic) ? "2" : "1"
        let syncParameter1 = "customer_id=\(billingTypeAddress.customerId)&customer_group_id=\(billingTypeAddress.customerGroupId)&firstname=\(fName)&lastname=\(lName)&email=\(userEmail)&telephone=\(userPhone)&fax=\(userPhone)&reward=\("0")&payment_firstname=\(billingTypeAddress.firstName)&payment_lastname=\(billingTypeAddress.lastName)&payment_company=\("")&payment_company_id=\("17")&payment_address_1=\(billingTypeAddress.address1)&payment_address_2=\(billingTypeAddress.address2)&payment_city=\(billingTypeAddress.city)&payment_postcode=\(billingTypeAddress.postCode)&payment_country=\(billingTypeAddress.country)&payment_country_id=\(billingTypeAddress.countryId)&payment_tax_id=\("0")&payment_zone=\(billingTypeAddress.city)&payment_zone_id=\(billingTypeAddress.zoneId)&payment_method=\("Credit / Debit Card")&payment_code=\("payfort_fort")&"
        
        let syncParameter2 = "shipping_firstname=\(deleveryTypeAddress.firstName)&shipping_lastname=\(deleveryTypeAddress.lastName)&shipping_company=\("")&shipping_company_id=\("")&shipping_address_1=\(deleveryTypeAddress.address1)&shipping_address_2=\(deleveryTypeAddress.address2)&shipping_city=\(deleveryTypeAddress.city)&shipping_postcode=\(deleveryTypeAddress.postCode)&shipping_country=\(deleveryTypeAddress.country)&shipping_country_id=\(deleveryTypeAddress.countryId)&shipping_tax_id=\("0")&shipping_zone=\(deleveryTypeAddress.city)&total=\("0")&shipping_method=\("Free Shipping")&shipping_code=\("free.free")&shipping_zone_id=\(deleveryTypeAddress.zoneId)&total=\(self.totalPrice)&language_id=\(languageId)"
        
        let finalParameter = syncParameter1 + syncParameter2
        
        if let userNameStr = self.userName.text, let cardNumberStr = self.cardNumber.text, let yearStr = self.yearLabel.text, let monthStr = self.monthLabel.text, let cvvStr = self.cvvTextField.text {
            let expiryData = yearStr + monthStr
            let syncParam = "merchant_identifier=\("StMMQqrn")&access_code=\("RuEmXiToxlHnq4OvqXG9")&merchant_reference=\("11415")&language=\("en")&service_command=\("TOKENIZATION")&signature=\("")&card_holder_name=\(userNameStr)&card_number=\(cardNumberStr)expiry_date=\(expiryData)&card_security_code=\(cvvStr)"
            
            let signature = syncParam.sha256()
            
            let syncParamStr = "merchant_identifier=\("StMMQqrn")&access_code=\("RuEmXiToxlHnq4OvqXG9")&merchant_reference=\("11415")&language=\("en")&service_command=\("TOKENIZATION")&signature=\(signature)&card_holder_name=\(userNameStr)&card_number=\(cardNumberStr)&expiry_date=\(expiryData)&card_security_code=\(cvvStr)&return_url=\("http://alzahrani-online.com/index.php?route=payment/payfort_fort/merchantPageResponse")"
            
            SyncManager.syncOperation(operationType: .onlinePayment, info: syncParamStr, completionHandler: { (response, error) in
                if response != nil {
                    print("Online Payment Response: \(response)")
                    
                    SyncManager.syncOperation(operationType: .placeOrder, info: finalParameter, completionHandler: { (response, error) in
                        //ProgressIndicatorController.dismissProgressView()
                        if error == nil {
                            let _ = self.navigationController?.popToRootViewController(animated: true)
                            
                            print("Response : \(response)")
                            if let response = response as? [String: AnyObject] {
                                if let successMessage = response["success"] as? String {
                                    self.showUserAlert(withMessage: successMessage)
                                }
                            }
                        } else {
                            print("Error: \(error)")
                            ProgressIndicatorController.dismissProgressView()
                        }
                    })
                }
            })
        }
        //ProgressIndicatorController.showLoading()
        
    }

    func showUserAlert(withMessage msg: String) {
        let alertController = UIAlertController(title: NSLocalizedString("Alzahrani", comment: ""), message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default) { (UIAlertAction) in
            self.dismiss(animated: true, completion: { 
                NotificationCenter.default.post(name: Notification.Name(Constants.sliderMenuFieldTapNotification), object: nil, userInfo: nil)
            })
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension OnlinePaymentViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
