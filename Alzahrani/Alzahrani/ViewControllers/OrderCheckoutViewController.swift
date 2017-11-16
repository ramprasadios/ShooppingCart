    //
    //  OrderCheckoutViewController.swift
    //  Alzahrani
    //
    //  Created by shilpa shree on 6/1/17.
    //  Copyright © 2017 Ramprasad A. All rights reserved.
    //
    
    import UIKit
    
    enum UserAddressType {
        case existingAddress, newAddress
    }
    
    class OrderCheckoutViewController: UIViewController {
        // MARK: - Outlets
        @IBOutlet weak var checkoutTableView: UITableView!
        
        @IBOutlet weak var aramexShippingButton: UIButton!
        
        
        //MARK: - Properties
        var orderDetailArray = NSMutableArray()
        var defaultAddress = ""
        var cartAddedData = [CartProductData]()
        var addressData = [[String: AnyObject]]()
        var deleveryAddressType: UserAddressType?
        var billingAddressType: UserAddressType?
        var aramexChargesTaken: Bool = false
        var aramexCostPrice = ""
        
        //MARK: - LifeCycle
        override func viewDidLoad() {
            super.viewDidLoad()
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            initialSetUp()
        }
        
        func initialSetUp(){
            //getAddress()
            getPersonalDetails()
            checkoutTableView.delegate = self
            checkoutTableView.dataSource = self
            orderDetailArray = ["","",""]
            let nib = UINib(nibName: "ReviewTableViewCell", bundle: nil)
            checkoutTableView.register(nib, forCellReuseIdentifier: "ReviewTableViewCell")
            let headerNib = UINib(nibName: "ReviewHeaderTableViewCell", bundle: nil)
            checkoutTableView.register(headerNib, forCellReuseIdentifier: "ReviewHeaderTableViewCell")
            let tableHeaderView = loadViewFromNib(nibName:"ReviewHeaderTableViewCell")
            tableHeaderView.frame = CGRect(x:0, y:0, width: self.checkoutTableView.frame.size.width, height: 40.0)
            self.checkoutTableView.tableHeaderView = tableHeaderView
        }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        
        func loadViewFromNib(nibName name : String) -> UIView {
            let bundle = Bundle(for: type(of: self))
            let nib = UINib(nibName: name, bundle: bundle)
            
            // Assumes UIView is top level and only object in name.xib file
            let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
            
            return view
        }
        
        func getPersonalDetails(){
            
            if let customer_id = UserDefaultManager.sharedManager().loginUserId {
                WebserviceEngine().requestforAPI(service: "customer/getmyProfile&customer_id=\(customer_id)", method: "GET", token: "", body: "", productBody: NSData()) { (result, error) in
                    if result != nil
                    {
                        NSLog("reviewlist \(result)")
                        var firstNameStr = ""
                        var lastNameStr = ""
                        var companyName = ""
                        var cityIdStr = ""
                        var countryIdStr = ""
                        var defaultaddress1 = ""
                        var defaultaddress2 = ""
                        var defaultcity = ""
                        var defaultcountry = ""
                        var defaultstate = ""
                        var defaultpincode = ""
                        
                        
                        if let records = result?.value(forKey:"records"){
                            if let newrecords = records as? [[String: AnyObject]]{
                                for newelement in newrecords {
                                    
                                    if let firstName = newelement["firstname"] as? String, let lastName = newelement["lastname"] as? String, let cityId = newelement["zone_id"] as? String, let countryId = newelement["country_id"] as? String {
                                        
                                        firstNameStr = firstName
                                        lastNameStr = lastName
                                        cityIdStr = cityId
                                        countryIdStr = countryId
                                    }
                                    
                                    if let address1 =  newelement["address_1"] as? String{
                                        defaultaddress1 = address1
                                    }
                                    if let address2 =  newelement["address_2"] as? String{
                                        defaultaddress2 = address2
                                    }
                                    if let city =  newelement["city"] as? String{
                                        defaultcity = city
                                    }
                                    if let country =  newelement["country"] as? String{
                                        defaultcountry = country
                                    }
                                    if let state =  newelement["zone"] as? String{
                                        defaultstate = state
                                    }
                                    if let pincode =  newelement["postcode"] as? String{
                                        defaultpincode = pincode
                                    }
                                    if let company = newelement["company"] as? String {
                                        companyName = company
                                    }
                                }
                                if let userId = UserDefaultManager.sharedManager().loginUserId, let cust_Group_id = UserDefaultManager.sharedManager().customerGroupId {
                                    let existingAddress = UserAddressData(customerId: userId, cust_Group_id, firstNameStr, lastNameStr, companyName, "", defaultaddress1, defaultaddress2, defaultstate, defaultpincode, defaultcountry, countryIdStr, defaultcity, cityIdStr, "")
                                    UserShipppingAddress.sharedInstance.userDefaultAddress = existingAddress
                                }
                                
                                self.defaultAddress = "\(firstNameStr) \(lastNameStr),\(companyName),\(defaultaddress1)\n\(defaultcity) \(defaultstate) \(defaultcountry)\("-")\(defaultpincode)"
                                
                                
                            }
                        }
                        DispatchQueue.main.sync(execute: { () -> Void in
                            self.checkoutTableView.reloadData()
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
        
        
        @IBAction func getAramexCharges(_ sender: Any) {
            if let deleveryAddress = self.deleveryAddressType {
                
                self.aramexChargesTaken = true
                let syncParameterInfo = self.getSyncParameters()
                SyncManager.syncOperation(operationType: .aramexShipping, info: syncParameterInfo, completionHandler: { (response, error) in
                    if error == nil {
                        print("Aramex Charges Data \(response)")
                        if let aramexResponse = response as? [String: AnyObject] {
                            if let aramexBaseDict = aramexResponse["wk_aramex"] as? [String: AnyObject] {
                                if let quoteDict = aramexBaseDict["quote"] as? [String: AnyObject] {
                                    if let aramexInfo = quoteDict["wk_aramex"] as? [String: AnyObject] {
                                        if let aramexCostText = aramexInfo["text"] as? String {
                                            if let aramesCostPrice = aramexInfo["cost"] as? Int {
                                                self.aramexCostPrice = aramesCostPrice.description
                                            }
                                            self.aramexShippingButton.setTitle(aramexCostText, for: .normal)
                                            self.aramexShippingButton.setTitle(aramexCostText, for: .highlighted)
                                            self.aramexShippingButton.isEnabled = false
                                        }
                                    }
                                }
                            }
                        }
                    }
                })
                
            } else {
                self.showAlertWith(warningMsg: "Plesae select Billing / Develery Address")
            }
        }
        
        
        @IBAction func proceedToCheckoutTapped(_ sender: Any) {
            if let deleveryAddress = self.deleveryAddressType, let billingAddre = self.billingAddressType {
                if self.aramexChargesTaken {
                    if let paymentVc = self.storyboard?.instantiateViewController(withIdentifier: ReviewPaymentViewController.selfName()) as? ReviewPaymentViewController {
                        paymentVc.cartPaymentData = self.cartAddedData
                        paymentVc.userInfoData = addressData
                        paymentVc.deleveryAddressType = deleveryAddress
                        paymentVc.billingAddressType = billingAddre
                        paymentVc.aramexCostPrice = self.aramexCostPrice
                        var loginUserType: UserLoginType = .endUser
                        if let userType = UserDefaultManager.sharedManager().customerGroupId {
                            if ((userType == "15") || (userType == "16")) {
                                loginUserType = .salesExecutive
                            } else if userType == "1" {
                                loginUserType = .endUser
                            } else if userType == "17" {
                                loginUserType = .employee
                            }
                        }
                        paymentVc.userType = loginUserType
                        self.navigationController?.pushViewController(paymentVc, animated: true)
                    }
                } else {
                    self.showAlertWith(warningMsg: "Plesae get shipping Charges")
                }
            } else {
                self.showAlertWith(warningMsg: "Plesae select Billing / Develery Address")
            }
        }
    }
    
    // MARK: - TableViewDelegateMethods
    extension OrderCheckoutViewController:UITableViewDelegate{
        
        
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            if (indexPath.row == cartAddedData.count){
                return 145
            }
            
            if (indexPath.row == cartAddedData.count + 1) || (indexPath.row == cartAddedData.count+2){
                return 160
            }
                
            else{
                return 40
            }
        }
    }
    
    // MARK: - TableViewDatasourceMethods
    extension OrderCheckoutViewController:UITableViewDataSource {
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return cartAddedData.count + 3
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            if indexPath.row == cartAddedData.count {
                let cell  = tableView.dequeueReusableCell(withIdentifier: "OrdeChecoutPriceTableViewCell") as! OrdeChecoutPriceTableViewCell
                cell.subTotalLabel.text = "SAR " + self.getSubTotal()
                cell.codeField.delegate = self
                cell.totalPriceLabel.text = "SAR " + self.getSubTotal()
                cell.shippingChargesLabel.text = NSLocalizedString("S.R 0", comment: "")
                cell.couponDiscoubtLabel.text = NSLocalizedString("S.R 0", comment: "")
                return cell
            }
            if indexPath.row == cartAddedData.count+1 {
                
                let cell  = tableView.dequeueReusableCell(withIdentifier: "OrderCheckoutAddressTableViewCell") as! OrderCheckoutAddressTableViewCell
                cell.delegate = self
                cell.headinLabel.text = NSLocalizedString("Billing Details", comment: "")
                cell.addressView.text = self.defaultAddress
                
                return cell
            }
            
            if indexPath.row == cartAddedData.count+2 {
                let cell  = tableView.dequeueReusableCell(withIdentifier: "OrderCheckoutAddressTableViewCell") as! OrderCheckoutAddressTableViewCell
                cell.delegate = self
                cell.headinLabel.text = NSLocalizedString("Delivery Changes", comment: "")
                cell.addressView.text = self.defaultAddress
                return cell
            }
            else{
                let cell  = tableView.dequeueReusableCell(withIdentifier: "ReviewTableViewCell") as! ReviewTableViewCell
                cell.productNameLabel.text = cartAddedData[indexPath.row].name
                cell.productQtyLabel.text = cartAddedData[indexPath.row].quantity
                cell.productUnitPriceLabel.text = cartAddedData[indexPath.row].unitPrice
                cell.productTotalPriceLabel.text = cartAddedData[indexPath.row].totalPrice
                return cell
                
            }
        }
        
        func newAddressAction(withAddressType type: AddressType){
            let addressVC = self.storyboard?.instantiateViewController(withIdentifier: "AddNewAddressViewController") as! AddNewAddressViewController
            addressVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            self.present(addressVC, animated: true, completion: nil)
        }
    }
    
    //MARK: - TextFieldDelegateMethods
    extension OrderCheckoutViewController: UITextFieldDelegate{
        func textFieldDidBeginEditing(_ textField: UITextField) {
            let cell = self.checkoutTableView.cellForRow(at:IndexPath.init(row: cartAddedData.count, section: 0)) as! OrdeChecoutPriceTableViewCell
            if textField == cell.codeField{
                textField.returnKeyType = .done
            }
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            let cell = self.checkoutTableView.cellForRow(at:IndexPath.init(row: cartAddedData.count, section: 0)) as! OrdeChecoutPriceTableViewCell
            if textField.returnKeyType == .done {
                
                cell.codeField.resignFirstResponder()
            }
            return true
            
        }
    }
    
    ///MARK:- Helper Methods:
    extension OrderCheckoutViewController {
        
        func getSubTotal() -> String {
            var locVal: Int = 0
            for cartData in cartAddedData {
                if let price = Int(cartData.totalPrice!) {
                    locVal = locVal + price
                }
            }
            return locVal.description
        }
    }
    
    
    extension OrderCheckoutViewController: OrderCheckoutButtonDelegate {
        
        func newAddressButtonTapped(withCell cell: OrderCheckoutAddressTableViewCell) {
            if let indexPath = self.checkoutTableView.indexPath(for: cell) {
                switch indexPath.row {
                case cartAddedData.count + 1:
                    self.billingAddressType = .newAddress
                    self.newAddressAction(withAddressType: .delevery)
                case cartAddedData.count + 2:
                    self.deleveryAddressType = .newAddress
                    self.newAddressAction(withAddressType: .billing)
                default:
                    break
                }
            }
        }
        
        func existingAddressTapped(withCell cell: OrderCheckoutAddressTableViewCell) {
            if let indexPath = self.checkoutTableView.indexPath(for: cell) {
                switch indexPath.row {
                case cartAddedData.count + 1:
                    self.billingAddressType = .existingAddress
                case cartAddedData.count + 2:
                    self.deleveryAddressType = .existingAddress
                default:
                    break
                }
            }
        }
    }
    
    //MARK:- Helper Methods:
    extension OrderCheckoutViewController {
        
        func showAlertWith(warningMsg msg: String) {
            let alertController = UIAlertController(title: Constants.alertTitle, message: msg, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
                
            })
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
        
        func getSyncParameters() -> String {
            
            let deleveryTypeAddress: UserAddressData!
            
            if self.deleveryAddressType == .existingAddress {
                deleveryTypeAddress = UserShipppingAddress.sharedInstance.userDefaultAddress
            } else {
                if self.billingAddressType == .newAddress {
                    deleveryTypeAddress = UserShipppingAddress.sharedInstance.userAddressData[1]
                } else {
                    deleveryTypeAddress = UserShipppingAddress.sharedInstance.userAddressData[0]
                }
            }
            var custGrpId = ""
            var custId = ""
            let languageId = (AppManager.languageType() == .arabic) ? "2" : "1"
            if let customer_group_id = UserDefaultManager.sharedManager().customerGroupId {
                custGrpId = customer_group_id
            }
            if let customer_id = UserDefaultManager.sharedManager().loginUserId {
                custId = customer_id
            }
            
            let syncParameter2 = "shipping_firstname=\(deleveryTypeAddress.firstName)&shipping_lastname=\(deleveryTypeAddress.lastName)&shipping_company=\("")&shipping_address_1=\(deleveryTypeAddress.address1)&shipping_address_2=\(deleveryTypeAddress.address2)&city=\(deleveryTypeAddress.city)&postcode=\(deleveryTypeAddress.postCode)&shipping_country=\(deleveryTypeAddress.country)&shipping_country_id=\(deleveryTypeAddress.countryId)&shipping_zone=\(deleveryTypeAddress.city)&total=\("0")&shipping_method=\("Aramex Shipping")&shipping_code=\("wk_aramex.wk_aramex")&shipping_zone_id=\(deleveryTypeAddress.zoneId)&language_id=\(languageId)&shipping_country_code=\("SA")&iso_code_2=\("SA")&customer_group_id=\(custGrpId)&customer_id=\(custId)"
            
            return syncParameter2
        }
    }
