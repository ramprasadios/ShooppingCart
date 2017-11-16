//
//  RewardsTableViewController.swift
//  Alzahrani
//
//  Created by shilpa shree on 6/9/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class RewardsTableViewController: UITableViewController {
//Mark:- Properties
    var dateArray = [String]()
    var pointsArray = [String]()
    var descriptionArray = [String]()
    var norewards = true
    override func viewDidLoad() {
        super.viewDidLoad()
initialSetup()
        ProgressIndicatorController.showLoading()
         getRewards()
        
    }
    func initialSetup(){
        
       
        
        let headerNib = UINib(nibName: "RewardsTableViewCell", bundle: nil)
        self.tableView.register(headerNib, forCellReuseIdentifier: "RewardsTableViewCell")
        let nib = UINib(nibName: "RewardsHistoryTableViewCell", bundle: nil)
      self.tableView.register(nib, forCellReuseIdentifier: "RewardsHistoryTableViewCell")
       
        let tableHeaderView = loadViewFromNib(nibName:"RewardsTableViewCell")
        tableHeaderView.frame = CGRect(x:0, y:0, width: self.tableView.frame.size.width, height: 40.0)
        self.tableView.tableHeaderView = tableHeaderView
        

    }
    //Mark:-TableViewDelegates and DataSource
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
    return 40
        
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
        return descriptionArray.count
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
       if dateArray.count == 0 && pointsArray.count == 0 && descriptionArray.count == 0{
        let headerView = UIView()
        headerView.frame = CGRect(x:0,y:2,width:self.tableView.frame.size.width,height:25)
       let label = UILabel()
        label.frame = CGRect(x:0,y:2,width:self.tableView.frame.size.width,height:25)
         label.text = "You do not have any reward points!"
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
         if dateArray.count == 0 && pointsArray.count == 0 && descriptionArray.count == 0{
            return 40
        }
        else{
            return 1
            
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        if dateArray.count>0 && pointsArray.count>0 && descriptionArray.count>0{
             let cell = tableView.dequeueReusableCell(withIdentifier: "RewardsHistoryTableViewCell", for: indexPath) as! RewardsHistoryTableViewCell
cell.dateLabel.text = dateArray[indexPath.row]
        cell.descriptionLabel.text = descriptionArray[indexPath.row]
        cell.piontLabel.text = pointsArray[indexPath.row]
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
 func getRewards(){
 var userId  = ""
    if UserDefaultManager.sharedManager().loginUserId != nil{
        userId = UserDefaultManager.sharedManager().loginUserId!
    }
 WebserviceEngine().requestforAPI(service: "customer/rewardPoints&customer_id=\(userId)", method: "GET", token: "", body: "", productBody: NSData()) { (result, error) in
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
 if let point = datavalue["points"] as? String{
 self.pointsArray.append(point)
 
 }
 if let descr = datavalue["description"] as? String{
 self.descriptionArray.append(descr)
 
 }
 
 }
 
 }
 DispatchQueue.main.sync(execute: { () -> Void in
 self.norewards = false
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
