//
//  ReviewPaymentViewController.swift
//  Alzahrani
//
//  Created by shilpa shree on 5/17/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

enum UserLoginType {
    case endUser
    case employee
    case salesExecutive
}

enum PaymentMethod: String {
    case onlinePayment = "Credit / Debit Card"
    case cashOnDelevery = "Cash On Delivery"
    case salaryDeduction = "Salary Deduction"
    case bankTransfer = "Bank Transfer"
}

enum ShippingMethod: String {
    case aramex = "Aramex Shipping"
    case freeShipping = "Free Shipping"
}

class ReviewPaymentViewController: UIViewController {
    
    @IBOutlet weak var proceedToPaymentButton: UIButton!
    @IBOutlet weak var creditCardButton: ISRadioButton!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    @IBOutlet weak var reviewtableview: UITableView!
    @IBOutlet weak var subTotalLabel: NSLayoutConstraint!
    @IBOutlet weak var totalPriceLabel: NSLayoutConstraint!
    
    @IBOutlet weak var proceedButtonConstraint: NSLayoutConstraint!
    @IBOutlet weak var paymentTypeLabel: UILabel!
    @IBOutlet weak var subTotalPriceLabel: UILabel!
    @IBOutlet weak var totalPriceValueLabel: UILabel!
    @IBOutlet weak var creditButton: ISRadioButton!
    @IBOutlet weak var creditLabel: UILabel!
    @IBOutlet weak var salaryButton: ISRadioButton!
    @IBOutlet weak var salaryLabel: UILabel!
    @IBOutlet weak var bankButton: ISRadioButton!
    @IBOutlet weak var bankLabel: UILabel!
    @IBOutlet weak var cashLabel: UILabel!
    @IBOutlet weak var cashButton: ISRadioButton!
    
    @IBOutlet weak var aramexShippingCharge: UILabel!
    
    var cartPaymentData = [CartProductData]()
    var userInfoData = [[String: AnyObject]]()
    var totalPrice = ""
    
    var deleveryAddressType: UserAddressType = .existingAddress
    var billingAddressType: UserAddressType = .existingAddress
    var onlinePaymentChecked: Bool? = false
    var userType: UserLoginType = .endUser
    var paymentTypeSelected: Bool = false
    var paymentCode: PaymentCode = .cashOnDelevery
    var paymentMethod: PaymentMethod = .cashOnDelevery
    var aramexCostPrice: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        self.bindInitialValues()
        self.setupViewBasedOn(userType: userType)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !self.salaryButton.isSelected {
            self.salaryButton.isSelected = false
            self.bankButton.isSelected = false
            self.cashButton.isSelected = false
            self.creditButton.isSelected = false
        }
    }
    
    func setupTableView() {
        
        let nib = UINib(nibName: "ReviewTableViewCell", bundle: nil)
        reviewtableview.register(nib, forCellReuseIdentifier: "ReviewTableViewCell")
        let headerNib = UINib(nibName: "ReviewHeaderTableViewCell", bundle: nil)
        reviewtableview.register(headerNib, forCellReuseIdentifier: "ReviewHeaderTableViewCell")
        reviewtableview.dataSource = self
        reviewtableview.delegate = self
        reviewtableview.estimatedRowHeight = 80
        reviewtableview.rowHeight = UITableViewAutomaticDimension
    }
    
    func bindInitialValues() {
        
        self.subTotalPriceLabel.text = "SAR " + self.getSubTotal()
        self.totalPriceValueLabel.text = "SAR " + self.getMainTotal()
        self.aramexShippingCharge.text = "SAR " + self.aramexCostPrice
    }
    
    func setupViewBasedOn(userType type: UserLoginType) {
        switch type {
        case .endUser:
            self.salaryLabel.isEnabled = false
            self.salaryButton.isEnabled = false
        case .employee:
            break
        case .salesExecutive:
            self.paymentTypeLabel.isHidden = true
            self.creditLabel.isHidden = true
            self.creditButton.isHidden = true
            self.salaryButton.isHidden = true
            self.salaryLabel.isHidden = true
            self.cashLabel.isHidden = true
            self.cashButton.isHidden = true
            self.bankLabel.isHidden = true
            self.bankButton.isHidden = true
            self.proceedButtonConstraint.constant = 180
            self.proceedToPaymentButton.setTitle("Place Order", for: .normal)
            self.proceedToPaymentButton.setTitle("Place Order", for: .highlighted)
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
    
    func getMainTotal() -> String {
        var locVal: Int = 0
        for cartData in cartPaymentData {
            if let price = Int(cartData.totalPrice!) {
                locVal = locVal + price
            }
        }
        if let aramexPrice = Int(aramexCostPrice) {
            locVal = locVal + aramexPrice
        }
        self.totalPrice = locVal.description
        return locVal.description
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onlinePaymentSelected(_ sender: Any) {
        self.paymentCode = .onlinePayment
        self.paymentMethod = .onlinePayment
        self.proceedToPaymentButton.setTitle("Proceed to Payment", for: .normal)
        self.proceedToPaymentButton.setTitle("Proceed to Payment", for: .highlighted)
        self.onlinePaymentChecked = true
        if let onlinePaymentVc = self.storyboard?.instantiateViewController(withIdentifier: OnlinePaymentViewController.selfName()) as? OnlinePaymentViewController {
            onlinePaymentVc.billingAddressType = self.billingAddressType
            onlinePaymentVc.deleveryAddressType = self.deleveryAddressType
            self.present(onlinePaymentVc, animated: true, completion: nil)
        }
    }
    
    @IBAction func salaryDeductionModeSelected(_ sender: Any) {
        self.paymentCode = .salaryDeduction
        self.paymentMethod = .salaryDeduction
        self.onlinePaymentChecked = false
        self.paymentTypeSelected = true
        self.proceedToPaymentButton.setTitle("Place Order", for: .normal)
        self.proceedToPaymentButton.setTitle("Place Order", for: .highlighted)
    }
    
    @IBAction func bankTransferModeSelected(_ sender: Any) {
        self.paymentCode = .bankTransfer
        self.paymentMethod = .bankTransfer
        self.paymentTypeSelected = true
        self.onlinePaymentChecked = false
        self.proceedToPaymentButton.setTitle("Place Order", for: .normal)
        self.proceedToPaymentButton.setTitle("Place Order", for: .highlighted)
    }
    
    @IBAction func cashOnDeleverySelected(_ sender: Any) {
        self.paymentCode = .cashOnDelevery
        self.paymentMethod = .cashOnDelevery
        self.paymentTypeSelected = true
        self.onlinePaymentChecked = false
        self.proceedToPaymentButton.setTitle("Place Order", for: .normal)
        self.proceedToPaymentButton.setTitle("Place Order", for: .highlighted)
    }
    
    @IBAction func proceedToPaymenTapped(_ sender: Any) {
        self.paymentTypeSelected = true
        self.onlinePaymentChecked = false
        self.proceedToPaymentButton.setTitle("Place Order", for: .normal)
        self.proceedToPaymentButton.setTitle("Place Order", for: .highlighted)
    }
    
    
    @IBAction func placeOrderButtonTapped(_ sender: Any) {
        if ((self.bankButton.isSelected == true || self.salaryButton.isSelected == true || self.cashButton.isSelected) && self.creditButton.isSelected == false) /* && (UserDefaultManager.sharedManager().customerGroupId == "15" || UserDefaultManager.sharedManager().customerGroupId == "16") */ {
            if !self.onlinePaymentChecked! {
                self.getPostParameters()
            } else {
                if let onlinePaymentVc = self.storyboard?.instantiateViewController(withIdentifier: OnlinePaymentViewController.selfName()) as? OnlinePaymentViewController {
                    onlinePaymentVc.billingAddressType = self.billingAddressType
                    onlinePaymentVc.deleveryAddressType = self.deleveryAddressType
                    self.present(onlinePaymentVc, animated: true, completion: nil)
                }
            }
        } else {
            let alertController = UIAlertController(title: Constants.alertTitle, message: NSLocalizedString("Please select Payment Method", comment: ""), preferredStyle: .alert)
            let okAction = UIAlertAction(title: Constants.alertAction, style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

//MARK:- UITableViewDataSource:
extension ReviewPaymentViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartPaymentData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "ReviewTableViewCell") as! ReviewTableViewCell
        cell.productNameLabel.text = cartPaymentData[indexPath.row].name
        cell.productQtyLabel.text = cartPaymentData[indexPath.row].quantity
        cell.productUnitPriceLabel.text = cartPaymentData[indexPath.row].unitPrice
        cell.productTotalPriceLabel.text = cartPaymentData[indexPath.row].totalPrice
        return cell
    }
}

//MARK:- UITableViewDelegate:
extension ReviewPaymentViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableCell(withIdentifier: "ReviewHeaderTableViewCell")
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 44.0
        
    }
}

//MARK:- Helper Methods:
extension ReviewPaymentViewController {
    
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
        let syncParameter1 = "customer_id=\(billingTypeAddress.customerId)&customer_group_id=\(billingTypeAddress.customerGroupId)&firstname=\(fName)&lastname=\(lName)&email=\(userEmail)&telephone=\(userPhone)&fax=\(userPhone)&reward=\("0")&payment_firstname=\(billingTypeAddress.firstName)&payment_lastname=\(billingTypeAddress.lastName)&payment_company=\("")&payment_company_id=\("17")&payment_address_1=\(billingTypeAddress.address1)&payment_address_2=\(billingTypeAddress.address2)&payment_city=\(billingTypeAddress.city)&payment_postcode=\(billingTypeAddress.postCode)&payment_country=\(billingTypeAddress.country)&payment_country_id=\(billingTypeAddress.countryId)&payment_tax_id=\("0")&payment_zone=\(billingTypeAddress.city)&payment_zone_id=\(billingTypeAddress.zoneId)&payment_method=\(self.paymentMethod.rawValue)&payment_code=\(self.paymentCode.rawValue)&"
        
        let syncParameter2 = "shipping_firstname=\(deleveryTypeAddress.firstName)&shipping_lastname=\(deleveryTypeAddress.lastName)&shipping_company=\("")&shipping_company_id=\("")&shipping_address_1=\(deleveryTypeAddress.address1)&shipping_address_2=\(deleveryTypeAddress.address2)&shipping_city=\(deleveryTypeAddress.city)&shipping_postcode=\(deleveryTypeAddress.postCode)&shipping_country=\(deleveryTypeAddress.country)&shipping_country_id=\(deleveryTypeAddress.countryId)&shipping_tax_id=\("0")&shipping_zone=\(deleveryTypeAddress.city)&total=\("0")&shipping_method=\("Free Shipping")&shipping_code=\("free.free")&shipping_zone_id=\(deleveryTypeAddress.zoneId)&total=\(self.totalPrice)&language_id=\(languageId)"
        
        let finalParameter = syncParameter1 + syncParameter2
        //ProgressIndicatorController.showLoading()
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
    
    func showUserAlert(withMessage msg: String) {
        let alertController = UIAlertController(title: NSLocalizedString("Alzahrani", comment: ""), message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default) { (UIAlertAction) in
            NotificationCenter.default.post(name: Notification.Name(Constants.sliderMenuFieldTapNotification), object: nil, userInfo: nil)
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
