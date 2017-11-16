//
//  ContactNewViewController.swift
//  Alzahrani
//
//  Created by shilpa shree on 6/9/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class ContactNewViewController: UIViewController {

    @IBOutlet weak var contactTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetUp()
        print(MyCart.removeProduct(withId: "3668"))
        // Do any additional setup after loading the view.
    }
    func initialSetUp(){
        contactTableView.delegate = self
        contactTableView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submitAction(_ sender: Any) {
        let cell = self.contactTableView.cellForRow(at: IndexPath.init(row:1,section:0)) as! ContactFormTableViewCell
       
       
        if cell.nameField.text?.characters.count == 0
        {
            cell.nameField.errorMessage = "Name is required"
        }
        else if (cell.emailField.text?.characters.count) == 0 || isValidEmail(cell.emailField.text!) == false
        {
            cell.emailField.errorMessage = "Enter Valid Email ID"
        }
         else if (cell.textView.text.characters.count) == 0{
            let alertController = UIAlertController(title: Constants.alertTitle, message:
                "Please enter Your Query", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
         }
         else if (cell.textView.text.characters.count<10) || (cell.textView.text.characters.count>3000){
            let alertController = UIAlertController(title: Constants.alertTitle, message:
                "Query should be in between 10 to 3000 characters", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
         }

        
        else{
            ProgressIndicatorController.showLoading()
            sendQueryAction()
        }
        
    }
	
	
	@IBAction func whatsappButtonTap(_ sender: Any) {
		if let url = URL(string: "https://api.whatsapp.com/send?phone=0539105080") {
			UIApplication.shared.open(url, options: [:], completionHandler: nil)
		}
	}
    
    @IBAction func menuButtonTapped(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name(Constants.hambergerTappedNotification), object: nil)
    }
    
    func sendQueryAction(){
        let cell = contactTableView.cellForRow(at: IndexPath.init(row:1,section:0)) as! ContactFormTableViewCell
         ProgressIndicatorController.dismissProgressView()
        
        let param = "name=\(cell.nameField.text!)&email=\(cell.emailField.text!)&enquiry=\(cell.textView.text!)"
       
            WebserviceEngine().requestforAPI(service: "customer/contactUs", method: "POST", token: "", body: param, productBody: NSData()) { (result, error) in
                if result != nil
                {
                
                    NSLog("reviewlist \(result)")
                    DispatchQueue.main.sync(execute: { () -> Void in
                        if let response = result as? [String:Any]{
                            if  let responsemessage = response["success"] as? String{
                                let alertController = UIAlertController(title: Constants.alertTitle, message:
                                   responsemessage, preferredStyle: UIAlertControllerStyle.alert)
                                alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: {
                                    (UIAlertAction) in
                                    NotificationCenter.default.post(name: Notification.Name(Constants.sliderMenuFieldTapNotification), object: nil, userInfo: nil)
                                }))
                                self.present(alertController, animated: true, completion: nil)
 
                            }
                        }
                        
                    })
                }
                else
                {
                    if (error!.value(forKey: "code") as! NSNumber).stringValue == "-1001"
                    {
                        DispatchQueue.main.sync(execute: { () -> Void in
                          
                            let alertController = UIAlertController(title: Constants.alertTitle, message:
                                "internet too slow", preferredStyle: UIAlertControllerStyle.alert)
                            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil))
                            self.present(alertController, animated: true, completion: nil)
                        })
                    }
                    if (error!.value(forKey: "code") as! NSNumber).stringValue == "-1009"
                    {
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
    func isValidEmail(_ testStr:String) -> Bool {
        
        let emailRegEx = "^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: testStr)
        
        return result
    }
    

extension ContactNewViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.row == 0 {
			if UIDevice.current.userInterfaceIdiom == .pad {
				return 220.0
			} else {
				return 155
			}
        } else {
			if UIDevice.current.userInterfaceIdiom == .pad {
				return 400.0
			} else {
				return 350
			}
        }
    }
}
extension ContactNewViewController:UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactAddressTableViewCell", for: indexPath) as! ContactAddressTableViewCell
            
            cell.toolFreeNumberLabel.text = NSLocalizedString("TOLL_FREE_NUMBER", comment: "")
            cell.whatsappNumberLabel.text = NSLocalizedString("WHATSAPP_NUMBER", comment: "")
            return cell
        }
       else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ContactFormTableViewCell", for: indexPath) as! ContactFormTableViewCell
            cell.textView.layer.borderColor = UIColor.lightGray.cgColor
            cell.textView.layer.borderWidth = 1
            cell.nameField.delegate = self
            cell.emailField.delegate = self
            cell.textView.delegate = self
            cell.textView.text = NSLocalizedString("WRITE_YOUR_ENQUIRY", comment: "")
			if UIDevice.current.userInterfaceIdiom == .pad {
				cell.textView.font = UIFont.systemFont(ofSize: 24.0)
			} else {
				cell.textView.font = UIFont.systemFont(ofSize: 14.0)
			}
            cell.textView.textColor = UIColor.lightGray
            return cell
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


}
extension ContactNewViewController:UITextFieldDelegate{
   

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
         let cell = contactTableView.cellForRow(at:IndexPath.init(row:1, section: 0)) as!  ContactFormTableViewCell
        if textField.returnKeyType == .next{
            cell.nameField.resignFirstResponder()
            cell.emailField.becomeFirstResponder()
        }
        if textField.returnKeyType == .done{
           cell.emailField.resignFirstResponder()
        
        }
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
         let cell = contactTableView.cellForRow(at:IndexPath.init(row:1, section: 0)) as!  ContactFormTableViewCell
        if textField ==  cell.nameField
        {
            //animateViewMoving (true, moveValue :80)
            textField.returnKeyType = .next
        }
        if textField == cell.emailField
        {
            textField.returnKeyType = .done
            //animateViewMoving (true, moveValue :120)

        }
    }
   
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        let cell = contactTableView.cellForRow(at:IndexPath.init(row:1, section: 0)) as!  ContactFormTableViewCell
        if textField ==  cell.nameField
        {
            //animateViewMoving (false, moveValue :80)
            
        }
        if textField == cell.emailField
        {
            //animateViewMoving (false, moveValue :120)
        }

    }
    
}
extension ContactNewViewController:UITextViewDelegate{
//    func textViewDidBeginEditing(_ textView: UITextView) {
//      
//            textView.returnKeyType = .done
//        animateViewMoving (true, moveValue :160)
//
//        
//    }
//    func textViewDidEndEditing(_ textView: UITextView) {
//        
//        
//        animateViewMoving( false, moveValue: 160)
//        
//        
//    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
        textView.returnKeyType = .done
        
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        //animateViewMoving (true, moveValue :180)
            textView.returnKeyType = .done
            return true
        
       
    }
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        //animateViewMoving (false, moveValue :180)
        
        return true
        
        
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}

