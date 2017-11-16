//
//  PaymentRecurringTableViewController.swift
//  Alzahrani
//
//  Created by shilpa shree on 6/10/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class PaymentRecurringTableViewController: UITableViewController {

    var profileIDArray = [String]()
    var statusArray = [String]()
    var dateArray = [String]()
    var productArray = [String]()
    var profile_id = ""
    var status =  ""
    var date = ""
    var product = ""
    var language_id = ""
    override func viewDidLoad() {
        super.viewDidLoad()
          ProgressIndicatorController.showLoading()
        // DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async{
      
        self.ReccuringPayments()
        //}
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
        print("profileIDArray",profileIDArray.count)
        return profileIDArray.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if profileIDArray.count == 0 {
            let headerView = UIView()
            headerView.frame = CGRect(x:0,y:2,width:self.tableView.frame.size.width,height:25)
            let label = UILabel()
            label.frame = CGRect(x:0,y:2,width:self.tableView.frame.size.width,height:25)
            label.text = "You dont have any recurring payment details"
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
        if profileIDArray.count == 0 {
            return 40
        }
        else{
            return 1
            
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if statusArray.count>0 && profileIDArray.count>0 && dateArray.count>0 && productArray.count>0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecurringPaymentTableViewCell", for: indexPath) as! RecurringPaymentTableViewCell
            
            cell.dateLabel.text = dateArray[indexPath.row]
            cell.statusLabel.text = statusArray[indexPath.row]
            cell.productLabel.text = productArray[indexPath.row]
            cell.profileIDLabel.text = profileIDArray[indexPath.row]
            cell.viewButton.addTarget(self, action: #selector( PaymentRecurringTableViewController.showDetails), for: UIControlEvents.touchUpInside)
cell.viewButton.tag = indexPath.row
            return cell
            
        }
        else{
            let cell = UITableViewCell()
            return cell
        }
    }
    
    //Mark:-Life cycle
    
    func showDetails(sender:UIButton){
        let recurringVC = self.storyboard?.instantiateViewController(withIdentifier: "ViewRecurringViewController") as! ViewRecurringViewController
        recurringVC.product = self.product
        recurringVC.date = self.date
        recurringVC.status = self.status
        recurringVC.profile_id = self.profile_id
        
        self.navigationController?.pushViewController(recurringVC , animated: true)
        
    }
    
    
    func ReccuringPayments(){
                var userId = ""
        if UserDefaultManager.sharedManager().loginUserId != nil{
              userId = UserDefaultManager.sharedManager().loginUserId!
        }
        WebserviceEngine().requestforAPI(service: "customer/recurringPayments&customer_id=\(userId)", method: "GET", token: "", body: "", productBody: NSData()) { (result, error) in
            if result != nil
            {
                NSLog("reviewlist \(result)")
                
                
                if let records = result?["records"] as? [[String:AnyObject]]{
                     ProgressIndicatorController.dismissProgressView()
                    let newrecords = records
                    for datavalue in newrecords{
                        
                        if let date = datavalue["date_added"] as? String{
                            self.date = date
                            self.dateArray.append(date)
                            
                        }
                        if let status = datavalue["status"] as? String{
                            self.status = status
                            self.statusArray.append(status )
                            
                        }
                        if let name = datavalue["name"] as? String{
                            self.product = name
                            self.productArray.append(name)
                            
                        }
                        if let id = datavalue["id"] as? String{
                            self.profile_id = id
                            self.profileIDArray.append(id)
                            
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
                { ProgressIndicatorController.dismissProgressView()
                    DispatchQueue.main.sync(execute: { () -> Void in
                        let alertController = UIAlertController(title:Constants.alertTitle, message:
                            Constants.slowInternet, preferredStyle: UIAlertControllerStyle.alert)
                        alertController.addAction(UIAlertAction(title: Constants.alertAction, style: UIAlertActionStyle.default,handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                    })
                }
                if (error!.value(forKey: "code") as! NSNumber).stringValue == "-1009"
                { ProgressIndicatorController.dismissProgressView()
                    DispatchQueue.main.sync(execute: { () -> Void in
                        
                        let alertController = UIAlertController(title: Constants.alertTitle, message:
                           Constants.noInternet, preferredStyle: UIAlertControllerStyle.alert)
                        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                        
                    })
                }
            }
        }
    }
    

}
