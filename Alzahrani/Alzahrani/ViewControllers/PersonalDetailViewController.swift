//
//  PersonalDetailViewController.swift
//  Alzahrani
//
//  Created by shilpa shree on 5/26/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class PersonalDetailViewController: UIViewController {

    // MARK: - IBOutlets
		@IBOutlet weak var departmentTextField: SkyFloatingLabelTextField!
		@IBOutlet weak var employeeIDTextField: SkyFloatingLabelTextField!
	let departmentArray = ["Trading", "Trans", "Management"]
	
    @IBOutlet weak var personalScrollView: UIScrollView!
    @IBOutlet weak var personalView: UIView!
    @IBOutlet weak var firstnameField: SkyFloatingLabelTextField!
    @IBOutlet weak var personalDetailView: UIView!
    @IBOutlet weak var lastNameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var emailTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var tlephoneTextField: SkyFloatingLabelTextField!
    
    //MARK: - Properties
    var activeField :AnyObject?
    var email = ""
    var mobile = ""
    var firstname = ""
    var secondName = ""
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getPersonalDetails()
        initialSetUp()
        self.updateUIElementText()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func initialSetUp(){
        self.title = NSLocalizedString("UPDATE_PERSONAL_INFO", comment: "")
    firstnameField.delegate = self
    lastNameTextField.delegate =  self
    tlephoneTextField.delegate =  self
    emailTextField.delegate = self
       
        if(AppManager.isUserLoggedIn == true){
        firstnameField.text = self.firstname
        lastNameTextField.text = self.secondName
        tlephoneTextField.text = self.mobile
        emailTextField.text = self.email
        //addNotificationObservers()
        } else {
            firstnameField.text = ""; lastNameTextField.text = ""; tlephoneTextField.text = ""; emailTextField.text = ""
        }
			
			if AppManager.getLoggedInUserType() == .endUser {
				self.employeeIDTextField.isHidden = true
				self.departmentTextField.isHidden = true
			} else {
				self.employeeIDTextField.isHidden = false
				self.departmentTextField.isHidden = false
			}
    }
	
    func updateUIElementText() {
        self.firstnameField.placeholder = NSLocalizedString("First Name", comment: "")
        self.lastNameTextField.placeholder = NSLocalizedString("Last Name", comment: "")
        self.emailTextField.placeholder = NSLocalizedString("Email", comment: "")
        self.tlephoneTextField.placeholder = NSLocalizedString("Telephone", comment: "")
    }
    
    func getPersonalDetails() {
        
        if let customer_id = UserDefaultManager.sharedManager().loginUserId {
					self.departmentTextField.text = "Please wait.."
					self.employeeIDTextField.text = "Please wait.."
            WebserviceEngine().requestforAPI(service: "customer/getmyProfile&customer_id=\(customer_id)", method: "GET", token: "", body: "", productBody: NSData()) { (result, error) in
                if result != nil
                {
                    print("reviewlist \(result)")
                    
                    
                    if let records = result?.value(forKey:"records"){
                        if let newrecords = records as? [[String: AnyObject]] {
													if let company = newrecords.first?["company"] as? String {
														DispatchQueue.main.async {
															self.departmentTextField.text = company
														}
													}
													
													if let customerFields = newrecords.first?["custom_field"] as? [String: AnyObject] {
														if let employeeId = customerFields["1"] as? String {
															DispatchQueue.main.async {
																self.employeeIDTextField.text = employeeId
															}
														}
													}
                        }
											
                    }
                    DispatchQueue.main.sync(execute: { () -> Void in
                        ProgressIndicatorController.dismissProgressView()
                    })
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
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func addNotificationObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(PersonalDetailViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PersonalDetailViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    func isValidEmail(_ testStr:String) -> Bool {
        
        let emailRegEx = "^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: testStr)
        
        return result
    }
    
    func keyboardWillShow(_ notification:Notification) {
        adjustingHeight(true, notification: notification)
    }
    
    func keyboardWillHide(_ notification:Notification) {
        personalScrollView.contentInset = UIEdgeInsets.zero
    personalScrollView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
    
    
    func adjustingHeight(_ show:Bool, notification:Notification) {
        
        self.personalScrollView.isScrollEnabled = true
        let info : NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        var height:CGFloat = 0
        
        if activeField is UITextView
        {
            height = CGFloat(Constants.resizeWithToolbar)
        }
        else if activeField is  UITextField
        {
            height = CGFloat(Constants.resizeWithToolbar)
        }
        
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height + height, 0.0)
        
        self.personalScrollView.contentInset = contentInsets
        self.personalScrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= (keyboardSize!.height + height)
        if let activeFieldPresent = activeField
        {
            if (!aRect.contains(activeFieldPresent.frame.origin))
            {
                personalScrollView.scrollRectToVisible(activeFieldPresent.frame, animated: true)
            }
        }
    }



    @IBAction func updateAction(_ sender: Any) {
        
        if firstnameField.text?.characters.count == 0
        {
            
            firstnameField.errorMessage = "FirstName is required"
        }
        else if (tlephoneTextField.text?.characters.count)! > 15
        {
           tlephoneTextField.errorMessage = "Valid Phone Number is Required"
        }
        else if tlephoneTextField.text?.characters.count == 0
        {
             tlephoneTextField.errorMessage = " Telephone num is required."
        }
        else if lastNameTextField.text?.characters.count == 0
        {
            lastNameTextField.errorMessage = "Last name is rewuired"
        }
        else if (emailTextField.text?.characters.count) == 0 || isValidEmail(emailTextField.text!) == false
        {
            emailTextField.errorMessage = "Enter Valid Email ID"
        } /* else if (UserDefaultManager.sharedManager().customerEmail == emailTextField.text) {
            emailTextField.errorMessage = "Email Already Exist"
        } */
        else{
            ProgressIndicatorController.showLoading()
            updateAction()
        }
    }
    
    func updateAction(){
        let languageId = (AppManager.languageType() == .arabic) ? "2" : "1"
        if let customer_id = UserDefaultManager.sharedManager().loginUserId {
            let param = "firstname=\(self.firstnameField.text!)&lastname=\(self.lastNameTextField.text!)&email=\(emailTextField.text!)&telephone=\(tlephoneTextField.text!)&customer_id=\(customer_id)&language_id=\(languageId)"
            
            WebserviceEngine().requestforAPI(service: "customer/updateProfile", method: "POST", token: "", body:param, productBody: NSData()) { (result, error) in
                if result != nil
                {
                    NSLog("reviewlist \(result)")
                    
                    // DispatchQueue.main.sync(execute: { () -> Void in
                    ProgressIndicatorController.dismissProgressView()
                    if let successResponse = result as? [String: AnyObject] {
                        if let successMessage = successResponse["success"] as? String {
                            let alertController = UIAlertController(title: Constants.alertTitle, message:
                                successMessage, preferredStyle: UIAlertControllerStyle.alert)
                            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: {
                                (UIAlertAction) in
                                let _ = self.navigationController?.popViewController(animated: true)
                            }))
                            DispatchQueue.main.async {
                                self.present(alertController, animated: true, completion: nil)
                            }
                        } else {
                            if let errorObject = successResponse["error"] {
                                if let errorMsg = errorObject["warning"] as? String {
                                    let alertController = UIAlertController(title: Constants.alertTitle, message:
                                        errorMsg, preferredStyle: UIAlertControllerStyle.alert)
                                    alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil))
                                    
                                    DispatchQueue.main.async {
                                        self.present(alertController, animated: true, completion: nil)
                                    }
                                }
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

extension PersonalDetailViewController:UITextFieldDelegate{
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeField = textField
        
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        
        if textField == firstnameField
            
        {
            textField.returnKeyType = .next
        }
        if textField == lastNameTextField
            
        {
            textField.returnKeyType = .next
        }
        if textField == emailTextField
            
        {
            textField.returnKeyType = .next
        }

        if textField ==  tlephoneTextField{
            tlephoneTextField.keyboardType = UIKeyboardType.numberPad
            let keyPadToolBar = UIToolbar()
            keyPadToolBar.barStyle = UIBarStyle.blackTranslucent
            keyPadToolBar.sizeToFit()
            let DoneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector( PersonalDetailViewController.dismissKeypadmobile))
            keyPadToolBar.setItems([DoneButton], animated: true)
            tlephoneTextField.inputAccessoryView = keyPadToolBar
             animateViewMoving (up:true, moveValue :40)
        }
		
		if textField == self.departmentTextField {
			textField.resignFirstResponder()
			self.showCompanyList()
		}
    }
    func dismissKeypadmobile(){
        animateViewMoving (up:false, moveValue :40)
        tlephoneTextField.resignFirstResponder()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // textField.resignFirstResponder()
        
        
        
        
        if textField.returnKeyType == .next{
            if textField == firstnameField{
                firstnameField.resignFirstResponder()
                lastNameTextField.becomeFirstResponder()
            }
            if textField == lastNameTextField{
                lastNameTextField.resignFirstResponder()
              emailTextField
                .becomeFirstResponder()
            }
            if textField == emailTextField{
                emailTextField.resignFirstResponder()
                tlephoneTextField
                    .becomeFirstResponder()
            }
            
        }
//        else if textField.returnKeyType == .done{
//            if textField ==  tlephoneTextField{
//                tlephoneTextField.resignFirstResponder()
//            }
//            
//        }
        
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == firstnameField
        {
            if  firstnameField.text?.characters.count != 0
            {
                firstnameField.errorMessage =  ""
            }
            
        }
        if textField == lastNameTextField
        {
            if   lastNameTextField.text?.characters.count != 0
            {
                lastNameTextField.errorMessage =  ""
            }
            
        }
        if textField ==  tlephoneTextField
        {
            if (range.location == 9 && string.characters.count == 1) || (range.location < 16 && string.characters.count >= 0)
            {
                tlephoneTextField.errorMessage = ""
            }
            else
            {
                tlephoneTextField.errorMessage =  "Enter Valid Mobile Number"
            }
        }
        else if textField ==  emailTextField
        {
            if isValidEmail( emailTextField.text!) == true
            {
                emailTextField.errorMessage = ""
            }
            // else
            //  {
            //      emailTextField.errorMessage = "Enter Valid Email ID"
            //  }
        }

        
        return true
    }
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = self.view.frame.offsetBy(dx: 0,  dy: movement)
        UIView.commitAnimations()
    }

    
    
}

extension PersonalDetailViewController {
	
	func showCompanyList() {
		let dropDownMenuVc = self.storyboard?.instantiateViewController(withIdentifier: MenuPopTableViewController.selfName()) as? MenuPopTableViewController
		dropDownMenuVc?.delegate = self
		dropDownMenuVc?.contentSize = CGSize(width: CGFloat(self.departmentTextField.frame.size.width),height: CGFloat(44 * self.numberOfMenu()))
		dropDownMenuVc?.popoverPresentationController?.permittedArrowDirections = .any
		dropDownMenuVc?.popoverPresentationController?.sourceView = self.departmentTextField as UIView
		dropDownMenuVc?.popoverPresentationController?.sourceRect = self.departmentTextField.bounds
		dropDownMenuVc?.popoverPresentationController?.delegate = dropDownMenuVc
		dropDownMenuVc?.sourceRect = self.departmentTextField.bounds
		
		self.present(dropDownMenuVc!, animated: true, completion: nil)
	}
}

//MARK:- MenuPopViewControllerDelegate
extension PersonalDetailViewController: MenuPopViewControllerDelegate {
	
	func numberOfMenu() -> Int {
		return self.departmentArray.count
	}
	
	func menuNameAtIndexPath(indexPath: IndexPath) -> String {
		return self.departmentArray[indexPath.row]
	}
	
	func didSelectMenuAtIndexPath(indexPath: IndexPath, menuController: MenuPopTableViewController) {
		self.departmentTextField.text = self.departmentArray[indexPath.row]
	}
}
