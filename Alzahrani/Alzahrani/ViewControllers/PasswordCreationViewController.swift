//
//  PasswordCreationViewController.swift
//  Alzahrani
//
//  Created by GlobeSoft on 5/10/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

enum ScreenType {
    case login
    case home
}

class PasswordCreationViewController: UIViewController,CheckboxDelegate{

    
    //IBOutlets
    
    @IBOutlet weak var passwordField: SkyFloatingLabelTextField!
    @IBOutlet weak var confirmpasswordField: SkyFloatingLabelTextField!
    @IBOutlet weak var yesButton: ISRadioButton!
    @IBOutlet weak var checkBoxButton: CheckBox!
    @IBOutlet weak var noButton: ISRadioButton!
    
    //properties
    var screenType: ScreenType?
    var terms = false
    var customergroupid = ""
    var firstname = ""
    var lastname = ""
    var email = ""
    var telephone = ""
    var customfield  = ""
    var address1 = ""
    var address2  = ""
    var postcode  = ""
    var city = ""
    var company = ""
    var country = ""
    var zoneid = ""
    var  newsselection:Bool!
    var custField1 = ""
    var custField2 = ""
    var custField3 = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.noButton.isSelected = true
        newsselection = true
        passwordField.delegate = self
        confirmpasswordField.delegate = self
        checkBoxButton.delegate = self
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.title = "Sign Up"
    }
    
    func checkBoxClicked(_ checked:Bool, withTag tag: Int)
    {
        terms = checked
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signupAction(_ sender: Any) {
    
   
        
        
        if passwordField.text?.characters.count == 0
        {
            
            passwordField.errorMessage = "Password is required"
        }
        else if (passwordField.text?.characters.count)! < 6
        {
            passwordField.errorMessage = "password must be minimum length of 6 characters."
        }
        else if confirmpasswordField.text?.characters.count == 0
        {
            confirmpasswordField.errorMessage = " Confirm Password is required."
        }
        else if passwordField.text != confirmpasswordField.text
        {
            confirmpasswordField.errorMessage = "Password and Confirm Password must match."
        }
        else if  newsselection == false
        {
            let alertvc =  UIAlertController(title: Constants.alertTitle, message: "Please Check for Newsletter Subscription ", preferredStyle: .alert)
            alertvc.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil))
            
            self.present(alertvc, animated: false, completion: nil)
        }
            
        else if terms == false {
            let alertvc =  UIAlertController(title: NSLocalizedString("Please Check", comment: ""), message: "Please Accept Terms & Conditions ", preferredStyle: .alert)
            
            alertvc.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil))
            
            self.present(alertvc, animated: false, completion: nil)
        }
        else{
            SwiftLoader.show(title: "Loading", animated: true)
            
            registerNewUser()
        }
        
    }
    
    @IBAction func subscribeActionTapped(_ sender: Any) {
        self.newsselection = true
    }
    
    @IBAction func subscribeDeniedTapped(_ sender: Any) {
        self.newsselection = true
    }
    
    
    func registerNewUser()
    {
        var registerBody = ""
        
        
        let customFields = ["6":"25", "1":"1234567890", "3":""]
        
        
        
        
        // registerBody = "customer_group-id=\("17")&firstname=\("selvam")&lastname=\("ram")&email=\("123@gmail.com")&telephone=\("11111111")&custom_field=\(customFields)&address_1=\("zzzzzzzz")&address_2=\("xxxxxx")&postcode=\("6754321")&city=\("Bangalore")&company=\("MNs company")&country_id=\("253")&zone_id=\("112")&password=\("123456789")"
        
        let languageId = (AppManager.languageType() == .arabic) ? "2" : "1"
        registerBody = "customer_group_id=\(customergroupid)&firstname=\(firstname)&lastname=\(lastname)&email=\(email)&telephone=\(telephone)&address_1=\(address1)&address_2=\(address2)&postcode=\(postcode)&city=\(city)&company=\(company)&country_id=\(country)&zone_id=\(zoneid)&password=\(self.passwordField.text!)&\(custField1)&\(custField2)&\(custField3)&language_id=\(languageId)"
        print("registerBody",registerBody)
        
        WebserviceEngine().requestforAPI(service: "customer/register", method: "POST", token: "", body: registerBody, productBody: NSData()) { (result, error) in
            if result != nil
            {
                print("result",result!)
                
                if result?.value(forKey: "success") != nil{
                    DispatchQueue.main.sync(execute: { () -> Void in
                        SwiftLoader.hide()
                        
                        let alertController = UIAlertController(title: Constants.alertTitle, message:
                            "You have successfully registered", preferredStyle: UIAlertControllerStyle.alert)
                        let OkAction = UIAlertAction(title: "OK", style: .default, handler: { (alert: UIAlertAction!) -> Void in
                            if self.screenType == .login {
                                self.dismiss(animated: true, completion: nil)
                            } else {
                                self.dismiss(animated: true, completion: {
                                    NotificationCenter.default.post(name: Notification.Name(Constants.signupSuccessNotification), object: nil)
                                })
                            }
                        })
                        alertController.addAction(OkAction)
                        self.present(alertController, animated: true, completion: nil)
                    })
                }
                else
                {
                    DispatchQueue.main.sync(execute: { () -> Void in
                        SwiftLoader.hide()
                        if let resultData = result as? [String: AnyObject] {
                            if let alertMessage = resultData["error"] {
                                if let errorMsg = alertMessage["warning"] as? String {
                                    let alertController = UIAlertController(title:Constants.alertTitle, message:
                                        errorMsg, preferredStyle: UIAlertControllerStyle.alert)
                                    alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil))
                                    self.present(alertController, animated: true, completion: nil)
                                }
                            }
                        }
                    })
                }
            }
            else
            {
                if (error!.value(forKey: "code") as! NSNumber).stringValue == "-1001"
                {
                    DispatchQueue.main.sync(execute: { () -> Void in
                        SwiftLoader.hide()
                        let alertController = UIAlertController(title: Constants.alertTitle, message:
                            "internet too slow", preferredStyle: UIAlertControllerStyle.alert)
                        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                    })
                }
                if (error!.value(forKey: "code") as! NSNumber).stringValue == "-1009"
                {
                    DispatchQueue.main.sync(execute: { () -> Void in
                        SwiftLoader.hide()
                        let alertController = UIAlertController(title: Constants.alertTitle, message:
                            "check your internet connection", preferredStyle: UIAlertControllerStyle.alert)
                        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                        
                    })
                }
            }
        }
    }
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
extension PasswordCreationViewController:UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        
        if textField == passwordField
            
        {
            textField.returnKeyType = .next
        }
        if textField == confirmpasswordField{
            textField.returnKeyType = .done
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // textField.resignFirstResponder()
        
        
        
        
        if textField.returnKeyType == .next{
            if textField == passwordField{
                passwordField.resignFirstResponder()
                confirmpasswordField.becomeFirstResponder()
            }
        }
        else if textField.returnKeyType == .done{
            if textField == confirmpasswordField{
                confirmpasswordField.resignFirstResponder()
            }
            
        }
        
        return true
    }
    
}
