//
//  OrderReturnViewController.swift
//  Alzahrani
//
//  Created by shilpa shree on 5/29/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit
enum orderType{
    
    case packageType
    case reasonType
    
}



class OrderReturnViewController: UIViewController,UIPopoverPresentationControllerDelegate,UIPopoverControllerDelegate {
//@Mark:- IBOutlets
    @IBOutlet weak var reasonTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var orderTextView: UITextView!
    
    @IBOutlet weak var orderScrollView: UIScrollView!
    @IBOutlet weak var packageOpenedTextField: SkyFloatingLabelTextField!
    
    @IBOutlet weak var productNameTextField: SkyFloatingLabelTextField!
    
    @IBOutlet weak var paymentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var quantityTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var orderView: UIView!
    
    @IBOutlet weak var firstView: UIView!
    
    @IBOutlet weak var orderidLabel: UILabel!
    
    @IBOutlet weak var checkbox: CheckBox!
    @IBOutlet weak var shippingLabel: UILabel!
    @IBOutlet weak var productNameLabel: UILabel!
    //@Mark- Properties
 var fieldType:orderType!
    var checked = true
    var activeField:AnyObject!
    var oederid = ""
    var firstname = ""
    var lastname = ""
    var email = ""
    var mobile = ""
    var customer_id = ""
    var model = ""
    var customergroupid = ""
var productName = ""
    var orderid = ""
    var quantity = ""
    var payment = ""
    var date = ""
    var shipping = ""
    var returnid = ""
    var opened = ""
    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubLayers()
        addPadding()
        initialSetUp()

        // Do any additional setup after loading the view.
    }
    func initialSetUp(){
        getPersonalDetails()
        self.checkbox.delegate = self
        self.dateLabel.text = self.date
        self.shippingLabel.text = self.shipping
        self.paymentLabel.text = self.payment
        self.orderidLabel.text = self.orderid
        self.reasonTextField.delegate =  self
        //self.packageOpenedTextField.delegate = self
        self.quantityTextField.delegate = self
       // self.productNameTextField.delegate = self
        orderTextView.delegate = self
        addNotificationObservers()
        self.productNameLabel.text =  self.productName
        self.quantityTextField.text = self.quantity
    }
    
    func addSubLayers(){
        let layer2 = CALayer()
        layer2.frame = CGRect(x:0,y:productNameLabel.frame.size.height - 1,width:productNameLabel.frame.size.width,height:1)
        layer2.backgroundColor = UIColor.gray.cgColor
       productNameLabel.layer.addSublayer(layer2)
        let layer1 = CALayer()
     layer1.frame = CGRect(x:0,y:orderTextView.frame.size.height - 1,width:orderTextView.frame.size.width,height:1)
        layer1.backgroundColor = UIColor.gray.cgColor
       
        layer1.shadowColor = UIColor.gray.cgColor
       layer1.shadowOpacity = 1
      layer1.shadowOffset = CGSize.init(width: 3, height: 4)
       layer1.shadowRadius = 10
        layer1.shadowPath = UIBezierPath(rect: layer1.bounds).cgPath
        
         orderTextView.layer.addSublayer(layer1)
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    func addPadding()
    {
        
        
        let dropDown = self.resizeImageForPadding(UIImage(named:"downArrow1")!,dropDown: true)
        let sortButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        sortButton.setImage(dropDown, for: UIControlState())
        sortButton.addTarget(self, action: #selector(OrderReturnViewController.showReasonList), for: UIControlEvents.touchUpInside)
       reasonTextField.rightView =  sortButton
       reasonTextField.rightViewMode = UITextFieldViewMode.always
        
        let dropDown1 = self.resizeImageForPadding(UIImage(named:"downArrow1")!,dropDown: true)
        let sortButton1 = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        sortButton1.setImage(dropDown1, for: UIControlState())
        sortButton1.addTarget(self, action: #selector(OrderReturnViewController.showPackageList), for: UIControlEvents.touchUpInside)
       packageOpenedTextField.rightView =  sortButton1
        packageOpenedTextField.rightViewMode = UITextFieldViewMode.always
        
        
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    func addNotificationObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(OrderReturnViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(OrderReturnViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    func keyboardWillShow(_ notification:Notification)
    {
        adjustingHeight(true, notification: notification)
    }
    
    func keyboardWillHide(_ notification:Notification)
    {
        orderScrollView.contentInset = UIEdgeInsets.zero
      orderScrollView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
    
    
    func adjustingHeight(_ show:Bool, notification:Notification) {
        
        self.orderScrollView.isScrollEnabled = true
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
        
        self.orderScrollView.contentInset = contentInsets
        self.orderScrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= (keyboardSize!.height + height)
        let fieldOrigin = CGPoint(x:0,y:0)
        if let activeFieldPresent = activeField
        {
            if (!aRect.contains(fieldOrigin))
            {
                orderScrollView.scrollRectToVisible(activeFieldPresent.frame, animated: true)
            }
        }
    }

    func showReasonList(){
        
        let popoverViewController  = self.storyboard?.instantiateViewController(withIdentifier: "listvc") as! ListViewController
        popoverViewController.delegate = self
        fieldType = orderType.reasonType
        popoverViewController.preferredContentSize = CGSize(width: self.reasonTextField.frame.size.width+100, height: 150)
        popoverViewController.modalPresentationStyle = UIModalPresentationStyle.popover
        popoverViewController.popoverPresentationController!.delegate = self
        popoverViewController.popoverPresentationController?.sourceView = self.view
        popoverViewController.popoverPresentationController?.sourceRect = CGRect(x: self.orderScrollView.frame.origin.x + self.reasonTextField.frame.origin.x+120,y: self.view.frame.origin.y + self.reasonTextField.frame.origin.y+60,width: 0,height: 0)
        
        
        popoverViewController.listArray =  ["Dead On Arrival" as AnyObject,"Faulty" as AnyObject,"Order Error" as AnyObject, "Other" as AnyObject,"Recieved wrong item" as AnyObject]
        
        self.present(popoverViewController, animated: true, completion: nil)
        
    }
    func showPackageList(){
        
        let popoverViewController  = self.storyboard?.instantiateViewController(withIdentifier: "listvc") as! ListViewController
        popoverViewController.delegate = self
          fieldType = orderType.packageType
        popoverViewController.preferredContentSize = CGSize(width: packageOpenedTextField.frame.size.width, height: 60)
        popoverViewController.modalPresentationStyle = UIModalPresentationStyle.popover
        popoverViewController.popoverPresentationController!.delegate = self
        popoverViewController.popoverPresentationController?.sourceView = self.view
        popoverViewController.popoverPresentationController?.sourceRect = CGRect(x: self.orderScrollView.frame.origin.x + self.packageOpenedTextField.frame.origin.x+120,y: self.view.frame.origin.y + self.packageOpenedTextField.frame.origin.y+60,width: 0,height: 0)
        
        
        popoverViewController.listArray =   ["Yes" as AnyObject,"No" as AnyObject]
        
        self.present(popoverViewController, animated: true, completion: nil)
    }
    func resizeImageForPadding(_ resizeImage:UIImage, dropDown:Bool) -> UIImage
    {
        
        
        if dropDown == true
        {
            UIGraphicsBeginImageContext(CGSize(width: 16, height: 16))
            resizeImage.draw(in: CGRect(x: 4, y: 6, width: 8, height: 8))
        }
        else
        {
            UIGraphicsBeginImageContext(CGSize(width: 20, height: 20))
            resizeImage.draw(in: CGRect(x: 4, y: 6, width: 12, height: 12))
        }
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage!
        
    }
    func getPersonalDetails(){
        
        if let customer_id = UserDefaultManager.sharedManager().loginUserId {
            WebserviceEngine().requestforAPI(service: "customer/getmyProfile&customer_id=\(customer_id)", method: "GET", token: "", body: "", productBody: NSData()) { (result, error) in
                if result != nil
                {
                    NSLog("reviewlist \(result)")
                    if let records = result?.value(forKey:"records"){
                        if let newrecords = records as? [[String: AnyObject]]{
                            for newelement in newrecords{
                                if let firstname =  newelement["firstname"] as? String{
                                    self.firstname = firstname
                                }
                                
                                if let secondname =  newelement["lastname"] as? String{
                                    self.lastname = secondname
                                }
                                if let emailid =  newelement["email"] as? String{
                                    self.email = emailid
                                }
                                if let mobileno =  newelement["telephone"] as? String{
                                    self.mobile = mobileno
                                }
                                if let customerid =  newelement["customer_id"] as? String{
                                    self.customer_id = customerid
                                }
                                
                                
                                if let customergroupid = newelement["customer_group__id"] as? String{
                                    self.customergroupid =  customergroupid
                                }
                                
                            }
                        }
                    }
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
    
    

    func orderReturnAction(){
    
        
        if self.reasonTextField.text == "Dead On Arrival"{
            self.returnid = "1"
        }
        if self.reasonTextField.text == "Faulty"{
             self.returnid = "2"
        }
        if self.reasonTextField.text == "Order Error"{
             self.returnid = "3"
        }
        if self.reasonTextField.text == "Other"{
             self.returnid = "4"
        }
        if self.reasonTextField.text == "Recieved wrong item"{
             self.returnid = "5"
        }
        if packageOpenedTextField.text == "Yes"{
            self.opened = "1"
        }
        if packageOpenedTextField.text == "No"{
           self.opened =  "0"
        }

        let param = "firstname=\(self.firstname)&lastname=\(self.lastname)&order_id=\(self.orderid)&customer_group_id=\(self.customergroupid)&telephone=\(self.mobile)&email=\(self.email)&product=\(self.productName)&model=\(self.model)&return_reason_id =\(self.returnid)&customer_id=\(customer_id)&quantity=\(self.quantity)&opened=\(self.opened)&date_ordered=\(self.date)&comments=\(orderTextView.text)"
        
        
        WebserviceEngine().requestforAPI(service: "customer/returnOrder", method: "POST", token: "", body:param, productBody: NSData()) { (result, error) in
            if result != nil
            {
                NSLog("reviewlist \(result)")
                
                // DispatchQueue.main.sync(execute: { () -> Void in
                ProgressIndicatorController.dismissProgressView()
                if let successResponse = result as? [String: AnyObject] {
                    if let successMessage = successResponse["success"] as? String {
                        let alertController = UIAlertController(title: Constants.alertTitle, message:
                            successMessage, preferredStyle: UIAlertControllerStyle.alert)
                        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil))
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
                
                
                
                
                // })
                
                
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

    @IBAction func submitAction(_ sender: Any) {
//        let addressVC = self.storyboard?.instantiateViewController(withIdentifier: "ReturnFinalViewController") as! ReturnFinalViewController
//        
//        addressVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
//        self.present(addressVC, animated: true, completion: nil)
        if self.checked == false{
            
            let alertController = UIAlertController(title: Constants.alertTitle, message:
                "Please Accept the returns terms and conditions", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
        else{
          ProgressIndicatorController.showLoading()
        orderReturnAction()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension OrderReturnViewController:listDelegate{
            func selectedList(_ listValue: NSString,selectedrow:Int) {
                switch fieldType! {
                case .reasonType :
                    print("listvalue",listValue)
//                    if listValue  == "Faulty(please supply details)"
//                    {
//                        
//                        self.reasonTextField.text = "Faulty"
//                    }
//                    if listValue == "Other(Please supply Details)"{
//                        self.reasonTextField.text = "Other"
//                    }
//                 
                    
                    self.reasonTextField.text  =  listValue as String
                    
                    break
                case .packageType:
                    
                    
                    self.packageOpenedTextField.text = listValue as String
                    
                    break
                default:
                    break

}
}
}
extension OrderReturnViewController:CheckboxDelegate{
    func checkBoxClicked(_ checked:Bool, withTag tag: Int){
        self.checked = checked
    }

}
extension OrderReturnViewController:UITextFieldDelegate{

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
         activeField = textField
        return true
    }

    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == productNameTextField{
            textField.returnKeyType = .next
        }
        if textField == quantityTextField{
            textField.returnKeyType = .next
        }
        
        if textField == reasonTextField
            
        {
          reasonTextField.resignFirstResponder()
            showReasonList()
        }
        if textField == packageOpenedTextField{
            textField.resignFirstResponder()
            showPackageList()
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .next{
            if textField == productNameTextField{
                productNameTextField.resignFirstResponder()
                quantityTextField.becomeFirstResponder()
            }
            if textField == quantityTextField{
                quantityTextField.resignFirstResponder()
                showReasonList()
            }
        }
        // textField.resignFirstResponder()
        
        
        
        
               return true
    }
    
}
extension OrderReturnViewController:UITextViewDelegate{
   
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == orderTextView{
            textView.returnKeyType = .done
        }
        
    }
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
       
        if textView == orderTextView{
             activeField = textView
            textView.returnKeyType = .done
            return true
        }
        return false
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    

}
