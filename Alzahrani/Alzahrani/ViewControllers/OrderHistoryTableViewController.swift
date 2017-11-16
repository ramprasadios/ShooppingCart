//
//  OrderHistoryTableViewController.swift
//  Alzahrani
//
//  Created by shilpa shree on 5/26/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class OrderHistoryTableViewController: UITableViewController {
    //Mark:-Properties
    var language_id = Int()
    var orderStatusArray = [String]()
    var orderPriceArray = [String]()
    var  orderQtyArray = [String]()
    var orderArray = [String]()
    var orderid = ""
    var dateArray = [String]()
    
    var orderDetailArray = NSMutableArray()
    var customer_group_id = ""
    var date = ""
    var shipping = ""
    var payment = ""
    
    var quantityArray = [String]()
    var priceArray = [String]()
    var productNameArray = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        getOrderList()
        self.title = NSLocalizedString("Order_History", comment: "")
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarImage()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getOrderList(){
        if LanguageType(rawValue: UserDefaultManager.sharedManager().selectedLanguageId!) == .arabic {
            self.language_id = 2
        }
        else{
            self.language_id = 1
        }
        var  userId = ""
        if UserDefaultManager.sharedManager().loginUserId != nil{
            userId = UserDefaultManager.sharedManager().loginUserId!
        }
        ProgressIndicatorController.showLoading()
        WebserviceEngine().requestforAPI(service: "customer/getOrderDetails&customer_id=\(userId)&language_id=\(self.language_id)", method: "GET", token: "", body: "", productBody: NSData()) { (result, error) in
            ProgressIndicatorController.dismissProgressView()
            if result != nil
            {
                NSLog("reviewlist \(result)")
                
                
                if let records = result?.value(forKey:"records"){
                    if let newrecords = records as? [[String: AnyObject]]{
                        
                        for newelement in newrecords{
                            if let date = newelement["date_added"] as? String{
                                self.dateArray.append(date)
                            }
                            if let quantity = newelement["products"] as? Int64{
                                let qty = String(describing:quantity)
                                self.orderQtyArray.append(qty)
                            }
                            if let orderid = newelement["order_id"] as? String{
                                // let id = String(describing:orderid)
                                self.orderArray.append(orderid)
                            }
                            
                            if let price = newelement["total"] as? String{
                                self.orderPriceArray.append(price)
                            }
                            if  let orderstatus = newelement["status"] as? String{
                                self.orderStatusArray.append(orderstatus)
                            }
                        }
                        
                        
                    }
                }
                DispatchQueue.main.sync(execute: { () -> Void in
                    self.tableView.reloadData()
                })
            }
            else
            {
                if (error!.value(forKey: "code") as! NSNumber).stringValue == "-1001"
                {
                    DispatchQueue.main.sync(execute: { () -> Void in
                        
                        let alertController = UIAlertController(title:Constants.alertTitle, message:
                            Constants.slowInternet, preferredStyle: UIAlertControllerStyle.alert)
                        alertController.addAction(UIAlertAction(title:Constants.alertAction, style: UIAlertActionStyle.default,handler: nil))
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
    
    func setNavigationBarImage() {
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dateArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderHistoryTableViewCell", for: indexPath) as! OrderHistoryTableViewCell
        
        cell.dateLabel.text = "\(dateArray[indexPath.row])"
        cell.priceLabel.text = "\(orderPriceArray[indexPath.row])"
        cell.orderid.text = "\(orderArray[indexPath.row])"
        cell.quantityLabel.text = orderQtyArray[indexPath.row]
        cell.orderstatusLbel.text = orderStatusArray[indexPath.row]
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.orderid = orderArray[indexPath.row]
        let orderDetailVC =  self.storyboard?.instantiateViewController(withIdentifier:"OrdersDetailViewController") as! OrdersDetailViewController
        orderDetailVC.orderid = self.orderid
        //getOrderDetail(orderid:self.orderid)
        self.navigationController?.pushViewController(orderDetailVC, animated: true)
    }
    func getOrderDetail(orderid:String){
        if UserDefaultManager.sharedManager().customerGroupId  != nil{
            self.customer_group_id = UserDefaultManager.sharedManager().customerGroupId!
        }
        if LanguageType(rawValue: UserDefaultManager.sharedManager().selectedLanguageId!) == .arabic {
            self.language_id = 2
        }
        else{
            self.language_id = 1
        }
        var userId = ""
        if UserDefaultManager.sharedManager().loginUserId != nil{
            userId = UserDefaultManager.sharedManager().loginUserId!
        }
        
        WebserviceEngine().requestforAPI(service: "customer/viewOrders&order_id=\(orderid)&customer_id=\(userId)&customer_group_id=\(self.customer_group_id)&language_id=\(self.language_id)", method: "GET", token: "", body: "", productBody: NSData()) { (result, error) in
            if result != nil
            {
                NSLog("reviewlist \(result)")
                
                DispatchQueue.main.sync(execute: { () -> Void in
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
                                    if let name = product["name"] as? String{
                                        self.productNameArray.append(name)
                                    }
                                }
                            }
                        }
                    }
                    
                    let orderDetailVC =  self.storyboard?.instantiateViewController(withIdentifier:"OrdersDetailViewController") as! OrdersDetailViewController
                    orderDetailVC .productNameArray = self.productNameArray
                    orderDetailVC .priceArray = self.priceArray
                    orderDetailVC .quantityArray = self.quantityArray
                    orderDetailVC .date = self.date
                    orderDetailVC .shipping = self.shipping
                    orderDetailVC .payment = self.payment
                    orderDetailVC .orderid = self.orderid
                    
                    self.navigationController?.pushViewController(orderDetailVC, animated: true)
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
