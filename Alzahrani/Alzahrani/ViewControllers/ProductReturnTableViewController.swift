//
//  ProductReturnTableViewController.swift
//  Alzahrani
//
//  Created by shilpa shree on 6/9/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class ProductReturnTableViewController: UITableViewController {
var returnIDArray = [String]()
    var statusArray = [String]()
    var dateArray = [String]()
    var productIdArray = [String]()
    var language_id = Int()
    override func viewDidLoad() {
        super.viewDidLoad()
        ProgressIndicatorController.showLoading()
getReturns()
       
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 125
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return returnIDArray.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if returnIDArray.count == 0 && statusArray.count == 0 && dateArray.count == 0 && productIdArray.count == 0 {
            let headerView = UIView()
            headerView.frame = CGRect(x:0,y:2,width:self.tableView.frame.size.width,height:25)
            let label = UILabel()
            label.frame = CGRect(x:0,y:2,width:self.tableView.frame.size.width,height:25)
            label.text = "You did not return any products!"
            label.font = UIFont(name:"System-Regular",size:12)
            headerView.addSubview(label)
            return headerView
        }
        else{
            
            let headerview1 = UIView()
            return headerview1
        }
        
        
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if returnIDArray.count == 0 && statusArray.count == 0 && dateArray.count == 0 && productIdArray.count == 0{
            return 40
        }
        else{
            return 1
            
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if statusArray.count>0 && returnIDArray.count>0 && dateArray.count>0 && productIdArray.count>0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductReturnTableViewCell", for: indexPath) as! ProductReturnTableViewCell
            cell.dateLabel.text = dateArray[indexPath.row]
            cell.orderIdLabel.text = productIdArray[indexPath.row]
            cell.statusLabel.text = statusArray[indexPath.row]
            cell.returnidLabel.text = returnIDArray[indexPath.row]

            return cell
        
            
        }
        else{
            let cell = UITableViewCell()
            return cell
        }
    }
    func loadViewFromNib(nibName name : String) -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: name, bundle: bundle)
        
        // Assumes UIView is top level and only object in name.xib file
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
    //Mark:-Life cycle
    func getReturns(){
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
        WebserviceEngine().requestforAPI(service: "customer/getReturnOrders&customer_id=\(userId)&language_id=\(self.language_id)", method: "GET", token: "", body: "", productBody: NSData()) { (result, error) in
            if result != nil
            {
                NSLog("reviewlist \(result)")
                ProgressIndicatorController.dismissProgressView()
                if let records = result?["records"] as? [[String:AnyObject]]{
                    print("records",records)
                    let newrecords = records
                    for datavalue in newrecords{
                        
                        if let date = datavalue["date_added"] as? String{
                            self.dateArray.append(date)
                            
                        }
                        if let status = datavalue["status"] as? String{
                            self.statusArray.append(status )
                            
                        }
                        if let returnid = datavalue["return_id"] as? String{
                            self.returnIDArray.append(returnid)
                            
                        }
                        if let order_id = datavalue["order_id"] as? String{
                            self.productIdArray.append(order_id)
                            
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
                {  ProgressIndicatorController.dismissProgressView()
                    DispatchQueue.main.sync(execute: { () -> Void in
                        let alertController = UIAlertController(title: Constants.alertTitle, message:
                            Constants.slowInternet, preferredStyle: UIAlertControllerStyle.alert)
                        alertController.addAction(UIAlertAction(title: Constants.alertAction, style: UIAlertActionStyle.default,handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                    })
                }
                if (error!.value(forKey: "code") as! NSNumber).stringValue == "-1009"
                {  ProgressIndicatorController.dismissProgressView()
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
