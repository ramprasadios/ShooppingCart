


//
//  RegistrationViewController.swift
//  Alzahrani
//
//  Created by GlobeSoft on 5/10/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

enum conetentType
{
    case compnanyType
    case stateType
    case countryType
    case employeeType
    case cityType
}

enum CustomFieldType: Int {
    case endCustomer = 25
    case trans = 26
    case management = 27
}

class RegistrationViewController: UIViewController,listDelegate,UIPopoverPresentationControllerDelegate,UIPopoverControllerDelegate {
    
    //IB outlets
    
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    @IBOutlet weak var mainViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var employeeField: SkyFloatingLabelTextField!
    @IBOutlet weak var companyName: SkyFloatingLabelTextField!
    @IBOutlet weak var firstName: SkyFloatingLabelTextField!
    @IBOutlet weak var lastName: SkyFloatingLabelTextField!
    @IBOutlet weak var email: SkyFloatingLabelTextField!
    @IBOutlet weak var telephone: SkyFloatingLabelTextField!
    @IBOutlet weak var signupView: UIView!
    @IBOutlet weak var addresscompanyField: SkyFloatingLabelTextField!
    @IBOutlet weak var emplyeeButton: UIButton!
    @IBOutlet weak var address1: SkyFloatingLabelTextField!
    @IBOutlet weak var address2: SkyFloatingLabelTextField!
    @IBOutlet weak var companyButton: UIButton!
    @IBOutlet weak var cityField: SkyFloatingLabelTextField!
    @IBOutlet weak var pincodeField: SkyFloatingLabelTextField!
    @IBOutlet weak var countryField: SkyFloatingLabelTextField!
    @IBOutlet weak var stateField: SkyFloatingLabelTextField!
    @IBOutlet weak var employeeButton: ISRadioButton!
    @IBOutlet weak var registerScrolllView: UIScrollView!
    @IBOutlet weak var cityListTextField: SkyFloatingLabelTextField!
    
    
    //Properties
    var screenType: ScreenType?
    var activeField :AnyObject?
    var fieldType:conetentType!
    var selectedusertype = ""
    var countryArray = NSMutableArray()
    var countryidArray = NSMutableArray()
    var regionArray = NSMutableArray()
    var zoneidArray = NSMutableArray()
    var selectedcountryID = ""
    var selectedzoneid = ""
    var cityListData = [CityData]()
    
    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("SIGNUP_TITLE", comment: "")
        // SwiftLoader.show(title: "Loading", animated: true)
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            self.getCountryList()
        }
        
        self.initialSetup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mainViewHeightConstraint.constant = 780.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @IBAction func nextAction(_ sender: Any) {
        if employeeField.text?.characters.count == 0
        {
            employeeField.errorMessage = "Valid EmployeeID is required"
        }
        
        /* if companyName.text?.characters.count == 0
        {
            companyName.errorMessage = "Valid companyName is required"
        } */
        
        if firstName.text?.characters.count == 0
        {
            firstName.errorMessage = "Valid FirstName is required"
        }
            
        else if lastName.text?.characters.count == 0
        {
            lastName.errorMessage = " Valid LastName is required"
        }
        else if telephone.text?.characters.count == 0 ||  (telephone.text?.characters.count)! < 10
        {
            telephone.errorMessage = "Valid  is required"
        }
        else if email.text?.characters.count == 0 || isValidEmail(email.text!) == false
        {
            email.errorMessage = "Enter Valid Email ID"
        }
            
        else if address1.text?.characters.count == 0
        {
            address1.errorMessage = "Valid Address is required"
        }
        else if (address1.text?.characters.count)! > 15
        {
            address1.errorMessage = "Valid Phone Number is Required"
        }
        else if (cityListTextField.text?.characters.count)! == 0
        {
            cityListTextField.errorMessage = "Valid City is required"
        }
        else if (countryField.text?.characters.count)! == 0
        {
            countryField.errorMessage = "Valid Country is required"
        }
            
        else if (stateField.text?.characters.count)! == 0
        {
            stateField.errorMessage = "Valid State is required"
        }
            
        else if selectedusertype == ""{
            
            let alertvc =  UIAlertController(title: NSLocalizedString("Please Check", comment: ""), message: "Please Select user type ", preferredStyle: .alert)
            
            alertvc.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil))
            
            self.present(alertvc, animated: false, completion: nil)
        }
        else{
            
            let newvc = self.storyboard?.instantiateViewController(withIdentifier: "passwordcreationvc") as! PasswordCreationViewController
            newvc.country = self.selectedcountryID
            newvc.zoneid = self.selectedzoneid
            newvc.firstname = self.firstName.text!
            newvc.screenType = self.screenType
            newvc.email = self.email.text!
            
            let customfield = self.employeeField.text ?? ""
            var customField1 = ""
            var customField2 = ""
            var customField3 = ""
            if companyName.text == "Trading" {
                customField1 = "custom_field[account][6]:\(25)"
                customField2 = "custom_field[account][1]:\("123456")"
                customField3 = "custom_field[account][3]:"
                
                newvc.custField1 = customField1
                newvc.custField2 = customField2
                newvc.custField3 = customField3
                
            } else if companyName.text == "Trans" {
                customField1 = "custom_field[account][6]=\("26")"
                customField2 = "custom_field[account][1]=\("123456")"
                customField3 = "custom_field[account][3]="
                
                newvc.custField1 = customField1
                newvc.custField2 = customField2
                newvc.custField3 = customField3
                
            } else if companyName.text == "Management" {
                customField1 = "custom_field[account][6]=\("27")"
                customField2 = "custom_field[account][1]=\("123456")"
                customField3 = "custom_field[account][3]="
                
                newvc.custField1 = customField1
                newvc.custField2 = customField2
                newvc.custField3 = customField3
            }
            
            newvc.customfield = customfield
            newvc.lastname = self.lastName.text!
            newvc.address2 = self.address2.text!
            newvc.city = self.cityListTextField.text!
            newvc.address1 = self.address1.text!
            newvc.telephone = self.telephone.text!
            let pincode  = pincodeField.text ?? ""
            newvc.postcode = pincode
            let aaddress2 = self.address2.text ?? ""
            newvc.address2 = aaddress2
            var company = ""
            
            var customergroupid = ""
            if self.selectedusertype == "Emplyoee"{
                customergroupid = "17"
                company = self.companyName.text!
            }
            else {
                customergroupid = "1"
                company = self.addresscompanyField.text ?? ""
                
                customField1 = "custom_field[account][6]=\("25")"
                customField2 = "custom_field[account][1]=\("123456")"
                customField3 = "custom_field[account][3]="
                
                newvc.custField1 = customField1
                newvc.custField2 = customField2
                newvc.custField3 = customField3
            }
            
            newvc.customergroupid = customergroupid
            newvc.company = company
            
            self.navigationController?.pushViewController(newvc, animated: true)
        }
    }
    
    @IBAction func cancelButtontapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func isValidEmail(_ testStr:String) -> Bool {
        
        let emailRegEx = "^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: testStr)
        
        return result
    }
    
    func countryList(){
        self.countryField.errorMessage = ""
        
        let popoverViewController  = self.storyboard?.instantiateViewController(withIdentifier: "listvc") as! ListViewController
        popoverViewController.delegate = self
        fieldType = conetentType.countryType
        popoverViewController.preferredContentSize = CGSize(width: self.countryField.frame.size.width, height: 250.0)
        popoverViewController.modalPresentationStyle = UIModalPresentationStyle.popover
        popoverViewController.popoverPresentationController!.delegate = self
        popoverViewController.popoverPresentationController?.sourceView = self.view
        popoverViewController.popoverPresentationController?.sourceRect = CGRect(x: registerScrolllView.frame.origin.x + self.countryField.frame.origin.x+60,y: registerScrolllView.frame.origin.y + self.countryField.frame.origin.y-40,width: 0,height: 0)
        
        popoverViewController.listArray = self.countryArray as [AnyObject]
        
        self.present(popoverViewController, animated: true, completion: nil)
        
        
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    
    @IBAction func showemployeeList(_ sender: Any) {
        
        showEmployeeList()
    }
    func showEmployeeList(){
        self.employeeField.errorMessage = ""
        
        let popoverViewController  = self.storyboard?.instantiateViewController(withIdentifier: "listvc") as! ListViewController
        popoverViewController.delegate = self
        fieldType = conetentType.employeeType
        popoverViewController.preferredContentSize = CGSize(width: self.employeeField.frame.size.width, height: 80.0)
        popoverViewController.modalPresentationStyle = UIModalPresentationStyle.popover
        popoverViewController.popoverPresentationController!.delegate = self
        popoverViewController.popoverPresentationController?.sourceView = self.view
        popoverViewController.popoverPresentationController?.sourceRect = CGRect(x: self.registerScrolllView.frame.origin.x + self.employeeField.frame.origin.x ,y: self.view.frame.origin.y + self.employeeField.frame.origin.y+80,width: 0,height: 0)
        
        
        popoverViewController.listArray = ["Trading" as AnyObject,"Trans" as AnyObject,"Management" as AnyObject]
        
        self.present(popoverViewController, animated: true, completion: nil)
        
    }
    
    func showcompanyList(){
        let popoverViewController  = self.storyboard?.instantiateViewController(withIdentifier: "listvc") as! ListViewController
        popoverViewController.delegate = self
        fieldType = conetentType.compnanyType
        popoverViewController.preferredContentSize = CGSize(width: self.companyName.frame.size.width, height: 100.0)
        popoverViewController.popoverPresentationController?.permittedArrowDirections = .down
        popoverViewController.modalPresentationStyle = UIModalPresentationStyle.popover
        popoverViewController.popoverPresentationController!.delegate = self
        popoverViewController.popoverPresentationController?.sourceView = self.view
        popoverViewController.popoverPresentationController?.sourceRect = CGRect(x: self.registerScrolllView.frame.origin.x + self.companyName.frame.origin.x + 120,y: self.view.frame.origin.y + self.companyName.frame.origin.y+70,width: 0,height: 0)
        
        
        popoverViewController.listArray =  ["Trading" as AnyObject,"Trans" as AnyObject,"Management" as AnyObject]
        
        self.present(popoverViewController, animated: true, completion: nil)
        
        
    }
    func stateList(){
        
        self.stateField.errorMessage = ""
        
        let popoverViewController  = self.storyboard?.instantiateViewController(withIdentifier: "listvc") as! ListViewController
        popoverViewController.delegate = self
        fieldType = conetentType.stateType
        popoverViewController.preferredContentSize = CGSize(width: self.stateField.frame.size.width, height: 250)
        popoverViewController.modalPresentationStyle = UIModalPresentationStyle.popover
        popoverViewController.popoverPresentationController!.delegate = self
        popoverViewController.popoverPresentationController?.sourceView = self.view
        popoverViewController.popoverPresentationController?.sourceRect = CGRect(x: self.registerScrolllView.frame.origin.x + self.stateField.frame.origin.x+100,y: self.view.frame.origin.y + self.stateField.frame.origin.y-80,width: 0,height: 0)
        
        
        popoverViewController.listArray =  (self.regionArray as? [AnyObject])!
        
        self.present(popoverViewController, animated: true, completion: nil)
        
        
    }
    
    func showCityList() {
        SwiftLoader.show(title: "Loading", animated: true)
        self.getCitiesList { (success) in
            if success {
                SwiftLoader.hide()
                let popoverViewController  = self.storyboard?.instantiateViewController(withIdentifier: "listvc") as! ListViewController
                popoverViewController.delegate = self
                self.fieldType = conetentType.cityType
                popoverViewController.preferredContentSize = CGSize(width: self.cityListTextField.frame.size.width, height: 250)
                popoverViewController.modalPresentationStyle = UIModalPresentationStyle.popover
                popoverViewController.popoverPresentationController!.delegate = self
                popoverViewController.popoverPresentationController?.sourceView = self.view
                popoverViewController.popoverPresentationController?.sourceRect = CGRect(x: self.registerScrolllView.frame.origin.x + self.cityListTextField.frame.origin.x+100,y: self.view.frame.origin.y + self.cityListTextField.frame.origin.y-80,width: 0,height: 0)
                var cityArray = [String]()
                for cityListArray in self.cityListData {
                    cityArray.append(cityListArray.name!)
                }
                popoverViewController.listArray = cityArray as [AnyObject]
                
                self.present(popoverViewController, animated: true, completion: nil)
            } else {
                SwiftLoader.hide()
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
    @IBAction func showCountryList(_ sender: Any) {
        countryList()
    }
    
    @IBAction func showStateList(_ sender: Any) {
        stateList()
        
    }
    
    
    @IBAction func showCityListButtonTapped(_ sender: Any) {
    }
    
    @IBAction func comanyField(_ sender: Any) {
        showcompanyList()
    }
    
    @IBAction func employeeAction(_ sender: Any) {
        viewHeight.constant = 128.0
        mainViewHeightConstraint.constant = 780.0
        selectedusertype = "Emplyoee"
        UserDefaults.standard.set(selectedusertype,forKey:"customerType")
    }
    
    @IBAction func consumerAction(_ sender: Any) {
        viewHeight.constant = 70
        mainViewHeightConstraint.constant = 725.0
        selectedusertype = "End Consumer"
        UserDefaults.standard.set(selectedusertype,forKey:"customerType")
        companyButton.isUserInteractionEnabled = false
    }
    
    func getCountryList(){
        
        WebserviceEngine().requestforAPI(service: "customer/country", method: "GET", token: "", body: "", productBody: NSData()) { (result, error) in
            if result != nil
            {
                NSLog("Registration result \(result)")
                let countryresult = result?.value(forKey: "records") as! NSArray
                DispatchQueue.main.sync(execute: { () -> Void in
                    SwiftLoader.hide()
                })
                
                for i in 0..<countryresult.count{
                    let countryname = (countryresult[i] as AnyObject).value(forKey: "name") as! String
                    self.countryArray.add(countryname)
                    
                    let countryid = (countryresult[i] as AnyObject).value(forKey: "country_id") as! String
                    self.countryidArray.add(countryid)
                }
                
                ///if let status = countryresult?.value(forKey: "status") as? String
                //{
                //if status == "1"
                //{
                
                
                // DispatchQueue.main.sync(execute: { () -> Void in
                // SwiftLoader.hide()
                
                //})
                // }
                //else
                //{
                // DispatchQueue.main.sync(execute: { () -> Void in
                //  SwiftLoader.hide()
                // let alertController = UIAlertController(title: "Sorry!", message:
                // "\(result?.value(forKey: "message") as! String)", preferredStyle: UIAlertControllerStyle.alert)
                //alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil))
                // self.present(alertController, animated: true, completion: nil)
                //})
                //}
                
                // }
                
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
    
    func getRegionlist(selectedcountryid:String){
        
        WebserviceEngine().requestforAPI(service: "customer/city&country_id=\(selectedcountryid)", method: "GET", token: "", body: "", productBody: NSData()) { (result, error) in
            if result != nil
            {
                NSLog("ciylist \(result)")
                let countryresult = result?.value(forKey:"zone") as! NSArray
                DispatchQueue.main.sync(execute: { () -> Void in
                    SwiftLoader.hide()
                    
                })
                
                for i in 0..<countryresult.count{
                    let zonename = (countryresult[i] as AnyObject).value(forKey: "name") as! String
                    self.regionArray.add(zonename)
                    let zoneid = (countryresult[i] as AnyObject).value(forKey: "zone_id") as! String
                    self.zoneidArray.add(zoneid )
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
    
    func getCitiesList(withCompletion completion: @escaping DownloadCompletion) {
        SyncManager.syncOperation(operationType: .getCitiesBasedOnZoneId, info: self.selectedzoneid, completionHandler: { (response, error) in
            if error == nil {
                print("City Response: \(response)")
                if let cityInfo = response as? [[String: AnyObject]] {
                    self.cityListData = []
                    for city in cityInfo {
                        if let cityName = city["name"] as? String, let zoneId = city["zone_id"] as? String {
                            let cityData = CityData(withName: cityName, andZoneId: zoneId)
                            self.cityListData.append(cityData)
                        }
                    }
                }
                completion(true)
            } else {
                completion(false)
            }
        })
    }
}

//MARK:- UITextFieldDelegate
extension RegistrationViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeField = textField
        
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == employeeField
        {
            if employeeField.text?.characters.count != 0
            {
                employeeField.errorMessage =  ""
            }
            
        }
        if textField == firstName
        {
            if firstName.text?.characters.count != 0
            {
                firstName.errorMessage =  ""
            }
            
        }
        if textField == lastName
        {
            if lastName.text?.characters.count != 0
            {
                lastName.errorMessage =  ""
            }
            
        }
        if textField == address1
        {
            if address1.text?.characters.count != 0
            {
                address1.errorMessage =  ""
            }
            
        }
        /* if textField == cityField
        {
            if cityField.text?.characters.count != 0
            {
                cityField.errorMessage =  ""
            }
            
        } */
        if textField == countryField
        {
            if countryField.text?.characters.count != 0
            {
                countryField.errorMessage =  ""
            }
            
        }
        if textField == stateField
        {
            if stateField.text?.characters.count != 0
            {
                stateField.errorMessage =  ""
            }
            
        }
        
        if textField == companyName
        {
            if companyName.text?.characters.count != 0
            {
                companyName.errorMessage =  ""
            }
            
        }
        if textField ==  telephone
        {
            if (range.location == 9 && string.characters.count == 1) || (range.location == 10 && string.characters.count == 0)
            {
                telephone.errorMessage = ""
            }
            else
            {
                telephone.errorMessage =  "Enter Valid Mobile Number"
            }
        }
        else if textField ==  email
        {
            if isValidEmail( email.text!) == true
            {
                email.errorMessage = ""
            }
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // textField.resignFirstResponder()
        
        if textField.returnKeyType == .next{
            if textField == employeeField{
                employeeField.resignFirstResponder()
                companyName.becomeFirstResponder()
            }
            if textField == firstName{
                
                firstName.resignFirstResponder()
                lastName.becomeFirstResponder()
            }
            if textField == lastName{
                lastName.resignFirstResponder()
                email.becomeFirstResponder()
                
            }
            if textField ==  email{
                email.resignFirstResponder()
                telephone.becomeFirstResponder()
                
            }
            if textField == addresscompanyField{
                addresscompanyField.resignFirstResponder()
                address1.becomeFirstResponder()
            }
            if textField == address1{
                address1.resignFirstResponder()
                address2.becomeFirstResponder()
            }
            if textField == address2{
                address2.resignFirstResponder()
                pincodeField.becomeFirstResponder()
            }
            /* if textField == cityField{
                cityField.resignFirstResponder()
                pincodeField.becomeFirstResponder()
            } */
            if textField == pincodeField{
                pincodeField.resignFirstResponder()
                countryField.becomeFirstResponder()
            }
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        
        if textField == telephone
        {
            telephone.keyboardType = UIKeyboardType.numberPad
            let keyPadToolBar = UIToolbar()
            keyPadToolBar.barStyle = UIBarStyle.blackTranslucent
            keyPadToolBar.sizeToFit()
            let DoneButton = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.done, target: self, action: #selector(RegistrationViewController.dismissKeypadmobile))
            keyPadToolBar.setItems([DoneButton], animated: true)
            telephone.inputAccessoryView = keyPadToolBar
        }
        
        if textField == pincodeField
        {
            pincodeField.keyboardType = UIKeyboardType.numberPad
            let keyPadToolBar = UIToolbar()
            keyPadToolBar.barStyle = UIBarStyle.blackTranslucent
            keyPadToolBar.sizeToFit()
            let DoneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(RegistrationViewController.dismissKeypadpincode))
            keyPadToolBar.setItems([DoneButton], animated: true)
            pincodeField.inputAccessoryView = keyPadToolBar
        }
        
        if textField == employeeField
        {
            //            self.employeeField.errorMessage = ""
            //            employeeField.resignFirstResponder()
            //            if selectedusertype == "Emplyoee"{
            //                showEmployeeList()
            //            }
            //            else{
            //                employeeField.resignFirstResponder()
            //                emplyeeButton.isUserInteractionEnabled = false
            //            }
            textField.returnKeyType = .next
        }
        
        if textField == companyName{
            companyName.resignFirstResponder()
            if selectedusertype == "Emplyoee" {
                showcompanyList()
            }
            else{
                companyName.resignFirstResponder()
                companyButton.isUserInteractionEnabled = false
            }
        }
        
        if textField == firstName{
            textField.returnKeyType = .next
        }
        
        if textField == lastName{
            textField.returnKeyType = .next
        }
        
        if textField == email{
            textField.returnKeyType = .next
        }
        
        if textField == addresscompanyField {
            textField.returnKeyType = .next
        }
        if textField == address1{
            textField.returnKeyType = .next
        }
        if textField == address2{
            textField.returnKeyType = .next
        }
        /* if textField == cityField{
            textField.returnKeyType = .next
        } */
        if textField == pincodeField{
            textField.returnKeyType = .next
        }
        if textField == countryField{
            self.countryField.errorMessage = ""
            
            countryField.resignFirstResponder()
            countryList()
        }
        if textField == stateField {
            self.stateField.errorMessage = ""
            
            stateField.resignFirstResponder()
            stateList()
        }
        
        if textField == cityListTextField {
            self.cityListTextField.errorMessage = ""
            cityListTextField.resignFirstResponder()
            
            showCityList()
        }
    }
    
    // keyboard Handling
    func dismissKeypadmobile()
    {
        self.addresscompanyField.becomeFirstResponder()
        self.telephone.resignFirstResponder()
    }
    
    func dismissKeypadpincode()
    {
        self.pincodeField.resignFirstResponder()
    }
}

extension RegistrationViewController  {
    
    func initialSetup() {
        //self.downloadCountruList()
        self.viewHeight.constant = 70
        self.addNotificationObservers()
        self.initialUISetup()
//        self.testdata()
    }
    
    func addNotificationObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(RegistrationViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RegistrationViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    /*  func downloadCountruList() {
     
     SwiftLoader.show(title: "Loading", animated: true)
     DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
     self.getCountryList()
     }
     }*/
    
    func initialUISetup() {
        
        employeeField.delegate = self
        companyName.delegate = self
        firstName.delegate  = self
        lastName.delegate = self
        email.delegate = self
        telephone.delegate = self
        addresscompanyField.delegate = self
        address2.delegate = self
        address1.delegate = self
        //cityField.delegate = self
        pincodeField.delegate = self
        countryField.delegate = self
        stateField.delegate = self
        cityListTextField.delegate = self
    }
}

//MARK:- Helper Methods:
extension RegistrationViewController {
    
    func testdata(){
        
        employeeField.text = "manager"
        companyName.text = "hss"
        firstName.text = "shilpa"
        lastName.text = "shree"
        email.text = "shilpa@hardwin.com"
        telephone.text = "1234567890"
        addresscompanyField.text = "aaaaaaaaaaa"
        address2.text = ""
        address1.text = "sssssssssss"
        //cityField.text = "banga"
        pincodeField.text = "560093"
        //countryField.text = "india"
        // stateField.text = "kar"
    }
    
    func keyboardWillShow(_ notification:Notification)
    {
        adjustingHeight(true, notification: notification)
    }
    
    func keyboardWillHide(_ notification:Notification)
    {
        self.registerScrolllView.contentInset = UIEdgeInsets.zero
        self.registerScrolllView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
    
    func selectedList(_ listValue: NSString,selectedrow:Int) {
        switch fieldType! {
        case .countryType :
            self.countryField.text = listValue as String
            self.selectedcountryID = self.countryidArray[selectedrow] as! String
            SwiftLoader.show(title: "Loading", animated: true)
            
            self.getRegionlist(selectedcountryid:self.selectedcountryID)
            self.stateField.text = NSLocalizedString("Region / State", comment: "")
            break
            
        case .stateType:
            self.stateField.text = listValue as String
            self.selectedzoneid = self.zoneidArray[selectedrow] as! String
            self.cityListTextField.text = NSLocalizedString("SELECT_CITY_MSG", comment: "")
            //self.getCityList(ofStateId stateId: self.selectedzoneid)
            break
            
        case .compnanyType:
            companyName.text = listValue as String
        case .employeeType:
            //self.employeeField.text = listValue as String
            break
            
        case .cityType:
            self.cityListTextField.text = self.cityListData[selectedrow].name
        }
    }
    
    func adjustingHeight(_ show:Bool, notification:Notification) {
        
        self.registerScrolllView.isScrollEnabled = true
        let info : NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        var height:CGFloat = 0
        
        if activeField is UITextView
        {
            height = CGFloat(Constants.resizeWithToolbar)
        }
        else if activeField is  UITextField
        {
            height = CGFloat(Constants.resizeWithoutToolbar)
        }
        
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height + height, 0.0)
        
        self.registerScrolllView.contentInset = contentInsets
        self.registerScrolllView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.signupView.frame
        aRect.size.height -= (keyboardSize!.height + height)
        if let activeFieldPresent = activeField
        {
            if (!aRect.contains(activeFieldPresent.frame.origin))
            {
                self.registerScrolllView.scrollRectToVisible(activeFieldPresent.frame, animated: true)
            }
        }
    }
}


