//
//  PasswordUpdateViewController.swift
//  Alzahrani
//
//  Created by shilpa shree on 5/26/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class PasswordUpdateViewController: UIViewController {
//@Mark:- IBOutlets
    @IBOutlet weak var passwordTextField: SkyFloatingLabelTextField!
    
    @IBOutlet weak var confirmpasswordTextField: SkyFloatingLabelTextField!
    
    //@Mark:- LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetUp()
    }
    
    func initialSetUp(){
        self.updateUIElementText()
        self.title = NSLocalizedString("UPDATE_PASSWORD", comment: "")
        passwordTextField.delegate = self
        confirmpasswordTextField.delegate = self
    }
    
    func updateUIElementText() {
        self.passwordTextField.placeholder = NSLocalizedString("Password", comment: "")
        self.confirmpasswordTextField.placeholder = NSLocalizedString("Confirm Password", comment: "")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func updateAction(_ sender: Any) {
        if passwordTextField.text?.characters.count == 0
        {
            
            passwordTextField.errorMessage = "Password is required"
        }
        else if (passwordTextField.text?.characters.count)! < 6
        {
            passwordTextField.errorMessage = NSLocalizedString("PASSWORD_LENGTH_ERROR", comment: "")
        }
        else if confirmpasswordTextField.text?.characters.count == 0
        {
            confirmpasswordTextField.errorMessage = "Confirm Password is required."
        }
        else if passwordTextField.text != confirmpasswordTextField.text
        {
            confirmpasswordTextField.errorMessage = NSLocalizedString("PASSWORD_MATCH_ERROR", comment: "")

        }
                else{
            ProgressIndicatorController.showLoading()
           updatePasswordAction()
        }
        

    }
    func updatePasswordAction(){
        if let customer_id = UserDefaultManager.sharedManager().loginUserId {
            let param = "customer_id=\(customer_id)&password=\(passwordTextField.text!)"

            WebserviceEngine().requestforAPI(service: "customer/updatePassword", method: "POST", token: "", body:param, productBody: NSData()) { (result, error) in
                if result != nil
                {
                    NSLog("reviewlist \(result)")
                    ProgressIndicatorController.dismissProgressView()
                    if let successResponse = result as? [String: AnyObject] {
                        DispatchQueue.main.async {
                            if let successMessage = successResponse["success"] as? String {
                                let alertController = UIAlertController(title: Constants.alertTitle, message:
                                    successMessage, preferredStyle: UIAlertControllerStyle.alert)
                                alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: {
                                    (UIAlertAction) in
                                    let _ = self.navigationController?.popViewController(animated: true)
                                }))
                                
                                self.present(alertController, animated: true, completion: nil)
                            }
                        }
                    }
                }
                else
                {
                    if (error!.value(forKey: "code") as! NSNumber).stringValue == "-1001"
                    {ProgressIndicatorController.dismissProgressView()
                        DispatchQueue.main.sync(execute: { () -> Void in
                            
                            let alertController = UIAlertController(title: Constants.alertTitle, message:
                                "internet too slow", preferredStyle: UIAlertControllerStyle.alert)
                            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil))
                            self.present(alertController, animated: true, completion: nil)
                        })
                    }
                    if (error!.value(forKey: "code") as! NSNumber).stringValue == "-1009"
                    {ProgressIndicatorController.dismissProgressView()
                        DispatchQueue.main.sync(execute: { () -> Void in
                            
                            let alertController = UIAlertController(title: Constants.alertTitle, message:
                                "check your internet connection", preferredStyle: UIAlertControllerStyle.alert)
                            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil))
                            self.present(alertController, animated: true, completion: nil)
                            
                        })
                    }
                }
            }
        }
    }
}

//MARK:- TextFieldDelegates
extension PasswordUpdateViewController:UITextFieldDelegate{
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
       
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        
        if textField == passwordTextField
            
        {
            textField.returnKeyType = .next
        }
        if textField == confirmpasswordTextField{
            textField.returnKeyType = .done
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // textField.resignFirstResponder()
        
        
        
        
        if textField.returnKeyType == .next{
            if textField == passwordTextField{
                passwordTextField.resignFirstResponder()
                confirmpasswordTextField.becomeFirstResponder()
            }
        }
        else if textField.returnKeyType == .done{
            if textField == confirmpasswordTextField{
                confirmpasswordTextField.resignFirstResponder()
            }
            
        }
        
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == passwordTextField
        {
            if  passwordTextField.text?.characters.count != 0
            {
               passwordTextField.errorMessage =  ""
            }
            
        }
        if textField == confirmpasswordTextField
        {
            if  confirmpasswordTextField.text?.characters.count != 0
            {
               confirmpasswordTextField.errorMessage =  ""
            }
            
        }
        
        return true
    }


}
