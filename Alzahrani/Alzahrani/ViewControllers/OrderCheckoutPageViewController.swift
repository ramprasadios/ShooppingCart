
//
//  OrderCheckoutPageViewController.swift
//  Alzahrani
//
//  Created by Hardwin on 12/07/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit
import Localize_Swift
import MagicalRecord

struct CheckoutFlow {
    
    var step1: Bool
    var step2: Bool
    var step3: Bool
    var step4: Bool
    var step5: Bool
    var step6: Bool
    
    init(withSteps1 one: Bool, andTwo two: Bool, andThree three: Bool, andFour four: Bool, andFive five: Bool, andSix six: Bool) {
        self.step1 = one
        self.step2 = two
        self.step3 = three
        self.step4 = four
        self.step5 = five
        self.step6 = six
    }
}

struct SectionHeaderData {
    
    var isTapped: Bool
    let sectionName: String
    var nextStep: Bool
    
    init(withHeaderName name: String, isTapped tapped: Bool, andNextStep next: Bool) {
        self.isTapped = tapped
        self.sectionName = name
        self.nextStep = next
    }
}

class OrderCheckoutPageViewController: UIViewController {
    
    var sectionHeaderInfoData = [SectionHeaderData]()
    var selectedPaymentMethod: PaymentMethodTypes = .bank
    var userExistingAddressData = [UserAddressData]()
    var checkoutFlowSteps: CheckoutFlow?
    var cartAddedData = [CartProductData]()
    var billingAddressInfo: AddressCellData?
    var deleveryAddressInfo: AddressCellData?
    var selectedAddressIndex: Int = 0
    var aramexShippingCharges: String = ""
    var aramexShippingCost: Int = 0
    var cartPrice: Int = 0
    var calculationStrArray = ["Sub-Total:", "Shipping Charges:", "Total:"]
    var valueArray = [String]()
    var sdkTokenValue: String = ""
    var merchantReference: String = ""
    var signatureValue: String = ""
    var codCharges = ""
    var shippingType: ShippingType = .free_shipping
    var shipping_code: ShippingCode = .free
    var free_shipping_charges = ""
    var userComments = ""
    var bankDetailsText: String?
    var shippingChargesLabel: String = ""
    var couponCodeInfo = [String: AnyObject]()
    var finalTotalPrice: String = ""
    
    //Coupon Properties:
    var isCouponApplied: Bool = false
    var couponValue: String = ""
    var coponCode: String = ""
    
    @IBOutlet weak var orderCheckoutTableView: UITableView!
    
    //MARK:- Life Cycle:
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getCouponDetails()
        self.initialTableViewSetup()
        self.registerNibs()
        self.setInitialData()
        self.addNotificationObserver()
        //self.title = NSLocalizedString("CheckOut", comment: "")
        self.title = "CheckOut".localized()
        self.setArrayData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.sendRemoveDropDownEvent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

//MARK:- Helper Methods:
extension OrderCheckoutPageViewController {
    
    func initialTableViewSetup() {
        
        self.orderCheckoutTableView.rowHeight = UITableViewAutomaticDimension
        self.orderCheckoutTableView.estimatedRowHeight = 150.0
    }
    
    func getCouponDetails() {
        if let couponCodeTxt = self.couponCodeInfo["CouponName"] as? String, let couponAmountStr = self.couponCodeInfo["CouponAmount"] as? Int {
            if couponCodeTxt != "" && couponAmountStr != 0 {
                self.isCouponApplied = true
                self.couponValue = couponAmountStr.description
                self.coponCode = couponCodeTxt
            }
        }
    }
    
    func registerNibs() {

        let sectionNib = UINib(nibName: CheckOutStepsHeaderView.selfName(), bundle: nil)
        self.orderCheckoutTableView.register(sectionNib, forHeaderFooterViewReuseIdentifier: CheckOutStepsHeaderView.selfName())
        
        let billingDetailsCellNib = UINib(nibName: BillingDetailsTableViewCell.selfName(), bundle: nil)
        self.orderCheckoutTableView.register(billingDetailsCellNib, forCellReuseIdentifier: BillingDetailsTableViewCell.selfName())
        
        let deleveryMethodCellNib = UINib(nibName: DeleveryMethodTableViewCell.selfName(), bundle: nil)
        self.orderCheckoutTableView.register(deleveryMethodCellNib, forCellReuseIdentifier: DeleveryMethodTableViewCell.selfName())
        
        let paymentMethodCellNib = UINib(nibName: PaymentMethodTableViewCell.selfName(), bundle: nil)
        self.orderCheckoutTableView.register(paymentMethodCellNib, forCellReuseIdentifier: PaymentMethodTableViewCell.selfName())

        let commentCellNib = UINib(nibName: CommetsTableViewCell.selfName(), bundle: nil)
        self.orderCheckoutTableView.register(commentCellNib, forCellReuseIdentifier: CommetsTableViewCell.selfName())
        
        let productDiscCellNib = UINib(nibName: ReviewTableViewCell.selfName(), bundle: nil)
        self.orderCheckoutTableView.register(productDiscCellNib, forCellReuseIdentifier: ReviewTableViewCell.selfName())
        
        let calcCellNib = UINib(nibName: CalculationTableViewCell.selfName(), bundle: nil)
        self.orderCheckoutTableView.register(calcCellNib, forCellReuseIdentifier: CalculationTableViewCell.selfName())
        
        let finalCellNib = UINib(nibName: FinalPriceTableViewCell.selfName(), bundle: nil)
        self.orderCheckoutTableView.register(finalCellNib, forCellReuseIdentifier: FinalPriceTableViewCell.selfName())
        
        let confirmOrderCellNib = UINib(nibName: ConfirmOderTableViewCell.selfName(), bundle: nil)
        self.orderCheckoutTableView.register(confirmOrderCellNib, forCellReuseIdentifier: ConfirmOderTableViewCell.selfName())
        
        let paymentCellNib = UINib(nibName: ProceedToPaymentTableViewCell.selfName(), bundle: nil)
        self.orderCheckoutTableView.register(paymentCellNib, forCellReuseIdentifier: ProceedToPaymentTableViewCell.selfName())
        
        let bankTransferCellNib = UINib(nibName: BankTransferDetailsCell.selfName(), bundle: nil)
        self.orderCheckoutTableView.register(bankTransferCellNib, forCellReuseIdentifier: BankTransferDetailsCell.selfName())
    }
    
    func setArrayData() {
        
        if self.selectedPaymentMethod == .cod {
            if isCouponApplied {
                self.calculationStrArray = [NSLocalizedString("Sub-Total:", comment: ""), NSLocalizedString("Coupon", comment: ""), "Cash On Delevery Fee:", NSLocalizedString(self.shippingChargesLabel, comment: ""), NSLocalizedString("Total:", comment: "")]
                self.valueArray = ["S.R " + self.getSubTotal(), "S.R " + "-" + self.couponValue, "S.R " + self.codCharges, self.aramexShippingCharges, "S.R " + self.finalTotalPrice]
            } else {
                self.calculationStrArray = [NSLocalizedString("Sub-Total:", comment: ""), "Cash On Delevery Fee:", NSLocalizedString(self.shippingChargesLabel, comment: ""), NSLocalizedString("Total:", comment: "")]
                self.valueArray = ["S.R " + self.getSubTotal(), "S.R " + self.codCharges, self.aramexShippingCharges, "S.R " + /*self.getTotalPrice() */ self.finalTotalPrice]
            }
        } else if self.selectedPaymentMethod == .online {
            if isCouponApplied {
                self.calculationStrArray = [NSLocalizedString("Sub-Total:", comment: ""), NSLocalizedString("Coupon", comment: ""), NSLocalizedString(self.shippingChargesLabel, comment: ""), NSLocalizedString("Total:", comment: "")]
                self.valueArray = ["S.R " + self.getSubTotal(), "S.R " + "-" + self.couponValue, self.aramexShippingCharges, "S.R " + /*self.getTotalPrice() */ self.finalTotalPrice]
            } else {
                self.calculationStrArray = [NSLocalizedString("Sub-Total:", comment: ""), NSLocalizedString(self.shippingChargesLabel, comment: ""), NSLocalizedString("Total:", comment: "")]
                self.valueArray = ["S.R " + self.getSubTotal(), self.aramexShippingCharges, "S.R " + /*self.getTotalPrice() */ self.finalTotalPrice]
            }
            
        } else if self.selectedPaymentMethod == .bank {
			if AppManager.currentApplicationMode() == .online {
				if isCouponApplied {
					self.calculationStrArray = [NSLocalizedString("Sub-Total:", comment: ""), NSLocalizedString("Coupon", comment: ""), NSLocalizedString(self.shippingChargesLabel, comment: ""), NSLocalizedString("Total:", comment: ""), ""]
					self.valueArray = ["S.R " + self.getSubTotal(), "S.R " + "-" + self.couponValue, self.aramexShippingCharges, "S.R " +/*self.getTotalPrice() */ self.finalTotalPrice, ""]
				} else {
					self.calculationStrArray = [NSLocalizedString("Sub-Total:", comment: ""), NSLocalizedString(self.shippingChargesLabel, comment: ""), NSLocalizedString("Total:", comment: ""), ""]
					self.valueArray = ["S.R " + self.getSubTotal(), self.aramexShippingCharges, "S.R " + /*self.getTotalPrice() */ self.finalTotalPrice, ""]
				}
			} else {
				self.calculationStrArray = [NSLocalizedString("Sub-Total:", comment: ""), NSLocalizedString(self.shippingChargesLabel, comment: ""), NSLocalizedString("Total:", comment: ""), ""]
				self.valueArray = ["S.R " + self.getSubTotal(), self.aramexShippingCharges, "S.R " + self.getTotalPrice(), ""]
			}
			
        } else {
            if self.isCouponApplied {
                self.calculationStrArray = [NSLocalizedString("Sub-Total:", comment: ""), NSLocalizedString("Coupon", comment: ""), NSLocalizedString(self.shippingChargesLabel, comment: ""), NSLocalizedString("Total:", comment: "")]
                self.valueArray = ["S.R " + self.getSubTotal(), "S.R " + self.couponValue, self.aramexShippingCharges, "S.R " + /*self.getTotalPrice() */ self.finalTotalPrice]
            } else {
                self.calculationStrArray = [NSLocalizedString("Sub-Total:", comment: ""), NSLocalizedString(self.shippingChargesLabel, comment: ""), NSLocalizedString("Total:", comment: "")]
                self.valueArray = ["S.R " + self.getSubTotal(), self.aramexShippingCharges, "S.R " + /*self.getTotalPrice() */ self.finalTotalPrice]
            }
            
        }
    }
    
    func setInitialData() {
        
        for section in CheckOutSteps.caseValues {
            var sectionData: SectionHeaderData?
            switch section {
            case .first:
                sectionData = SectionHeaderData(withHeaderName: section.rawValue, isTapped: false, andNextStep: true)
            case .second:
                sectionData = SectionHeaderData(withHeaderName: section.rawValue, isTapped: true, andNextStep: true)
            case .third:
                sectionData = SectionHeaderData(withHeaderName: section.rawValue, isTapped: false, andNextStep: false)
            case .fourth:
                sectionData = SectionHeaderData(withHeaderName: section.rawValue, isTapped: false, andNextStep: false)
            case .fifth:
                sectionData = SectionHeaderData(withHeaderName: section.rawValue, isTapped: false, andNextStep: false)
            case .sixth:
                sectionData = SectionHeaderData(withHeaderName: section.rawValue, isTapped: false, andNextStep: false)
            }
            self.sectionHeaderInfoData.append(sectionData!)
        }
        self.orderCheckoutTableView.reloadData()
    }
    
    func getCustomerType() -> UserLoginType {
        if let custGrpId = UserDefaultManager.sharedManager().customerGroupId {
            if custGrpId == "1" {
                return .endUser
            } else if ((custGrpId == "15") || (custGrpId == "16")) {
                return .salesExecutive
            } else {
                return .employee
            }
        } else {
            return .endUser
        }
    }
    
    func getAddressList() -> [String] {
		var addressList = [String]()
		if AppManager.currentApplicationMode() == .online {
			var tempStr = ""
			for field in self.userExistingAddressData {
				tempStr = field.firstName + "," + " " + field.lastName + "," + " " + field.address1 + "," + " " + field.address2 + "," + " " + field.city + "," + " "
				
				addressList.append(tempStr)
			}
			return addressList
		} else {
			var tempStr = ""
			if let addressData = Address.getAllAddressData() {
				for field in addressData {
					tempStr = ("\(field.firstName!), \(field.lastName!), \(field.address1!), \(field.address2!), \(field.city!) ")
					addressList.append(tempStr)
				}
			}
			 return addressList
		}
    }
	
    func setupAddressDropdown(atCell cell: BillingDetailsTableViewCell) {
        cell.billingAddressDropdown.contentTextField.text = "Loading Address..."
        cell.billingAddressDropdown.delegate = self
        cell.billingAddressDropdown.optionsArray = self.getAddressList()
        cell.billingAddressDropdown.menuHeight = 250.0
        cell.billingAddressDropdown.fontSize = UIFont.systemFont(ofSize: 12.0)
//        cell.billingAddressDropdown.yPosition = 0.0
        cell.billingAddressDropdown.menuWidth = self.view.frame.size.width * 0.75
    }
    
    func goToNextStep(atSection section: Int) {
        if self.getCustomerType() == .salesExecutive && section == 3 {
            self.sectionHeaderInfoData[section + 2].nextStep = true
            self.sectionHeaderInfoData[section + 2].isTapped = !self.sectionHeaderInfoData[section + 2].isTapped
            
            for (index, _) in self.sectionHeaderInfoData.enumerated() {
                if index != section + 2 {
                    self.sectionHeaderInfoData[index].isTapped = false
                }
            }
            self.orderCheckoutTableView.reloadData()
        } else {
            self.sectionHeaderInfoData[section + 1].nextStep = true
            self.sectionHeaderInfoData[section + 1].isTapped = !self.sectionHeaderInfoData[section + 1].isTapped
            
            for (index, _) in self.sectionHeaderInfoData.enumerated() {
                if index != section + 1 {
                    self.sectionHeaderInfoData[index].isTapped = false
                }
            }
            self.orderCheckoutTableView.reloadData()
        }
    }
    
    func newAddressAction(withAddressType type: AddressType) {
		
		if AppManager.currentApplicationMode() == .online {
			self.sendRemoveDropDownEvent()
			self.navigationController?.tabBarController?.tabBar.isHidden = true
			let addressVC = self.storyboard?.instantiateViewController(withIdentifier: "AddNewAddressViewController") as! AddNewAddressViewController
			addressVC.userAddressInfoType = type
			addressVC.delegate = self
			addressVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
			self.present(addressVC, animated: true, completion: nil)

		} else {
			ALAlerts.showToast(message: NSLocalizedString("Available only in online mode", comment: ""))
		}
	}
	
    func addNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(OrderCheckoutPageViewController.showTabBar), name: Notification.Name(rawValue: "ShowTabBarNotify"), object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(OrderCheckoutPageViewController.keyBoardWillShow),
                                               name: .UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(OrderCheckoutPageViewController.keyBoardWillCollapse),
                                               name: .UIKeyboardWillHide, object: nil)
    }
    
    func showTabBar() {
        self.navigationController?.tabBarController?.tabBar.isHidden = false
    }
    
    func downloadExistingAddress() {
        self.downloadUserExistingAddress()
    }
    
    func handleAddressSave() {
        if self.deleveryAddressInfo?.deleveryType == .existing {
            UserShipppingAddress.sharedInstance.deleveryExitingAddressData = []
            let custId = UserDefaultManager.sharedManager().loginUserId
            let custGrpId = UserDefaultManager.sharedManager().customerGroupId
			if AppManager.currentApplicationMode() == .online {
				let existingAddress = self.userExistingAddressData[self.selectedAddressIndex]
				let addressData = UserAddressData(customerId: custId!, custGrpId!, existingAddress.firstName, existingAddress.lastName, existingAddress.company, existingAddress.company_id, existingAddress.address1, existingAddress.address2, existingAddress.city, existingAddress.postCode, existingAddress.country, existingAddress.countryId, existingAddress.zone, existingAddress.zoneId, "")
				UserShipppingAddress.sharedInstance.deleveryExitingAddressData.append(addressData)
			} else {
				let userAddressData = Address.getAllAddressData()
				let existingAddress = userAddressData?[self.selectedAddressIndex]
				let addressData = UserAddressData(customerId: custId!, custGrpId!, existingAddress!.firstName!, existingAddress!.lastName!, existingAddress!.company!, "", existingAddress!.address1!, existingAddress!.address2!, existingAddress!.city!, existingAddress!.postCode!, existingAddress!.country!, existingAddress!.countryId!, existingAddress!.zoneName!, existingAddress!.zoneId!, "")
				UserShipppingAddress.sharedInstance.deleveryExitingAddressData.append(addressData)
			}
			
        } else {
            UserShipppingAddress.sharedInstance.billingExitingAddressData = []
            let custId = UserDefaultManager.sharedManager().loginUserId
            let custGrpId = UserDefaultManager.sharedManager().customerGroupId
			if AppManager.currentApplicationMode() == .online {
				let existingAddress = self.userExistingAddressData[self.selectedAddressIndex]
				let addressData = UserAddressData(customerId: custId!, custGrpId!, existingAddress.firstName, existingAddress.lastName, existingAddress.company, existingAddress.company_id, existingAddress.address1, existingAddress.address2, existingAddress.city, existingAddress.postCode, existingAddress.country, existingAddress.countryId, existingAddress.zone, existingAddress.zoneId, "")
				UserShipppingAddress.sharedInstance.billingExitingAddressData.append(addressData)
			} else {
				let userAddressData = Address.getAllAddressData()
				let existingAddress = userAddressData?[self.selectedAddressIndex]
				let addressData = UserAddressData(customerId: custId!, custGrpId!, existingAddress!.firstName!, existingAddress!.lastName!, existingAddress!.company!, "", existingAddress!.address1!, existingAddress!.address2!, existingAddress!.city!, existingAddress!.postCode!, existingAddress!.country!, existingAddress!.countryId!, existingAddress!.zoneName!, existingAddress!.zoneId!, "")
				UserShipppingAddress.sharedInstance.billingExitingAddressData.append(addressData)
			}
        }
    }
    
    func setDeleveryMethodData(atCell cell: DeleveryMethodTableViewCell) {
        cell.shippingRadioButton.isSelected = true
		if AppManager.getLoggedInUserType() != .salesExecutive {
			let totalPrice = self.getTotalPrice()
			if let totalCartPrice = Int(totalPrice) {
				if totalCartPrice >= 200 {
					cell.shippingTypeLabel.text = NSLocalizedString("Free Shipping", comment: "")
					cell.shippingChargesLabel.text = NSLocalizedString("Free Shipping", comment: "")
					cell.shippingPriceLabel.text = self.aramexShippingCharges
				} else {
					cell.shippingTypeLabel.text = "Aramex Shipping"
					cell.shippingChargesLabel.text = "Aramex Shipping"
					cell.shippingPriceLabel.text = self.aramexShippingCharges
				}
			}
		} else {
			cell.shippingTypeLabel.text = NSLocalizedString("Free Shipping", comment: "")
			cell.shippingChargesLabel.text = NSLocalizedString("Free Shipping", comment: "")
			cell.shippingPriceLabel.text = self.aramexShippingCharges
		}
		
    }
	
    func getSubTotal() -> String {
        var locVal: Int = 0
        for cartData in self.cartAddedData {
            if let price = Int(cartData.totalPrice!) {
                locVal = locVal + price
            }
        }
        return locVal.description
    }
    
    func getTotalPrice() -> String {
        var locVal: Int = 0
        for cartData in self.cartAddedData {
            if let price = Int(cartData.totalPrice!) {
                locVal = locVal + price
            }
        }
        locVal += self.aramexShippingCost
        
//        if let shippingCost = Int(self.free_shipping_charges) {
//            locVal += shippingCost
//        }
        if self.selectedPaymentMethod == .cod {
            if let codPrice = Int(self.codCharges) {
                locVal += codPrice
            }
        }
        return locVal.description
    }
    
    func generateTotalPrice(withSuccessHandler successHandler: ((_ success: Bool, _ value: String) -> Void)? = nil) {
	  var codPrice = ""
		if AppManager.getLoggedInUserType() == .salesExecutive {
			codPrice = "0"
		} else {
			codPrice = self.codCharges
		}
        let subTotal = self.getSubTotal()
        let syncParam = "&sub_total=\(subTotal)&cash_on_delevary_fee=\(codPrice)&coupon_amount=\(self.couponValue)&free_shipping=0&aramex_shipping=\(self.aramexShippingCost)"
        SyncManager.syncOperation(operationType: .getFinalPrice, info: syncParam) { (response, error) in
            if error == nil {
                if let responseData = response as? [String: AnyObject] {
                    if let finalPrice = responseData["final_price"] as? String {
                        successHandler?(true, finalPrice)
                    }
                }
            } else {
               successHandler?(false, "0")
            }
        }
    }
    
    func freeShippingChargesFee(withShippingType shippingType: ShippingOptions, withSuccessHandler successHandler: ((_ success: Bool, _ value: String) -> Void)? = nil) {
        let key = (shippingType == .cash_on_delevery) ? "cash_on_delivery_amount" : "free_shipping_amount"
        SyncManager.syncOperation(operationType: .getShippingCharges, info: shippingType.rawValue) { (response, error) in
            if error == nil {
                print("Shipping Charges Resp \(response)")
                if let responseObject = response as? [[String: AnyObject]] {
                    if let responseData = responseObject.first {
                        if let charges = responseData[key] as? String {
                            successHandler?(true, charges)
                        }
                    }
                }
            }
        }
    }
    
    func downloadUserExistingAddress(withSuccessHandler successHandler: SuccessHandler? = nil) {
        
        if let currentUserId = UserDefaultManager.sharedManager().loginUserId {
            SyncManager.syncOperation(operationType: .getUserExistingAddress, info: currentUserId) { (response, error) in
                if error == nil {
                    self.userExistingAddressData = []
                    if let responseData = response as? [[String: AnyObject]] {
                        for addressObj in responseData {
                            for key in addressObj.keys {
                                if let addressData = addressObj[key] as? [String: AnyObject] {
                                    let userAddress = UserAddressData(customerId: AppManager.getCustId(), AppManager.getCustGroupId(), addressData["firstname"] as? String ?? "", addressData["lastname"] as? String ?? "", addressData["company"] as? String ?? "", "", addressData["address_1"] as? String ?? "", addressData["address_2"] as? String ?? "", addressData["city"] as? String ?? "", addressData["postcode"] as? String ?? "", addressData["country"] as? String ?? "", addressData["country_id"] as? String ?? "", addressData["zone"] as? String ?? "", addressData["zone_id"] as? String ?? "", "")
                                    
                                    self.userExistingAddressData.append(userAddress)
                                    
                                }
                            }
                        }
                    }
                    successHandler?(true)
                } else {
                    successHandler?(false)
                }
            }
        }
    }
    
    func sendRemoveDropDownEvent() {
        NotificationCenter.default.post(name: Notification.Name("RemoveDropDownNotification"), object: nil)
    }
    
    func downloadBankDetails(withCimpletion completion: SuccessHandler? = nil) {
        SyncManager.syncOperation(operationType: .getBankDetails, info: "") { (response, error
            ) in
            if error == nil {
                if let htmlContent = response as? [String: AnyObject] {
                    
                    let englishDetails = htmlContent["bank_transfer_bank1"]
                    let arabicDetails = htmlContent["bank_transfer_bank2"]
                    
                    if let bankDetailsText = englishDetails as? String, let bankArDetails = arabicDetails as? String {
                        if AppManager.languageType() == .arabic {
                            self.bankDetailsText = bankArDetails
                        } else {
                            self.bankDetailsText = bankDetailsText
                        }
                    }
                    completion?(true)
                }
                
            } else {
                completion?(true)
            }
        }
    }
}

//MARK:- UITableViewDataSource
extension OrderCheckoutPageViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionHeaderInfoData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sectionHeaderInfoData[section].isTapped {
            if ((section == 1) || (section == 2) || (section == 3)) {
                return 1
            } else if (section == 4) {
                if self.getCustomerType() == .endUser {
                    return 5
                } else if self.getCustomerType() == .employee {
                    return 6
                } else {
                    return 0
                }
            } else if (section == 5) {
                if self.selectedPaymentMethod == .cod {
                    if self.isCouponApplied {
                        return self.cartAddedData.count + 1 + 3 + 1 + 1 + 1
                    } else {
                        return self.cartAddedData.count + 1 + 3 + 1 + 1
                    }
                } else if self.selectedPaymentMethod == .online {
                    if self.isCouponApplied {
                        return self.cartAddedData.count + 1 + 3 + 1 + 1
                    } else {
                        return self.cartAddedData.count + 1 + 3 + 1
                    }
                } else if self.selectedPaymentMethod == .bank {
                    if isCouponApplied {
                        return self.cartAddedData.count + 1 + 3 + 1 + 1 + 1
                    } else {
                        return self.cartAddedData.count + 1 + 3 + 1 + 1
                    }
                } else {
                    if isCouponApplied {
                        return self.cartAddedData.count + 1 + 3 + 1 + 1
                    } else {
                        return self.cartAddedData.count + 1 + 3 + 1
                    }
                }
            } else {
                return 0
            }
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: BillingDetailsTableViewCell.selfName(), for: indexPath) as? BillingDetailsTableViewCell
            cell?.cellType = .billing
            let selectedAddrType = cell?.addressInfo?.deleveryType
            if selectedAddrType == .new {
                cell?.newAddressButton.isSelected = true
                cell?.existingAddressButton.isSelected = false
            } else {
                cell?.newAddressButton.isSelected = false
                cell?.existingAddressButton.isSelected = true
            }
            cell?.billingAddressDropdown.isUserInteractionEnabled = false
			if AppManager.currentApplicationMode() == .online {
				self.downloadUserExistingAddress(withSuccessHandler: { (success) in
					if success {
						cell?.billingAddressDropdown.isUserInteractionEnabled = true
						self.setupAddressDropdown(atCell: cell!)
					} else {
						cell?.billingAddressDropdown.isUserInteractionEnabled = false
					}
				})
			} else {
				cell?.billingAddressDropdown.isUserInteractionEnabled = true
				self.setupAddressDropdown(atCell: cell!)
			}
			
            cell?.delegate = self
            return cell!
			
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: BillingDetailsTableViewCell.selfName(), for: indexPath) as? BillingDetailsTableViewCell
            cell?.cellType = .delevery
            
            let selectedAddrType = cell?.addressInfo?.deleveryType
            if selectedAddrType == .new {
                cell?.newAddressButton.isSelected = true
                cell?.existingAddressButton.isSelected = false
            } else {
                cell?.newAddressButton.isSelected = false
                cell?.existingAddressButton.isSelected = true
            }
            cell?.billingAddressDropdown.isUserInteractionEnabled = false
			if AppManager.currentApplicationMode() == .online {
				self.downloadUserExistingAddress(withSuccessHandler: { (success) in
					if success {
						cell?.billingAddressDropdown.isUserInteractionEnabled = true
						self.setupAddressDropdown(atCell: cell!)
					} else {
						cell?.billingAddressDropdown.isUserInteractionEnabled = false
					}
				})
			} else {
				cell?.billingAddressDropdown.isUserInteractionEnabled = true
				self.setupAddressDropdown(atCell: cell!)
			}
			
            cell?.delegate = self
            return cell!
        } else if indexPath.section == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: DeleveryMethodTableViewCell.selfName(), for: indexPath) as? DeleveryMethodTableViewCell
            self.setDeleveryMethodData(atCell: cell!)
            cell?.delegate = self
            return cell!
        } else if indexPath.section == 4 {
            if self.getCustomerType() == .employee {
                if (indexPath.row == 0) {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "NormalCell", for: indexPath)
                    cell.textLabel?.text = NSLocalizedString("Please select the preferred payment method to use on this order.",comment: "")
                    cell.textLabel?.numberOfLines = 0
                    cell.textLabel?.font = UIFont.systemFont(ofSize: 10.0)
                    return cell
                } else if indexPath.row == 5 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: CommetsTableViewCell.selfName(), for: indexPath) as? CommetsTableViewCell
                    cell?.delegate = self
                    return cell!
                }  else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: PaymentMethodTableViewCell.selfName(), for: indexPath) as? PaymentMethodTableViewCell
                    if self.selectedPaymentMethod.rawValue == PaymentMethodTypes.caseValues[indexPath.row].rawValue {
                        cell?.paymentMethodButton.isSelected = true
                    } else {
                        cell?.paymentMethodButton.isSelected = false
                    }
                    let paymentMethod = PaymentMethodTypes.caseValues[indexPath.row].rawValue
                    let paymentMethodLocalizedText = NSLocalizedString(paymentMethod, comment: "")
                    cell?.paymentMethodTypeLabel.text = paymentMethodLocalizedText
                    return cell!
                }
            } else {
                if (indexPath.row == 0) {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "NormalCell", for: indexPath)
                    cell.textLabel?.text = NSLocalizedString("Please select the preferred payment method to use on this order.", comment: "")
                    
                    return cell
                    
                } else if indexPath.row == 4 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: CommetsTableViewCell.selfName(), for: indexPath) as? CommetsTableViewCell
                    cell?.delegate = self
                    return cell!
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: PaymentMethodTableViewCell.selfName(), for: indexPath) as? PaymentMethodTableViewCell
                    
                    if self.selectedPaymentMethod.rawValue == PaymentMethodTypes.caseValues[indexPath.row].rawValue {
                        cell?.paymentMethodButton.isSelected = true
                    } else {
                        cell?.paymentMethodButton.isSelected = false
                    }
                    let paymentMethod = PaymentMethodTypes.caseValues[indexPath.row].rawValue
                    let paymentMethodLocalizedText = NSLocalizedString(paymentMethod, comment: "")

                    cell?.paymentMethodTypeLabel.text = paymentMethodLocalizedText
                    return cell!
                }
            }
        } else if indexPath.section == 5 {
            
            if indexPath.row == 0 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: ReviewTableViewCell.selfName(), for: indexPath) as? ReviewTableViewCell
                /* cell?.productNameLabel.text = "Product Name"
                cell?.productModelLabel.text = "Model"
                cell?.productQtyLabel.text = "Quantity"
                cell?.productUnitPriceLabel.text = "Unit Price"
                cell?.productTotalPriceLabel.text = "Total" */
                
                return cell!
                
            } else if ((indexPath.row != 0) && (indexPath.row <= self.cartAddedData.count)) {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: CalculationTableViewCell.selfName(), for: indexPath) as? CalculationTableViewCell

                cell?.productNameLabel.text = self.cartAddedData[indexPath.row - 1].name
                cell?.productModelLabel.text = "DOSE12XC4333"
                cell?.productQtyLabel.text = self.cartAddedData[indexPath.row - 1].quantity
                cell?.productUnitPriceLabel.text = self.cartAddedData[indexPath.row - 1].unitPrice
                cell?.productTotalPriceLabel.text = self.cartAddedData[indexPath.row - 1].totalPrice
                
                return cell!
            } else {
                let totalRows = self.orderCheckoutTableView.numberOfRows(inSection: indexPath.section)
                if self.selectedPaymentMethod != .online {
                    
                    if indexPath.row != totalRows - 1 {
                        self.setArrayData()
                        if self.selectedPaymentMethod == .bank {
                            if self.calculationStrArray.count + 1 == indexPath.row {
                                let cell = tableView.dequeueReusableCell(withIdentifier: BankTransferDetailsCell.selfName(), for: indexPath) as? BankTransferDetailsCell
                                cell?.delegate = self
                                cell?.bankDetailsLabel.text = self.bankDetailsText
                                return cell!
                                
                            } else {
                                let cell = tableView.dequeueReusableCell(withIdentifier: FinalPriceTableViewCell.selfName(), for: indexPath) as? FinalPriceTableViewCell
                                let string = NSLocalizedString(self.calculationStrArray[indexPath.row - (self.cartAddedData.count + 1)], comment: "")
                                cell?.productUnitPriceLabel.text = string
                                let valueString = NSLocalizedString(self.valueArray[indexPath.row - (self.cartAddedData.count + 1)], comment: "")
                                cell?.productTotalPriceLabel.text = valueString
                                
                                return cell!
                            }
                        }
                        let cell = tableView.dequeueReusableCell(withIdentifier: FinalPriceTableViewCell.selfName(), for: indexPath) as? FinalPriceTableViewCell
                        cell?.productUnitPriceLabel.text = self.calculationStrArray[indexPath.row - (self.cartAddedData.count + 1)]
                        cell?.productTotalPriceLabel.text = self.valueArray[indexPath.row - (self.cartAddedData.count + 1)]
                        
                        return cell!
                    } else {
                        let cell = tableView.dequeueReusableCell(withIdentifier: ConfirmOderTableViewCell.selfName(), for: indexPath) as? ConfirmOderTableViewCell
                        cell?.confirmOrderDelegate = self
                        return cell!
                    }
                } else {
                    if indexPath.row < totalRows - 1 {
                        self.setArrayData()
                        let cell = tableView.dequeueReusableCell(withIdentifier: FinalPriceTableViewCell.selfName(), for: indexPath) as? FinalPriceTableViewCell
                        cell?.productUnitPriceLabel.text = self.calculationStrArray[indexPath.row - (self.cartAddedData.count + 1)]
                        cell?.productTotalPriceLabel.text = self.valueArray[indexPath.row - (self.cartAddedData.count + 1)]
                        
                        return cell!
                    } else {
                        
                        if indexPath.row == totalRows - 1 {
                            
                            
                            let cell = tableView.dequeueReusableCell(withIdentifier: ProceedToPaymentTableViewCell.selfName(), for: indexPath) as? ProceedToPaymentTableViewCell
                            cell?.paymentDelegate = self
                            return cell!
                        } else {
                            let cell = tableView.dequeueReusableCell(withIdentifier: "NormalCell", for: indexPath)
                            cell.textLabel?.text = "test"
                            return cell
                        }
                    }
                }
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NormalCell", for: indexPath)
             cell.textLabel?.text = "test"
             return cell
        }
    }
}

//MARK:- UITableViewDelegate
extension OrderCheckoutPageViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let sectionHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: CheckOutStepsHeaderView.selfName()) as? CheckOutStepsHeaderView
        sectionHeader?.sectionDelegate = self
        let step = self.sectionHeaderInfoData[section].sectionName
        let localizedName = NSLocalizedString(step, comment: "")
        sectionHeader?.chekoutHeaderStepTitleButton.tag = section
        sectionHeader?.chekoutHeaderStepTitleButton.setTitle(localizedName, for: .normal)
        
        return sectionHeader
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if UIDevice.current.userInterfaceIdiom == .pad {
			return 75.0
		} else {
			return 44.0
		}
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 4 {
            
            if self.getCustomerType() == .employee {
                if ((indexPath.row != 0) && (indexPath.row != 6) && (indexPath.row != 5) && (indexPath.row != 7)) {
                    
                    self.selectedPaymentMethod = PaymentMethodTypes.caseValues[indexPath.row]
                    let indexSet: IndexSet = [indexPath.section]
                    self.orderCheckoutTableView.reloadSections(indexSet, with: .automatic)
                }
            } else {
                if ((indexPath.row != 0) && (indexPath.row != 5) && (indexPath.row != 4)) {
                    
                    self.selectedPaymentMethod = PaymentMethodTypes.caseValues[indexPath.row]
                    let indexSet: IndexSet = [indexPath.section]
                    self.orderCheckoutTableView.reloadSections(indexSet, with: .automatic)
                }
            }
        }
    }
}

extension OrderCheckoutPageViewController: SectionHeaderDelegate {
    
    func sectionTitleTapped(atSection section: Int) {
        self.sendRemoveDropDownEvent()
        if self.sectionHeaderInfoData[section].nextStep {
            self.sectionHeaderInfoData[section].isTapped = !self.sectionHeaderInfoData[section].isTapped
            
            for (index, _) in self.sectionHeaderInfoData.enumerated() {
                if index != section {
                    self.sectionHeaderInfoData[index].isTapped = false
                }
            }
            self.orderCheckoutTableView.reloadData()
        }
    }
}

extension OrderCheckoutPageViewController: BillingStepDelegate {
    
	func didTapContinueButton(atCell cell: BillingDetailsTableViewCell, withUserAddressInfo addressInfo: AddressCellData) {
		if addressInfo.addressType == .billing {
			self.billingAddressInfo = addressInfo
			if addressInfo.deleveryType == .existing {
				self.handleAddressSave()
			}
			
			if let indexPath = self.orderCheckoutTableView.indexPath(for: cell) {
				self.sectionHeaderInfoData[indexPath.section + 1].nextStep = true
				self.goToNextStep(atSection: indexPath.section)
			}
		} else {
			self.deleveryAddressInfo = addressInfo
			if addressInfo.deleveryType == .existing {
				self.handleAddressSave()
			}
			
			let totalPrice = self.getTotalPrice()
			if AppManager.currentApplicationMode() == .online {
				self.freeShippingChargesFee(withShippingType: .free_shipping, withSuccessHandler: { (success, value) in
					if success {
						
						if let totalCartPrice = Int(totalPrice) {
							if AppManager.getLoggedInUserType() != .salesExecutive {
								if totalCartPrice < Int(value)! {
									self.shippingChargesLabel = "Aramex Shipping:"
									self.shippingType = .aramex_shipping
									self.shipping_code = .aramex
									self.getAramexPrice(withCompletionHandler: { (success) in
										if success {
											if let indexPath = self.orderCheckoutTableView.indexPath(for: cell) {
												self.sectionHeaderInfoData[indexPath.section + 1].nextStep = true
												self.goToNextStep(atSection: indexPath.section)
											}
										}
									})
								} else {
									self.shippingChargesLabel = "Free Shipping:"
									self.aramexShippingCharges = "S.R 0"
									self.shippingType = .free_shipping
									self.shipping_code = .free
									self.free_shipping_charges = value
									if let indexPath = self.orderCheckoutTableView.indexPath(for: cell) {
										self.sectionHeaderInfoData[indexPath.section + 1].nextStep = true
										self.goToNextStep(atSection: indexPath.section)
									}
								}
							} else {
								self.shippingChargesLabel = "Free Shipping:"
								self.aramexShippingCharges = "S.R 0"
								self.shippingType = .free_shipping
								self.shipping_code = .free
								self.free_shipping_charges = value
								if let indexPath = self.orderCheckoutTableView.indexPath(for: cell) {
									self.sectionHeaderInfoData[indexPath.section + 1].nextStep = true
									self.goToNextStep(atSection: indexPath.section)
								}
							}
							
						}
					}
				})
			} else {
				self.shippingChargesLabel = "Free Shipping:"
				self.aramexShippingCharges = "S.R 0"
				self.shippingType = .free_shipping
				self.shipping_code = .free
				self.free_shipping_charges = "0.0"
				if let indexPath = self.orderCheckoutTableView.indexPath(for: cell) {
					self.sectionHeaderInfoData[indexPath.section + 1].nextStep = true
					self.goToNextStep(atSection: indexPath.section)
				}
			}
		}
	}
	
    func didTapNewAddressButton(atCell cell: BillingDetailsTableViewCell) {
        if cell.cellType == .billing {
            self.newAddressAction(withAddressType: .billing)
        } else {
            self.newAddressAction(withAddressType: .delevery)
        }
    }
}

extension OrderCheckoutPageViewController: DeleveryStepDelegate {
	
    func didTapDeleveryContinueButton(atCell cell: DeleveryMethodTableViewCell) {
        if self.getCustomerType() == .salesExecutive {
			if AppManager.currentApplicationMode() == .online {
				self.downloadBankDetails(withCimpletion: { (success) in
					if success {
						if let indexPath = self.orderCheckoutTableView.indexPath(for: cell) {
							self.sectionHeaderInfoData[indexPath.section + 2].nextStep = true
							self.selectedPaymentMethod = .bank
							self.freeShippingChargesFee(withShippingType: .free_shipping, withSuccessHandler: { (success, price) in
								if success {
									self.codCharges = price
									self.generateTotalPrice(withSuccessHandler: { (success, value) in
										if success {
											self.finalTotalPrice = value
											self.goToNextStep(atSection: indexPath.section)
										}
									})
								}
							})
						}
					}
				})
			} else {
				if let indexPath = self.orderCheckoutTableView.indexPath(for: cell) {
					self.sectionHeaderInfoData[indexPath.section + 2].nextStep = true
					self.selectedPaymentMethod = .bank
					self.finalTotalPrice = self.getTotalPrice()
					self.goToNextStep(atSection: indexPath.section)
				}
			}
        } else {
            if let indexPath = self.orderCheckoutTableView.indexPath(for: cell) {
                self.sectionHeaderInfoData[indexPath.section + 1].nextStep = true
                self.goToNextStep(atSection: indexPath.section)
				self.finalTotalPrice = self.getTotalPrice()
					//self.goToNextStep(atSection: indexPath.section)
            }
        }
    }
}

extension OrderCheckoutPageViewController: CommentsStepDelegate {
    
    func didTapCommentsContinueButton(atCell cell: CommetsTableViewCell) {
			if cell.termsAndConditionsCheckbox.isChecked {
				if let indexPath = self.orderCheckoutTableView.indexPath(for: cell) {
					if self.selectedPaymentMethod == .cod {
						self.freeShippingChargesFee(withShippingType: .cash_on_delevery, withSuccessHandler: { (success, price) in
							if success {
								self.codCharges = price
								self.generateTotalPrice(withSuccessHandler: { (success, value) in
									if success {
										self.finalTotalPrice = value
										self.sectionHeaderInfoData[indexPath.section + 1].nextStep = true
										self.goToNextStep(atSection: indexPath.section)
									}
								})
							}
						})
					} else if self.selectedPaymentMethod == .bank {
						self.downloadBankDetails(withCimpletion: { (success) in
							if success {
								self.generateTotalPrice(withSuccessHandler: { (success, value) in
									if success {
										print("Final Price: \("")")
										self.finalTotalPrice = value
										self.sectionHeaderInfoData[indexPath.section + 1].nextStep = true
										self.goToNextStep(atSection: indexPath.section)
									}
								})
							}
						})
					} else {
						self.generateTotalPrice(withSuccessHandler: { (success, value) in
							if success {
								print("Final Price: \("")")
								self.finalTotalPrice = value
								self.sectionHeaderInfoData[indexPath.section + 1].nextStep = true
								self.goToNextStep(atSection: indexPath.section)
							}
						})
					}
				}
			} else {
					ALAlerts.showToast(message: "Please agree to terms and Conditions")
			}
		}
	
    func didTapDoneButton(atCell cell: CommetsTableViewCell) {
			
        if let userCommentText = cell.commentsTextView.text {
            self.userComments = userCommentText
        }
    }
	
    func didTapPolicyButton() {
        if let policyVc = self.storyboard?.instantiateViewController(withIdentifier: "PolicyViewController") as? PolicyViewController {
            policyVc.delegate = self
            self.navigationController?.tabBarController?.tabBar.isHidden = true
            policyVc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            self.present(policyVc, animated: true, completion: nil)
        }
    }
}

extension OrderCheckoutPageViewController: DropDownMenuViewDelegate {
    
    func menuDropDownSelected(index: Int, withSectionId id: String?) {
        self.selectedAddressIndex = index
        self.handleAddressSave()
    }
}

extension OrderCheckoutPageViewController: PolicyHandlerDelegate {
    
    func didPolicyCloseButtonTapped() {
        self.navigationController?.tabBarController?.tabBar.isHidden = false
    }
}

extension OrderCheckoutPageViewController: PaymentActionDelegate {
    
    func didTapProceedToPaymentButton(atCell cell: ProceedToPaymentTableViewCell) {
        ProgressIndicatorController.showLoading()
        let deviceid = UIDevice.current.identifierForVendor!.uuidString
        let access_code = NSLocalizedString("ACCESS_CODE_PRODUCTION", comment: "")
        //let merchant_identifier = NSLocalizedString("merchant_identifier", comment: "")
		let merchant_identifier = NSLocalizedString("MERCHANT_IDENTIFIER_PRODUCTION", comment: "")
        let str="TESTSHAINaccess_code="+access_code+"device_id="+deviceid+"language=enmerchant_identifier="+merchant_identifier+"service_command=SDK_TOKENTESTSHAIN"
//		let str="KFUPMaccess_code="+access_code+"device_id="+deviceid+"language=enmerchant_identifier="+merchant_identifier+"service_command=SDK_TOKENTESTSHAIN"
        print("str--\(str)")
		
        let signature=self.digest(input: str.data(using: String.Encoding.utf8)!)
        
        let signaturestring = getHexString(fromData: signature)
        self.signatureValue = signaturestring
        //self.createTokenId()
		self.getSDKToken()
        
    }
    
    private func digest(input : Data) -> Data {
        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
        var hashValue = [UInt8](repeating: 0, count: digestLength)
        input.withUnsafeBytes {
            _ = CC_SHA256($0, CC_LONG(input.count), &hashValue)
        }
        
        return Data(bytes: hashValue)
    }
    
    func getHexString(fromData data: Data) -> String {
        var bytes = [UInt8](repeating: 0, count: data.count)
        data.copyBytes(to: &bytes, count: data.count)
        
        var hexString = ""
        for byte in bytes {
            hexString += String(format:"%02x", UInt8(byte))
        }
        return hexString
    }
	
	func getSDKToken() {
		let currerntLanguage = (AppManager.languageType() == .arabic) ? "ar" : "en"
		let deviceid = UIDevice.current.identifierForVendor!.uuidString
		let access_code = NSLocalizedString("access_code", comment: "")
		let merchant_identifier = NSLocalizedString("merchant_identifier", comment: "")
		let syncParam = "merchant_identifier=\(merchant_identifier)&service_command=SDK_TOKEN&device_id=\(deviceid)&language=\(currerntLanguage)&access_code=\(access_code)"
		SyncManager.syncOperation(operationType: .generateSDKToken, info: syncParam) { (response, error) in
			if error == nil {
				ProgressIndicatorController.dismissProgressView(withSuccessHandler: { (success) in
					if success {
						print("SDK Token Response: \(response)")
						if let responseObject = response as? [String: AnyObject] {
							if let sdkResponse = responseObject["response"] {
								if let sdkToekn = sdkResponse["sdk_token"] as? String {
									print("SDK Token: \(sdkToekn)")
									
									self.sdkTokenValue = sdkToekn
									
									
									let date = Date()
									let calendar = Calendar.current
									let hour = calendar.component(.hour, from: date)
									let minutes = calendar.component(.minute, from: date)
									let seconds = calendar.component(.second, from: date)
									
									let userDefaults = UserDefaultManager.sharedManager()
									
									
									let userId=userDefaults.loginUserId! as String
									let userName=userDefaults.loginUserName! as String
									
									let formatter = DateFormatter()
									formatter.dateFormat = "ddMMyyyy"
									let dateresult = formatter.string(from: date)
									
									let strHour = String(hour)
									let strMin = String(minutes)
									let strSec = String(seconds)
									
									let merchant_reference = userId+"_"+dateresult+strHour+strMin+strSec
									
									self.merchantReference = merchant_reference
									
									self.onlinePaymentProcess()
								}
							}
						}
					}
				})
			} else {
				ProgressIndicatorController.dismissProgressView()
			}
		}
	}
	
    func createTokenId()
    {
        let userDefaults = UserDefaultManager.sharedManager()
        let userEmail=userDefaults.customerEmail! as String
        let configuration = URLSessionConfiguration .default
        let session = URLSession(configuration: configuration)
        let deviceid = UIDevice.current.identifierForVendor!.uuidString
		//let access_code = NSLocalizedString("access_code", comment: "")
        let access_code = NSLocalizedString("ACCESS_CODE_PRODUCTION", comment: "")
        let merchant_identifier = NSLocalizedString("MERCHANT_IDENTIFIER_PRODUCTION", comment: "")
        let params = ["access_code":access_code as AnyObject,"device_id":deviceid as AnyObject, "language":"en" as AnyObject, "merchant_identifier":merchant_identifier as AnyObject, "service_command":"SDK_TOKEN" as AnyObject,"signature":self.signatureValue as AnyObject] as Dictionary<String, AnyObject>
        print("params\(params)")
		//For Production - Live:
		//https://paymentservices.payfort.com/FortAPI/paymentApi
		
		//For Development - Testing 
		//https://sbpaymentservices.payfort.com/FortAPI/paymentApi
		//Moving to Live as per Azeem Sir Instruction - 09-Oct-2017
        let urlString = NSString(format: "https://paymentservices.payfort.com/FortAPI/paymentApi");
        print("url string is \(urlString)")
        let request : NSMutableURLRequest = NSMutableURLRequest()
        
        request.url = NSURL(string: NSString(format: "%@", urlString)as String) as URL?
        
        request.httpMethod = "POST"
        request.timeoutInterval = 30
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody  = try! JSONSerialization.data(withJSONObject: params, options: [])
        
        
        let dataTask = session.dataTask(with: request as URLRequest)
        {
            ( data: Data?, response: URLResponse?, error: Error?) -> Void in
            // 1: Check HTTP Response for successful GET request
            guard let httpResponse = response as? HTTPURLResponse, let receivedData = data
                else {
                    print("error: not a valid http response")
                    return
            }
            
            switch (httpResponse.statusCode)
            {
            case 200:
                
                let response = NSString (data: receivedData, encoding: String.Encoding.utf8.rawValue)
                //var td_value=[String:AnyObject]()
                print("response\(response)")
                let td_value = response?.components(separatedBy: ",")
                
                
                let resp = td_value?[2].components(separatedBy: ":")
                let resp_msg=resp![1] as String
                let resp_msg_trim=resp_msg.trimmingCharacters(in: .whitespaces)
                
                let sdk_token=td_value?[4].components(separatedBy: ":")
                let sdk_tokenVal=sdk_token![1].trimmingCharacters(in: .whitespaces)
                
                //print("resp_msg==\(resp_msg_trim)")
                
                let resp_msg_status = resp_msg_trim.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range:nil)
                
                if resp_msg_status == "Success"
                {
                    self.sdkTokenValue = sdk_tokenVal
                    
                    
                    let date = Date()
                    let calendar = Calendar.current
                    let hour = calendar.component(.hour, from: date)
                    let minutes = calendar.component(.minute, from: date)
                    let seconds = calendar.component(.second, from: date)
                    
                    let userDefaults = UserDefaultManager.sharedManager()
                    
                    
                    let userId=userDefaults.loginUserId! as String
                    let userName=userDefaults.loginUserName! as String
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "ddMMyyyy"
                    let dateresult = formatter.string(from: date)
                    
                    let strHour = String(hour)
                    let strMin = String(minutes)
                    let strSec = String(seconds)
                    
                    let merchant_reference = userId+"_"+dateresult+strHour+strMin+strSec
                    
                    self.merchantReference = merchant_reference
                    
                    self.onlinePaymentProcess()
				} else {
					ProgressIndicatorController.dismissProgressView(withSuccessHandler: { (success) in
						if success {
							ALAlerts.showToast(message: "Channed Not Configured for Live mode")
						}
					})
				}
				
				
            default:
                print("save profile POST request got response \(httpResponse.statusCode)")
            }
        }
        dataTask.resume()
        
    }
    
    func onlinePaymentProcess()
    {
        AppDelegate.delegate().isOnlinePaymentInitiated = true
        let userDefaults = UserDefaultManager.sharedManager()
        let userLang=userDefaults.selectedLanguageId
        
        let userEmail=userDefaults.customerEmail! as String
        
        let totalPrice = finalTotalPrice.replacingOccurrences(of: ".", with: "", options: NSString.CompareOptions.literal, range:nil)
        let lang : String
//        let PayFort = PayFortController.init(enviroment:KPayFortEnviromentProduction)
        let PayFort = PayFortController.init(enviroment:KPayFortEnviromentSandBox)
        //PayFort?.hideLoading = true;
        //let sdktoken = sdk_token
        PayFort?.setPayFortCustomViewNib("PayFortView2")
        if(userLang == "English")
        {
            
            lang = "en"
        }
        else
        {
            lang = "ar"
        }
        
        //PayFort?.isShowResponsePage = true;
        let sdktoken = self.sdkTokenValue.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range:nil)
        
        let request = NSMutableDictionary.init()
        request.setValue(totalPrice, forKey: "amount")
        request.setValue("PURCHASE", forKey: "command")
        request.setValue("SAR", forKey: "currency")
        request.setValue(userEmail, forKey: "customer_email")
        request.setValue(lang, forKey: "language")
        
        
        request.setValue(sdktoken, forKey: "sdk_token")
        request.setValue(self.merchantReference, forKey: "merchant_reference")
        print("request value\(request)")
        
        
        
        DispatchQueue.main.async {
            ProgressIndicatorController.dismissProgressView()
            PayFort?.callPayFort(withRequest: request, currentViewController: self,
                                 success: { (requestDic, responeDic) in
                                    print("success")
                                    self.sdkTokenValue = ""
                                    self.merchantReference = ""
                                    
                                    self.placeOrder { (success) in
                                        if success {
                                            AppDelegate.delegate().isOnlinePaymentInitiated = false
                                            print("Order Placed Successfully")
                                        } else {
                                            AppDelegate.delegate().isOnlinePaymentInitiated = false
                                            print("Order Placed not Successfully")
                                        }
                                    }
                                    
            },
                                 canceled: { (requestDic, responeDic) in
                                    print("canceled")
                                    AppDelegate.delegate().isOnlinePaymentInitiated = false
                                    
            },
                                 faild: { (requestDic, responeDic, message) in
                                    
                                    ALAlerts.showToast(message: "Your credit card has been declined. Please revise your payment")
                                    AppDelegate.delegate().isOnlinePaymentInitiated = false
                                    ProgressIndicatorController.showLoading()
                                    self.createTokenId()
                                    //PayFort?.isShowResponsePage = true;
                                    print("responeDic==\(responeDic)")
            })
        }
    }
}

extension OrderCheckoutPageViewController: ConfirmOrderDelegate {
    
    func confirmOrderButtonTapped(atCell cell: ConfirmOderTableViewCell) {
        self.placeOrder { (success) in
            if success {
                DispatchQueue.main.async {
                    cell.confirmOrderButton.isEnabled = true
                }
            } else {
                DispatchQueue.main.async {
                    cell.confirmOrderButton.isEnabled = true
                }
            }
        }
    }
}

//MARK:- Address Handler Methods:
extension OrderCheckoutPageViewController {
    
    func getSyncParameters() -> String {
        
        let deleveryTypeAddress: UserAddressData!
        
        if self.deleveryAddressInfo?.deleveryType == .existing {
            deleveryTypeAddress = UserShipppingAddress.sharedInstance.deleveryExitingAddressData[0]
        } else {
            deleveryTypeAddress = UserShipppingAddress.sharedInstance.deleveryNewAddressData[0]
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
    
    func getAramexPrice(withCompletionHandler successHandler: @escaping SuccessHandler) {
        
        //self.aramexChargesTaken = true
        let syncParameterInfo = self.getSyncParameters()
        SyncManager.syncOperation(operationType: .aramexShipping, info: syncParameterInfo, completionHandler: { (response, error) in
            if error == nil {
                
                print("Aramex Charges Data \(response)")
                if let aramexResponse = response as? [String: AnyObject] {
                    if let aramexBaseDict = aramexResponse["wk_aramex"] as? [String: AnyObject] {
                        if let error = aramexBaseDict["error"] as? String, error != "" {
                            let alertControlller = UIAlertController(title: Constants.alertTitle, message: error, preferredStyle: .alert)
                            let okAction = UIAlertAction(title: Constants.alertAction, style: .default, handler: nil)
                            alertControlller.addAction(okAction)
                            successHandler(false)
                            self.present(alertControlller, animated: true, completion: nil)
                        } else {
                            successHandler(true)
                            if let quoteDict = aramexBaseDict["quote"] as? [String: AnyObject] {
                                if let aramexInfo = quoteDict["wk_aramex"] as? [String: AnyObject] {
                                    if let aramexCostText = aramexInfo["text"] as? String {
                                        self.aramexShippingCharges = aramexCostText
                                        self.valueArray = [self.getSubTotal(), self.aramexShippingCharges, self.getTotalPrice()]
                                        if let aramesCostPrice = aramexInfo["cost"] as? Int {
                                            self.aramexShippingCost = aramesCostPrice
                                            print("Aramex Price: \(aramesCostPrice)")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        })
    }
    
    func placeOrder(withCompletion successHandler: SuccessHandler? = nil) {
        let deleveryTypeAddress: UserAddressData!
        let billingTypeAddress: UserAddressData!
        
        if billingAddressInfo?.deleveryType == .existing {
            billingTypeAddress = UserShipppingAddress.sharedInstance.billingExitingAddressData[0]
        } else {
            billingTypeAddress = UserShipppingAddress.sharedInstance.billingNewAddressData[0]
        }
        
        if deleveryAddressInfo?.deleveryType == .existing {
            deleveryTypeAddress = UserShipppingAddress.sharedInstance.deleveryExitingAddressData[0]
        } else {
            deleveryTypeAddress = UserShipppingAddress.sharedInstance.deleveryNewAddressData[0]
        }
        
        //Coupon Parameters:
        var couponName: String = ""
        var couponAmount: String = ""
        
        if let couponNameStr = self.couponCodeInfo["CouponName"] as? String, let couponAmountStr = self.couponCodeInfo["CouponAmount"] as? String {
            couponName = couponNameStr
            couponAmount = couponAmountStr
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
        
//        var codCharges = ""
//        if self.selectedPaymentMethod == .cod {
//            codCharges = "18"
//        } else {
//            codCharges = "0"
//        }

        
        var paymentCode = ""
        switch self.selectedPaymentMethod {
        case .bank:
            paymentCode = PaymentCode.bankTransfer.rawValue
        case .cod:
            paymentCode = PaymentCode.cashOnDelevery.rawValue
        case .online:
            paymentCode = PaymentCode.onlinePayment.rawValue
        case .salary:
            paymentCode = PaymentCode.salaryDeduction.rawValue
        default:
            break
        }
			
			if AppManager.getLoggedInUserType() == .salesExecutive {
				paymentCode = PaymentCode.bankTransfer.rawValue
			}
			
        let subTotal = self.getSubTotal()
        let languageId = (AppManager.languageType() == .arabic) ? "2" : "1"
        let syncParameter1 = "customer_id=\(billingTypeAddress.customerId)&customer_group_id=\(billingTypeAddress.customerGroupId)&firstname=\(fName)&lastname=\(lName)&email=\(userEmail)&telephone=\(userPhone)&fax=\(userPhone)&reward=\("0")&payment_firstname=\(billingTypeAddress.firstName)&payment_lastname=\(billingTypeAddress.lastName)&payment_company=\("")&payment_company_id=\("17")&payment_address_1=\(billingTypeAddress.address1)&payment_address_2=\(billingTypeAddress.address2)&payment_city=\(billingTypeAddress.city)&payment_postcode=\(billingTypeAddress.postCode)&payment_country=\(billingTypeAddress.country)&payment_country_id=\(billingTypeAddress.countryId)&payment_tax_id=\("0")&payment_zone=\(billingTypeAddress.city)&payment_zone_id=\(billingTypeAddress.zoneId)&payment_method=\(self.selectedPaymentMethod.rawValue)&payment_code=\(paymentCode)&"
        
        let syncParameter2 = "shipping_firstname=\(deleveryTypeAddress.firstName)&shipping_lastname=\(deleveryTypeAddress.lastName)&shipping_company=\("")&shipping_company_id=\("")&shipping_address_1=\(deleveryTypeAddress.address1)&shipping_address_2=\(deleveryTypeAddress.address2)&shipping_city=\(deleveryTypeAddress.city)&shipping_postcode=\(deleveryTypeAddress.postCode)&shipping_country=\(deleveryTypeAddress.country)&shipping_country_id=\(deleveryTypeAddress.countryId)&shipping_tax_id=\("0")&shipping_zone=\(deleveryTypeAddress.city)&total=\("0")&shipping_method=\(self.shippingType.rawValue)&shipping_code=\(self.shipping_code.rawValue)&shipping_zone_id=\(deleveryTypeAddress.zoneId)&total=\(subTotal)&language_id=\(languageId)&cash_on_delivery=\(codCharges)&aramex=\(self.aramexShippingCost)&final_total=\(self.finalTotalPrice)&free_shipping=0&comment=\(self.userComments)&coupon_amount=\(self.couponValue)&coupon_name=\(self.coponCode)&free_shipping=\("")"
        
        let finalParameter = syncParameter1 + syncParameter2
		
		if AppManager.currentApplicationMode() == .online {
			SyncManager.syncOperation(operationType: .placeOrder, info: finalParameter, completionHandler: { (response, error) in
				
				if error == nil {
					successHandler?(true)
					print("Response : \(response)")
					if let response = response as? [String: AnyObject] {
						if let successMessage = response["success"] as? String {
							let alertController = UIAlertController(title: Constants.alertTitle, message: successMessage, preferredStyle: .alert)
							let okAction = UIAlertAction(title: Constants.alertAction, style: .default, handler: { (UIAlertAction) in
								let _ = self.navigationController?.popToRootViewController(animated: true)
								var menuTappedInfo = [String: AnyObject]()
								let tappedFieldInfo = LoggedInUser.OrderHistory
								menuTappedInfo = [Constants.keyLogin: tappedFieldInfo as AnyObject]
								
								NotificationCenter.default.post(name: Notification.Name(Constants.sliderMenuFieldTapNotification), object: nil, userInfo: menuTappedInfo)
								NotificationCenter.default.post(name: Notification.Name("UpdateProductCartStatus"), object: nil)
							})
							alertController.addAction(okAction)
							self.present(alertController, animated: true, completion: nil)
						}
					}
				} else {
					successHandler?(false)
					print("Error: \(error)")
				}
			})
		} else {
			var orderData = [String: AnyObject]()
			orderData["offline_order"] = finalParameter as AnyObject?
			
			var offlineProducts = [String: AnyObject]()
			var offlineProductsArray = [[String: AnyObject]]()
			for product in self.cartAddedData {
			   offlineProducts["product_id"] = product.productId as AnyObject?
				offlineProducts["quantity"] = product.quantity as AnyObject?
				
				offlineProductsArray.append(offlineProducts)
			}
			orderData["OfflineProducts"] = offlineProductsArray as AnyObject?
			
			
			
			MagicalRecord.save({ (context) in
				Orders.mr_import(from: orderData, in: context)
			}, completion: { (success, error) in
				if success {
					let orderSuccessMessage = NSLocalizedString("ORDER_SUCCESS_ALERT", comment: "")
					let alertController = UIAlertController(title: Constants.alertTitle, message: orderSuccessMessage, preferredStyle: .alert)
					let okAction = UIAlertAction(title: Constants.alertAction, style: .default, handler: { (UIAlertAction) in
						let _ = self.navigationController?.popToRootViewController(animated: true)
						var menuTappedInfo = [String: AnyObject]()
						let tappedFieldInfo = LoggedInUser.OrderHistory
						menuTappedInfo = [Constants.keyLogin: tappedFieldInfo as AnyObject]
						MyCart.removeAllMyCartListData()
						
						NotificationCenter.default.post(name: Notification.Name(Constants.sliderMenuFieldTapNotification), object: nil, userInfo: menuTappedInfo)
						NotificationCenter.default.post(name: Notification.Name("UpdateProductCartStatus"), object: nil)
					})
					alertController.addAction(okAction)
					self.present(alertController, animated: true, completion: nil)
				} else {
					ALAlerts.showToast(message: "Error Placing the order")
				}
			})
		}
    }
}

//MARK:- KeyBoard Handler Methods:
extension OrderCheckoutPageViewController {
	
    func keyBoardWillShow(notification: Notification) {
        if let keyBoardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyBoardSize.height, right: 0.0)
            
            self.orderCheckoutTableView.contentInset = contentInset
            self.orderCheckoutTableView.scrollIndicatorInsets = contentInset
            let indexPath = IndexPath(row: 2, section: 4)
            
            //self.orderCheckoutTableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
    
    func keyBoardWillCollapse(notification: Notification) {
        self.orderCheckoutTableView.contentInset = UIEdgeInsets.zero
        self.orderCheckoutTableView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
}

//MARK:- AddressDataDelegate
extension OrderCheckoutPageViewController: AddressDataDelegate {
    func didFinishPickingAddress() {
        self.showTabBar()
        self.downloadUserExistingAddress { (success) in
            if success {
                self.orderCheckoutTableView.reloadData()
            }
        }
    }
}

//MARK:- BankDetailsDelegate
extension OrderCheckoutPageViewController: BankDetailsDelegate {
    func didTapBankDetailsButton() {
        if let bankDetailsVc = self.storyboard?.instantiateViewController(withIdentifier: BankDetailsViewController.selfName()) as? BankDetailsViewController {
            
            self.navigationController?.pushViewController(bankDetailsVc, animated: true)
        }
    }
}
