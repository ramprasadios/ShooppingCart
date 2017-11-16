//
//  AddressViewController.swift
//  Alzahrani
//
//  Created by shilpa shree on 5/26/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit
enum adressType{
    case countryType
    case stateType
    case cityType
}

class AddressViewController: UIViewController,UIPopoverPresentationControllerDelegate,UIPopoverControllerDelegate {
    //MARK:- IBOutlets
	
    @IBOutlet weak var countryTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var cityTextField: SkyFloatingLabelTextField!
    @IBOutlet var addressScrollView: UIScrollView!
    @IBOutlet var stateTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var companyTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var address1TextField: SkyFloatingLabelTextField!
    @IBOutlet weak var address2TextField: SkyFloatingLabelTextField!
    @IBOutlet weak var postalTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var addressView: UIView!
    
    //MARK:- Properties
    class var isUserLoggedIn: Bool {
        return UserDefaultManager.sharedManager().isUserAuthenticated()
    }
    var fieldType:adressType!
    var firstname = ""
    var lastname = ""
    var activeField :AnyObject?
    var countryArray = NSMutableArray()
    var countryidArray = NSMutableArray()
    var regionArray = NSMutableArray()
    var zoneidArray = NSMutableArray()
    var cityListData = [CityData]()
     var selectedcountryID = ""
     var selectedZoneID  = ""
    var company = ""
    var address1 = ""
    var address2 = ""
    var city = ""
    var state = ""
    var country = ""
    var pincode = ""
    var addressid = ""
    
    
    //@Mark:- LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetUp()
        self.updateUIElementText()
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            self.getCountryList()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    func initialSetUp(){
        self.title = NSLocalizedString("UPDATE_ADDRESS_INFO", comment: "")
        addPadding()
       address1TextField.delegate = self
        address2TextField.delegate = self
        stateTextField.delegate = self
        postalTextField.delegate = self
        cityTextField.delegate = self
        countryTextField.delegate = self
        companyTextField.delegate = self
     //addNotificationObservers()
        
        if(AddressViewController.isUserLoggedIn == true){
        address1TextField.text = self.address1
        address2TextField.text = address2
        companyTextField.text = company
        stateTextField.text = state
        cityTextField.text = city
        countryTextField.text = self.country
        postalTextField.text = self.pincode
        } else {
            address1TextField.text = ""; address2TextField.text = ""; companyTextField.text = ""; stateTextField.text = "";  cityTextField.text = ""; countryTextField.text = ""; postalTextField.text = ""
        }
    }
    
    func animateViewMoving (_ up:Bool, moveValue :CGFloat){
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = self.view.frame.offsetBy(dx: 0,  dy: movement)
        UIView.commitAnimations()
    }
    
    @IBAction func updateAction(_ sender: Any) {
        var errorMessage = ""
        if address1TextField.text?.characters.count == 0
        {
			errorMessage = NSLocalizedString("INVALID_ADDRESS_ERROR", comment: "")
            address1TextField.errorMessage = errorMessage
        }
        /* else if (address1TextField.text?.characters.count)! < 10
        {
			errorMessage = NSLocalizedString("INVALID_ADDRESS_ERROR", comment: "")
           address1TextField.errorMessage = errorMessage
        } */
        else if (cityTextField.text?.characters.count)! == 0
        {
			errorMessage = NSLocalizedString("INVALID_CITY_ERROR", comment: "")
            cityTextField.errorMessage = errorMessage
        }
        else if (countryTextField.text?.characters.count)! == 0
        {
			errorMessage = NSLocalizedString("INVALID_COUNTRY_ERROR", comment: "")
           countryTextField.errorMessage = errorMessage
        }
            
        else if (stateTextField.text?.characters.count)! == 0
        {
			errorMessage = NSLocalizedString("INVALID_STATE_ERROR", comment: "")
            stateTextField.errorMessage = errorMessage
        }
             else{
//        ProgressIndicatorController.showLoading()
                updateAddressAction()
        }

        
    }
    func addNotificationObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(AddressViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AddressViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

   
    func addPadding()
    {
        let dropDown = self.resizeImageForPadding(UIImage(named:"downArrow1")!,dropDown: true)
        let sortButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        sortButton.setImage(dropDown, for: UIControlState())
        sortButton.addTarget(self, action: #selector(AddressViewController.showCountryList), for: UIControlEvents.touchUpInside)
         countryTextField.rightView =  sortButton
        countryTextField.rightViewMode = UITextFieldViewMode.always
        
        let dropDown1 = self.resizeImageForPadding(UIImage(named:"downArrow1")!,dropDown: true)
        let sortButton1 = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        sortButton1.setImage(dropDown1, for: UIControlState())
        sortButton1.addTarget(self, action: #selector(AddressViewController.loadRegionStateList), for: UIControlEvents.touchUpInside)
       stateTextField.rightView =  sortButton1
        stateTextField.rightViewMode = UITextFieldViewMode.always
        
        let dropDown2 = self.resizeImageForPadding(UIImage(named:"downArrow1")!,dropDown: true)
        let sortButton2 = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        sortButton1.setImage(dropDown2, for: UIControlState())
        sortButton1.addTarget(self, action: #selector(AddressViewController.loadCitiesList), for: UIControlEvents.touchUpInside)
        cityTextField.rightView =  sortButton2
        cityTextField.rightViewMode = UITextFieldViewMode.always
    }
    
    func loadRegionStateList() {
        self.getRegionlist(selectedcountryid: self.selectedcountryID)
    }
    
    func loadCitiesList() {
        self.showCityList()
    }
    
    func showCountryList(){
        self.countryTextField.errorMessage = ""
        let popoverViewController  = self.storyboard?.instantiateViewController(withIdentifier: "listvc") as! ListViewController
        popoverViewController.delegate = self
        fieldType = adressType.countryType
        popoverViewController.preferredContentSize = CGSize(width: self.countryTextField.frame.size.width, height: 150)
        popoverViewController.modalPresentationStyle = UIModalPresentationStyle.popover
        popoverViewController.popoverPresentationController!.delegate = self
        popoverViewController.popoverPresentationController?.sourceView = self.view
        popoverViewController.popoverPresentationController?.sourceRect = CGRect(x: self.addressScrollView.frame.origin.x + self.countryTextField.frame.origin.x, y: self.view.frame.origin.y + self.countryTextField.frame.origin.y,width: 0,height: 0)
        
        
        popoverViewController.listArray = self.countryArray as [AnyObject]
            self.present(popoverViewController, animated: true, completion: nil)

    }
    
    func showStateRegionList(){
        self.stateTextField.errorMessage = ""
        let popoverViewController  = self.storyboard?.instantiateViewController(withIdentifier: "listvc") as! ListViewController
        popoverViewController.delegate = self
       fieldType = adressType.stateType
        popoverViewController.preferredContentSize = CGSize(width: self.stateTextField.frame.size.width, height: 150)
        popoverViewController.modalPresentationStyle = UIModalPresentationStyle.popover
        popoverViewController.popoverPresentationController!.delegate = self
        popoverViewController.popoverPresentationController?.sourceView = self.view
        popoverViewController.popoverPresentationController?.sourceRect = CGRect(x: self.addressScrollView.frame.origin.x + self.stateTextField.frame.origin.x,y: self.view.frame.origin.y + self.stateTextField.frame.origin.y,width: 0,height: 0)
        
        
        popoverViewController.listArray =  self.regionArray as [AnyObject]
        self.present(popoverViewController, animated: true, completion: nil)

        
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
    return .none
    }
    
    func resizeImageForPadding(_ resizeImage:UIImage, dropDown:Bool) -> UIImage
    {
        
        
        if dropDown == true
        {
            UIGraphicsBeginImageContext(CGSize(width: 16, height: 16))
            resizeImage.draw(in: CGRect(x: 4, y: 4, width: 8, height: 8))
        }
        else
        {
            UIGraphicsBeginImageContext(CGSize(width: 20, height: 20))
            resizeImage.draw(in: CGRect(x: 4, y: 4, width: 12, height: 12))
        }
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage!
        
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */



    func keyboardWillShow(_ notification:Notification)
    {
        adjustingHeight(true, notification: notification)
    }
    
    func keyboardWillHide(_ notification:Notification)
    {
      addressScrollView.contentInset = UIEdgeInsets.zero
       addressScrollView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
    
    
    func adjustingHeight(_ show:Bool, notification:Notification) {
        
        self.addressScrollView.isScrollEnabled = true
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
        
        self.addressScrollView.contentInset = contentInsets
        self.addressScrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.addressView.frame
        aRect.size.height -= (keyboardSize!.height + height)
        if let activeFieldPresent = activeField
        {
            if (!aRect.contains(activeFieldPresent.frame.origin))
            {
                addressScrollView.scrollRectToVisible(activeFieldPresent.frame, animated: true)
            }
        }
    }

    func getCountryList(){
        
        WebserviceEngine().requestforAPI(service: "customer/country", method: "GET", token: "", body: "", productBody: NSData()) { (result, error) in
            if result != nil
            {
                NSLog("Registration result \(result)")
                let countryresult = result?.value(forKey: "records") as! NSArray
                
                
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
                  
                        let alertController = UIAlertController(title: Constants.alertTitle, message:
                            "internet too slow", preferredStyle: UIAlertControllerStyle.alert)
						let okTitle = NSLocalizedString("OK", comment: "")
                        alertController.addAction(UIAlertAction(title: okTitle, style: UIAlertActionStyle.default,handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                    })
                }
                if (error!.value(forKey: "code") as! NSNumber).stringValue == "-1009"
                {
                    DispatchQueue.main.sync(execute: { () -> Void in
                       
                        let alertController = UIAlertController(title: Constants.alertTitle, message:
                            "check your internet connection", preferredStyle: UIAlertControllerStyle.alert)
						let okTitle = NSLocalizedString("OK", comment: "")
                        alertController.addAction(UIAlertAction(title: okTitle, style: UIAlertActionStyle.default,handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                        
                    })
                }
            }
        }
    }
    
    func updateUIElementText() {
        self.companyTextField.placeholder = NSLocalizedString("Company", comment: "")
        self.address1TextField.placeholder = NSLocalizedString("Address 1", comment: "")
        self.address2TextField.placeholder = NSLocalizedString("Address 2", comment: "")
        self.postalTextField.placeholder = NSLocalizedString("Postal Code", comment: "")
        self.countryTextField.placeholder = NSLocalizedString("Country", comment: "")
        self.stateTextField.placeholder = NSLocalizedString("Region / State", comment: "")
        self.cityTextField.placeholder = NSLocalizedString("City", comment: "")
    }
    
    func updateAddressAction(){
		let langId = (AppManager.languageType() == .english) ? "1" : "2"
        if let customer_id = UserDefaultManager.sharedManager().loginUserId {
            let param = "firstname=\(self.firstname)&lastname=\(self.lastname)&company=\(companyTextField.text!)&address_1=\(address1TextField.text!)&address_2=\(address2TextField.text!)&city=\(cityTextField.text!)&postcode=\(postalTextField.text!)&country_id=\(selectedcountryID)&zone_id=\(selectedZoneID)&customer_id=\(customer_id)&address_id=\(self.addressid)&language_id=\(langId)"
            
            
            WebserviceEngine().requestforAPI(service: "customer/editAddressList", method: "POST", token: "", body:param, productBody: NSData()) { (result, error) in
                if result != nil
                {
                    NSLog("reviewlist \(result)")
                    
                    DispatchQueue.main.async {
                        if let successResponse = result as? [String: AnyObject] {
                            if let successMessage = successResponse["success"] as? String {
                                let alertController = UIAlertController(title: NSLocalizedString(Constants.alertTitle, comment: ""), message:
                                    successMessage, preferredStyle: UIAlertControllerStyle.alert)
								let okTitle = NSLocalizedString("OK", comment: "")
                                alertController.addAction(UIAlertAction(title: okTitle, style: UIAlertActionStyle.default,handler: {
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
                    {
//                        ProgressIndicatorController.dismissProgressView()
                        DispatchQueue.main.sync(execute: { () -> Void in
                            
                            let alertController = UIAlertController(title: Constants.alertTitle, message:
                                "internet too slow", preferredStyle: UIAlertControllerStyle.alert)
							let okTitle = NSLocalizedString("OK", comment: "")
                            alertController.addAction(UIAlertAction(title: okTitle, style: UIAlertActionStyle.default,handler: nil))
                            self.present(alertController, animated: true, completion: nil)
                        })
                    }
                    if (error!.value(forKey: "code") as! NSNumber).stringValue == "-1009"
                    {
//                ProgressIndicatorController.dismissProgressView()
                        DispatchQueue.main.sync(execute: { () -> Void in
                            
                            let alertController = UIAlertController(title: Constants.alertTitle, message:
                                "check your internet connection", preferredStyle: UIAlertControllerStyle.alert)
							let okTitle = NSLocalizedString("OK", comment: "")
                            alertController.addAction(UIAlertAction(title: okTitle, style: UIAlertActionStyle.default,handler: nil))
                            self.present(alertController, animated: true, completion: nil)
                            
                        })
                    }
                }
            }
        }
        
        
    }

    func getRegionlist(selectedcountryid:String){
        ProgressIndicatorController.showLoading()
        WebserviceEngine().requestforAPI(service: "customer/city&country_id=\(selectedcountryid)", method: "GET", token: "", body: "", productBody: NSData()) { (result, error) in
            if result != nil
            {
                ProgressIndicatorController.dismissProgressView()
                NSLog("ciylist \(result)")
//                ProgressIndicatorController.dismissProgressView()
                let countryresult = result?.value(forKey:"zone") as! NSArray
                DispatchQueue.main.sync(execute: { () -> Void in
                    
                    
                })
                
                for i in 0..<countryresult.count{
                    let zonename = (countryresult[i] as AnyObject).value(forKey: "name") as! String
                    self.regionArray.add(zonename)
                    let zoneid = (countryresult[i] as AnyObject).value(forKey: "zone_id") as! String
                    self.zoneidArray.add(zoneid)
                }
                self.showStateRegionList()
            }
            else
            {
                ProgressIndicatorController.dismissProgressView()
                if (error!.value(forKey: "code") as! NSNumber).stringValue == "-1001"
                {
//                    ProgressIndicatorController.dismissProgressView()
                    DispatchQueue.main.sync(execute: { () -> Void in
                       
                        let alertController = UIAlertController(title: Constants.alertTitle, message:
                            "internet too slow", preferredStyle: UIAlertControllerStyle.alert)
						let okTitle = NSLocalizedString("OK", comment: "")
                        alertController.addAction(UIAlertAction(title: okTitle, style: UIAlertActionStyle.default,handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                    })
                }
                if (error!.value(forKey: "code") as! NSNumber).stringValue == "-1009"
                {
//                    ProgressIndicatorController.dismissProgressView()
                    DispatchQueue.main.sync(execute: { () -> Void in
                    
                        let alertController = UIAlertController(title: Constants.alertTitle, message:
                            "check your internet connection", preferredStyle: UIAlertControllerStyle.alert)
						let okTitle = NSLocalizedString("OK", comment: "")
                        alertController.addAction(UIAlertAction(title: okTitle, style: UIAlertActionStyle.default,handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                        
                    })
                }
            }
        }
    }
}

extension AddressViewController:listDelegate{
    func selectedList(_ listValue: NSString,selectedrow:Int){
    switch fieldType!
    {
    case .countryType:
        self.countryTextField.text = listValue as String
        self.selectedcountryID = self.countryidArray[selectedrow] as! String
    //ProgressIndicatorController.showLoading()
        self.getRegionlist(selectedcountryid:self.selectedcountryID)
        self.stateTextField.text = "Please Select State / Region"
        self.cityTextField.text = "Please Select City"
        break
    case .stateType:
        self.stateTextField.text = listValue as String
        self.selectedZoneID = zoneidArray[selectedrow] as! String
        self.addressid = zoneidArray[selectedrow] as! String
        self.cityTextField.text = "Please Select City"
        break
        
    case .cityType:
        self.cityTextField.text = listValue as String
        }
    }
    
    
}
extension AddressViewController:UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeField = textField
        
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
               if textField == address1TextField
        {
            if  address1TextField.text?.characters.count != 0
            {
                 address1TextField.errorMessage =  ""
            }
            
        }
//        if textField == address2TextField
//        {
//            if  address2TextField.text?.characters.count != 0
//            {
//                address2TextField.errorMessage =  ""
//            }
//        }
//        if textField == postalTextField
//        {
//            if  postalTextField.text?.characters.count != 0 || postalTextField.text?.characters.count < 6
//            {
//                postalTextField.errorMessage =  ""
//            }
//        }

        if textField == cityTextField
        {
            if cityTextField.text?.characters.count != 0
            {
                cityTextField.errorMessage =  ""
            }
            
        }
        if textField == countryTextField
        {
            if countryTextField.text?.characters.count != 0
            {
                countryTextField.errorMessage =  ""
            }
            
        }
        if textField == stateTextField
        {
            if stateTextField.text?.characters.count != 0
            {
                stateTextField.errorMessage =  ""
            }
            
        }
        
//        if textField == companyTextField
//        {
//            if companyTextField.text?.characters.count != 0
//            {
//                companyTextField.errorMessage =  ""
//            }
//            
//        }

        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // textField.resignFirstResponder()
        
        if textField.returnKeyType == .next{
            if textField ==  companyTextField{
                companyTextField.resignFirstResponder()
                address1TextField.becomeFirstResponder()
            }
            
            if textField == address1TextField{
               address1TextField.resignFirstResponder()
               address2TextField.becomeFirstResponder()
            }
            if textField == address2TextField {
                address2TextField.resignFirstResponder()
               postalTextField.becomeFirstResponder()
            }
            if textField == cityTextField{
                cityTextField.resignFirstResponder()
               //postalTextField.becomeFirstResponder()
            }
            if textField == postalTextField{
                postalTextField.resignFirstResponder()
                countryTextField.becomeFirstResponder()
            }
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {

        if textField == postalTextField
        {
           postalTextField.keyboardType = UIKeyboardType.numberPad
            let keyPadToolBar = UIToolbar()
            keyPadToolBar.barStyle = UIBarStyle.blackTranslucent
            keyPadToolBar.sizeToFit()
            let DoneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(AddressViewController.dismissKeypadpincode))
            keyPadToolBar.setItems([DoneButton], animated: true)
            postalTextField.inputAccessoryView = keyPadToolBar
        }
        
        if textField == companyTextField{
          textField.returnKeyType = .next
        }

        if textField == address1TextField{
            textField.returnKeyType = .next
        }
        if textField == address2TextField{
            textField.returnKeyType = .next
            //animateViewMoving (true, moveValue :40)
        }
        /* if textField == cityTextField {
            textField.returnKeyType = .next
             animateViewMoving (true, moveValue :60)
        } */
        if textField == postalTextField{
            textField.returnKeyType = .next
             //animateViewMoving (true, moveValue :60)
        }
        if textField == countryTextField{
            self.countryTextField.errorMessage = ""
            
            countryTextField.resignFirstResponder()
            showCountryList()
        }
        if textField == stateTextField {
            self.stateTextField.errorMessage = ""
            
           stateTextField.resignFirstResponder()
           self.getRegionlist(selectedcountryid: self.selectedcountryID)
        }
        
        if textField == cityTextField {
            self.cityTextField.errorMessage = ""
            
            cityTextField.resignFirstResponder()
            self.showCityList()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == address2TextField{
         
            //animateViewMoving (false, moveValue :40)
        }
        if textField == cityTextField{
           
            //animateViewMoving (false, moveValue :60)
        }
        if textField == postalTextField{
        
            //animateViewMoving (false, moveValue :80)
        }

    }
    
    // keyboard Handling
   
    
    func dismissKeypadpincode()
    { //animateViewMoving (false, moveValue :60)
        self.postalTextField.resignFirstResponder()
    }
}

extension AddressViewController {
    
    func getCitiesList(withCompletion completion: DownloadCompletion? = nil) {
        SyncManager.syncOperation(operationType: .getCitiesBasedOnZoneId, info: self.selectedZoneID, completionHandler: { (response, error) in
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
                completion?(true)
            } else {
                completion?(false)
            }
        })
    }
    
    func showCityList() {
        SwiftLoader.show(title: "Loading", animated: true)
        self.getCitiesList { (success) in
            if success {
                SwiftLoader.hide()
                let popoverViewController  = self.storyboard?.instantiateViewController(withIdentifier: "listvc") as! ListViewController
                popoverViewController.delegate = self
                self.fieldType = adressType.cityType
                popoverViewController.preferredContentSize = CGSize(width: self.cityTextField.frame.size.width, height: 250)
                popoverViewController.modalPresentationStyle = UIModalPresentationStyle.popover
                popoverViewController.popoverPresentationController!.delegate = self
                popoverViewController.popoverPresentationController?.sourceView = self.view
                popoverViewController.popoverPresentationController?.sourceRect = CGRect(x: self.cityTextField.frame.origin.x + self.cityTextField.frame.origin.x,y: self.view.frame.origin.y + self.cityTextField.frame.origin.y, width: 0,height: 0)
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
}
