//
//  OrdersDetailViewController.swift
//  Alzahrani
//
//  Created by shilpa shree on 5/29/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

enum OrderDetailTyps {
    
    case SubTotal, COD, FreeShipping, Total
}

struct OrderDetailData {
    
    let text: String?
    let title: String?
    let type: OrderDetailTyps?
    
    init(_ text: String, _ title: String, withType type: OrderDetailTyps) {
        self.text = text
        self.title = title
        self.type = type
    }
}

struct TotalFieldsData {
    
    var fieldName: String
    var fieldValue: String
    
    init(withFieldName name: String, andFieldValue value: String) {
        self.fieldName = name
        self.fieldValue = value
    }
}

class OrdersDetailViewController: UIViewController {
    //@Mark-IBOutlets
    @IBOutlet weak var orderTableView: UITableView!
    
    @IBOutlet weak var paymentAddressTextView: UITextView!
    
    @IBOutlet weak var shippingAddressTextView: UITextView!
    //@MarkProperties
    var language_id = Int()
    var orderDetailArray = NSMutableArray()
    var customer_group_id = ""
    var date = ""
    var shipping = ""
    var payment = ""
    var orderid = ""
    var shiipindefaultAddress = ""
    var billingAddress = ""
    var shippingcharge = ""
    var total = ""
    var cod = ""
    var subtotal = ""
    var totalFieldsData = [TotalFieldsData]()
    
    var quantityArray = [String]()
    var priceArray = [String]()
    var modelArray = [String]()
    var productNameArray = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetUp()
        
        // Do any additional setup after loading the view.
    }
    func initialSetUp(){
		self.title = NSLocalizedString("ORDER_DETAILS", comment: "")
        orderTableView.delegate = self
        orderTableView.dataSource = self
        //  priceArray = ["hii","hello","ok"]
        getOrderDetail()
        
        
        let totalNib = UINib(nibName: TotalTableViewCell.selfName(), bundle: nil)
        self.orderTableView.register(totalNib, forCellReuseIdentifier: TotalTableViewCell.selfName())
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getOrderDetail(){
        var userId = ""
        if UserDefaultManager.sharedManager().customerGroupId  != nil{
            self.customer_group_id = UserDefaultManager.sharedManager().customerGroupId!
        }
        
        if LanguageType(rawValue: UserDefaultManager.sharedManager().selectedLanguageId!) == .arabic {
            self.language_id = 2
        }
        else{
            self.language_id = 1
        }
        if UserDefaultManager.sharedManager().loginUserId != nil{
            userId = UserDefaultManager.sharedManager().loginUserId!
        }
        
        WebserviceEngine().requestforAPI(service: "customer/viewOrders&order_id=\(self.orderid)&customer_id=\(userId)&customer_group_id=\(self.customer_group_id)&language_id=\(self.language_id)", method: "GET", token: "", body: "", productBody: NSData()) { (result, error) in
            if result != nil
            {
                NSLog("reviewlist \(result)")
                
                var firstName = ""
                var lastName = ""
                var company = ""
                var defaultaddress1 = ""
                var defaultaddress2 = ""
                var defaultcity = ""
                var defaultcountry = ""
                var  defaultstate = ""
                var  defaultpincode = ""
                var billfirstName = ""
                var billlastName = ""
                var billcompany = ""
                var billdefaultaddress1 = ""
                var billdefaultaddress2 = ""
                var billdefaultcity = ""
                var billdefaultcountry = ""
                var  billdefaultstate = ""
                var  billdefaultpincode = ""
                
                
                if let records = result?.value(forKey:"records"){
                    if let newrecords = records as? [String: AnyObject]{
                        
                        
                        if let date = newrecords["date_added"] as? String{
                            self.date = date
                        }
                        if let payment = newrecords["payment_method"] as? String{
                            self.payment = payment
                            
                        }
                        
                        
                        
                        if let shipping = newrecords["shipping_method"] as? String{
                            self.shipping = shipping
                        }
                        if let productDetails = newrecords["products"] as? [[String: AnyObject]]{
                            
                            for product in productDetails{
                                if let price = product["price"] as? String{
                                    self.priceArray.append(price)
                                    
                                }
                                if let qty = product["quantity"] as? String{
                                    self.quantityArray.append( qty)
                                    
                                }
                                if let model = product["model"] as? String{
                                    self.modelArray.append( model)
                                    
                                }
                                
                                if let name = product["name"] as? String{
                                    self.productNameArray.append(name)
                                    
                                    
                                    
                                }
                                
                            }
                        }
                        //
                        if let addressdic = newrecords["shipping_address"] as? [String: AnyObject]{
                            
                            if let firstname = addressdic["firstname"] as? String{
                                firstName = firstname
                            }
                            if let lastname = addressdic["lastname"] as? String{
                                lastName =  lastname
                            }
                            if let Company = addressdic["company"] as? String{
                                company = Company
                                
                                if let address1 = addressdic["address_1"] as? String{
                                    defaultaddress1 = address1
                                }
                                if let address2 = addressdic["address_2"] as? String{
                                    defaultaddress2 =  address2
                                }
                                if let pincode = addressdic["postcode"] as? String{
                                    defaultpincode = pincode
                                    
                                    if let city = addressdic["city"] as? String{
                                        defaultcity = city
                                    }
                                    if let zone = addressdic["zone"]{
                                        defaultstate = zone as! String
                                        
                                    }
                                    if let country = addressdic["country"] as? String{
                                        defaultcountry = country
                                    }
                                    
                                    
                                }
                                
                                
                                
                            }
                            if let addressdic = newrecords["payment_address"] as? [String: AnyObject]{
                                
                                if let firstname = addressdic["firstname"] as? String{
                                    billfirstName = firstname
                                }
                                if let lastname = addressdic["lastname"] as? String{
                                    billlastName =  lastname
                                }
                                if let Company = addressdic["company"] as? String{
                                    billcompany = Company
                                    
                                    if let address1 = addressdic["address_1"] as? String{
                                        billdefaultaddress1 = address1
                                    }
                                    if let address2 = addressdic["address_2"] as? String{
                                        billdefaultaddress2 =  address2
                                    }
                                    if let pincode = addressdic["postcode"] as? String{
                                        billdefaultpincode = pincode
                                        
                                        if let city = addressdic["city"] as? String{
                                            billdefaultcity = city
                                        }
                                        if let zone = addressdic["zone"]{
                                            billdefaultstate = zone as! String
                                            
                                        }
                                        if let country = addressdic["country"] as? String{
                                            billdefaultcountry = country
                                        }
                                        
                                        
                                    }
                                    
                                    
                                    
                                }
                                if let totals = newrecords["totals"] as? [[String: AnyObject]]{
                                    //    var orderDetailData = [[String: AnyObject]]()
                                    //    var orderDetailInfo = [OrderDetailData]()
                                    //    for (index, value) in totals.enumerated() {
                                    //        let text = value["text"] as! String
                                    //        let title = value["title"] as! String
                                    //        let orderData: OrderDetailData?
                                    //            switch index {
                                    //            case 0:
                                    //                orderData = OrderDetailData(text!, title!, withType: .SubTotal)
                                    //                orderDetailInfo.append(orderData!)
                                    //            case 1:
                                    //                orderData = OrderDetailData(text!, title!, withType: .COD)
                                    //                orderDetailInfo.append(orderData!)
                                    //            case 2:
                                    //                orderData = OrderDetailData(text!, title!, withType: .FreeShipping)
                                    //                orderDetailInfo.append(orderData!)
                                    //            case 3:
                                    //                orderData = OrderDetailData(text!, title!, withType: .Total)
                                    //                orderDetailInfo.append(orderData!)
                                    //            default: break
                                    //            }
                                    //
                                    //    }
                                    //    print("orderDetailInfo",orderDetailInfo)
                                    /* if totals.count == 2{
                                        if let subTotal = totals[0]["text"]{
                                            self.subtotal = subTotal as! String
                                        }
                                        
                                        if  let subTotal = totals[1]["text"]{
                                            self.total  = subTotal as! String
                                        }
                                        self.shippingcharge = "S.R 0"
                                    }
                                    else if totals.count == 3{
                                        if let subTotal = totals[0]["text"]{
                                            self.subtotal = subTotal as! String
                                        }
                                        
                                        if  let subTotal = totals[1]["text"]{
                                            self.shippingcharge  = subTotal as! String
                                        }
                                        if  let subTotal = totals[1]["text"]{
                                            self.total  = subTotal as! String
                                        }
                                    } */
                                    
                                    for totalObjectInfo in totals {
                                        if let title = totalObjectInfo["title"] as? String {
                                            let titleString = TotalsKeys(rawValue: title)
                                            if titleString == .sub_total {
                                                if let subTotal = totalObjectInfo["text"] as? String {
                                                    //self.subtotal = subTotal
                                                    let totalField = TotalFieldsData(withFieldName: title, andFieldValue: subTotal)
                                                    self.totalFieldsData.append(totalField)
                                                }
                                            } else if titleString == .cod {
                                                if let subTotal = totalObjectInfo["text"] as? String {
                                                    //self.shippingcharge = subTotal
                                                    let totalField = TotalFieldsData(withFieldName: title, andFieldValue: subTotal)
                                                    self.totalFieldsData.append(totalField)
                                                }
                                            } else if titleString == .freeShipping {
                                                if let subTotal = totalObjectInfo["text"] as? String {
                                                    /* if subTotal != "S.R 0" {
                                                        self.shippingcharge = subTotal
                                                    } */
                                                    let totalField = TotalFieldsData(withFieldName: title, andFieldValue: subTotal)
                                                    self.totalFieldsData.append(totalField)
                                                }
                                            } else if titleString == .aramex {
                                                if let subTotal = totalObjectInfo["text"] as? String {
                                                    /* if subTotal != "S.R 0" {
                                                        self.shippingcharge = subTotal
                                                    } */
                                                    let totalField = TotalFieldsData(withFieldName: title, andFieldValue: subTotal)
                                                    self.totalFieldsData.append(totalField)
                                                }
                                            } else {
                                                if let subTotal = totalObjectInfo["text"] as? String {
                                                    //self.total = subTotal
                                                    let totalField = TotalFieldsData(withFieldName: title, andFieldValue: subTotal)
                                                    self.totalFieldsData.append(totalField)
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                self.shiipindefaultAddress = "\(firstName),\(lastName),\(company),\(defaultaddress1)\n\(defaultcity) \(defaultstate) \(defaultcountry)\("-")\(defaultpincode)"
                                self.billingAddress = "\(billfirstName),\(billlastName),\(billcompany),\(billdefaultaddress1)\n\(billdefaultcity) \(billdefaultstate) \(billdefaultcountry)\("-")\(billdefaultpincode)"
                            }
                            
                        }
                        DispatchQueue.main.async(execute: { () -> Void in
                            self.orderTableView.reloadData()
                        })
                        
                    }
                        
                        
                    else
                    {
                        if (error!.value(forKey: "code") as! NSNumber).stringValue == "-1001"
                        {
                            DispatchQueue.main.sync(execute: { () -> Void in
                                
                                let alertController = UIAlertController(title:Constants.alertTitle, message:
                                    Constants.slowInternet, preferredStyle: UIAlertControllerStyle.alert)
                                alertController.addAction(UIAlertAction(title: Constants.alertAction, style: UIAlertActionStyle.default,handler: nil))
                                self.present(alertController, animated: true, completion: nil)
                            })
                        }
                        if (error!.value(forKey: "code") as! NSNumber).stringValue == "-1009"
                        {
                            DispatchQueue.main.sync(execute: { () -> Void in
                                
                                let alertController = UIAlertController(title:Constants.alertTitle, message:
                                    Constants.noInternet, preferredStyle: UIAlertControllerStyle.alert)
                                alertController.addAction(UIAlertAction(title: Constants.alertAction, style: UIAlertActionStyle.default,handler: nil))
                                self.present(alertController, animated: true, completion: nil)
                                
                            })
                        }
                    }
                }
            }
        }
    }
}

//MARK:- UITableViewDelegate
extension OrdersDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 95
        } else if indexPath.section == 3 {
            if indexPath.row == 0 {
                return 118
            }
            
            if (indexPath.row == 1) || (indexPath.row == 2) {
                return 90
            }
        } else if indexPath.section == 2 {
            if ((indexPath.row == self.totalFieldsData.count) || (indexPath.row == self.totalFieldsData.count + 1)) {
                return 90
            } else {
                return UITableViewAutomaticDimension
            }
        } else{
            return 120
        }
        return 0
    }
}

extension OrdersDetailViewController:UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        if section == 1 {
            print("count",priceArray.count)
            return priceArray.count
        } else if section == 2 {
            return self.totalFieldsData.count + 2
        }
        else {
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            
            let cell  = tableView.dequeueReusableCell(withIdentifier: "OrderDetailTableViewCell") as! OrderDetailTableViewCell
            cell.orderIDLabel.text = self.orderid
            cell.paymentLabel.text = self.payment
            cell.cashLabel.text = self.shipping
            cell.dateLabel.text = self.date
			
			if UIDevice.current.userInterfaceIdiom == .pad {
				cell.orderIDLabel.font = UIFont.systemFont(ofSize: 18.0)
				cell.paymentLabel.font = UIFont.systemFont(ofSize: 18.0)
				cell.cashLabel.font = UIFont.systemFont(ofSize: 18.0)
				cell.dateLabel.font = UIFont.systemFont(ofSize: 18.0)
			} else {
				cell.orderIDLabel.font = UIFont.systemFont(ofSize: 12.0)
				cell.paymentLabel.font = UIFont.systemFont(ofSize: 12.0)
				cell.cashLabel.font = UIFont.systemFont(ofSize: 12.0)
				cell.dateLabel.font = UIFont.systemFont(ofSize: 12.0)
			}
            return cell
        }
        
        if indexPath.section == 1 {
            let cell  = tableView.dequeueReusableCell(withIdentifier: "OrderDetailSecondTableViewCell") as! OrderDetailSecondTableViewCell
            print("indexPath.row",indexPath.row)
            cell.priceLabel.text = self.priceArray[indexPath.row]
            cell.quantityLabel.text = self.quantityArray[indexPath.row]
            cell.productName.text = self.productNameArray[indexPath.row]
            cell.returnButton.addTarget(self, action: #selector(OrdersDetailViewController.returnAction), for: UIControlEvents.touchUpInside)
            cell.returnButton.tag = indexPath.row
			
			if UIDevice.current.userInterfaceIdiom == .pad {
				cell.priceLabel.font = UIFont.systemFont(ofSize: 18.0)
				cell.quantityLabel.font = UIFont.systemFont(ofSize: 18.0)
				cell.productName.font = UIFont.systemFont(ofSize: 18.0)
			} else {
				cell.priceLabel.font = UIFont.systemFont(ofSize: 12.0)
				cell.quantityLabel.font = UIFont.systemFont(ofSize: 12.0)
				cell.productName.font = UIFont.systemFont(ofSize: 12.0)
			}
            return cell
        }
        
        if indexPath.section == 2 {
            /* if indexPath.row == 0 {
                let cell  = tableView.dequeueReusableCell(withIdentifier: "OrderDetailThirdTableViewCell") as! OrderDetailThirdTableViewCell
                cell.totalLabel.text = self.total
                cell.shippingChargeLabel.text = self.shippingcharge
                cell.subTotalLabel.text = self.subtotal
                return cell
            } */
            
            if indexPath.row == self.totalFieldsData.count + 1 {
                let cell  = tableView.dequeueReusableCell(withIdentifier: "OrderDetailFourthTableViewCell") as! OrderDetailFourthTableViewCell
                cell.headingLabel.text = NSLocalizedString("Shiiping Details", comment: "")
                cell.addresssTextView.text = self.shiipindefaultAddress
                
                return cell
                
            } else if indexPath.row == self.totalFieldsData.count {
                let cell  = tableView.dequeueReusableCell(withIdentifier: "OrderDetailFourthTableViewCell") as! OrderDetailFourthTableViewCell
                cell.headingLabel.text = NSLocalizedString("Billing Details", comment: "")
                cell.addresssTextView.text = self.billingAddress
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: TotalTableViewCell.selfName(), for: indexPath) as? TotalTableViewCell
                cell?.fieldTitleLabel.text = self.totalFieldsData[indexPath.row].fieldName
                cell?.fieldValueLabel.text = self.totalFieldsData[indexPath.row].fieldValue
				
				if UIDevice.current.userInterfaceIdiom == .pad {
					cell?.fieldTitleLabel.font = UIFont.systemFont(ofSize: 18.0)
					cell?.fieldValueLabel.font = UIFont.systemFont(ofSize: 18.0)
				} else {
					cell?.fieldTitleLabel.font = UIFont.systemFont(ofSize: 12.0)
					cell?.fieldValueLabel.font = UIFont.systemFont(ofSize: 12.0)
				}
                return cell!
            }
        }
        
        let cell = UITableViewCell()
        return cell
    }
    
    func returnAction(sender:UIButton){
        
        let orderDetailVC =  self.storyboard?.instantiateViewController(withIdentifier:"OrderReturnViewController") as! OrderReturnViewController
        orderDetailVC.orderid = self.orderid
        let productname = productNameArray[sender.tag]
        orderDetailVC.productName = productname
        let quantity = quantityArray[sender.tag]
        orderDetailVC.quantity = quantity
        let model = modelArray[sender.tag]
        orderDetailVC.model = model
        orderDetailVC.payment = self.payment
        orderDetailVC.date = self.date
        orderDetailVC.shipping = self.shipping
        
        self.navigationController?.pushViewController(orderDetailVC, animated: true)
    }
    
}
