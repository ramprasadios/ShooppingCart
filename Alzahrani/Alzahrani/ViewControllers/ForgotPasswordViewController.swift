//
//  ForgotPasswordViewController.swift
//  Alzahrani
//
//  Created by Hardwin on 09/05/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController {

    //IB-Outlet:
    @IBOutlet weak var userEmailAddress: SkyFloatingLabelTextField!
    
    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("Forgot Password", comment: "")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        if userEmailAddress.text?.characters.count == 0 || isValidEmail(userEmailAddress.text!) == false {
            userEmailAddress.errorMessage = NSLocalizedString("Please enter Valid Email", comment: "")
        } else{
            if let validEmail = userEmailAddress.text {
                let userInfo = "email=\(validEmail)"
                SyncManager.syncOperation(operationType: .forgotPassword, info: userInfo, completionHandler: { (result, error) in
                    if error == nil {
                        self.showAlertwith(alertMessage: "New Password will be sent to your Registered Email ID")
                    }
                })

            }
        }
    }
    
    func isValidEmail(_ testStr:String) -> Bool {
        
        let emailRegEx = "^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: testStr)
        
        return result
    }
    
    func showAlertwith(alertMessage msg: String) {
        let alertController = UIAlertController(title: Constants.alertTitle, message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
            let _ = self.navigationController?.popViewController(animated: true)
        })
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

//MARK:- UITextFieldDelegate
extension ForgotPasswordViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.returnKeyType == .done {
            userEmailAddress.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == userEmailAddress{
            textField.returnKeyType = .done
        }
        
    }
}
