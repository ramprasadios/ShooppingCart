//
//  ViewRecurringViewController.swift
//  Alzahrani
//
//  Created by shilpa shree on 6/13/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class ViewRecurringViewController: UIViewController {
    // MARK: - OutL

    @IBOutlet weak var recurringTableView: UITableView!
    // MARK: - Navigation

     var language_id = ""
    var profile_id = ""
    var status =  ""
    var date = ""
    var product = ""
    var payment = ""
    var qty = ""
    var transactionDate = ""
    var transactionType = ""
    var amount = ""
    var orderDescription = ""
    var referance = ""
   var orderid = ""
    // MARK: - Navigation

    override func viewDidLoad() {
        super.viewDidLoad()
initialSetUp()
        // Do any additional setup after loading the view.
    }
    func initialSetUp(){
        ProgressIndicatorController.showLoading()
        getDetails()
        recurringTableView.delegate = self
        recurringTableView.dataSource = self
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    func getDetails(){
        
        
        var userId  = ""
        if UserDefaultManager.sharedManager().loginUserId != nil{
            userId = UserDefaultManager.sharedManager().loginUserId!
        }

        WebserviceEngine().requestforAPI(service: "/customer/viewRecurring&recurring_id=\(self.profile_id)&customer_id=\(userId)", method: "GET", token: "", body: "", productBody: NSData()) { (result, error) in
            if result != nil
            {
                NSLog("list \(result)")
                ProgressIndicatorController.dismissProgressView()
                if let records = result?["records"] as? [[String:AnyObject]]{
                    print("records",records)
                    let newrecords = records
                    for datavalue in newrecords{
                       if let payment = datavalue["payment_method"] as? String{
                            
                    self.payment = payment
                            
                        }
                        if let qty = datavalue["payment_method"] as? String{
                            self.qty = qty
                        }
                        if let orderid = datavalue["order_id"] as? String{
                            self.orderid = orderid
                        }
                        if let descrip = datavalue["recurring_description"] as? String{
                            self.orderDescription = descrip
                        }

                        if let refer = datavalue["reference"] as? String{
                            self.referance = refer
                        }
                        
                        if  let transactionArray = datavalue["transactions"] as? [[String:AnyObject]]{
                            for trans in transactionArray{
                                 if let amount = trans["amount"] as? String{
                                    self.amount = amount
                                }
                               
                                
                                if let date = trans["date_added"] as? String{
                                    self.transactionDate = date
                                }
                                if let type = trans["type"] as? String{
                                    self.transactionType = type
                                }
                            }
                        }
                    }

                    
                    }
                
                DispatchQueue.main.sync(execute: { () -> Void in
                    
                  self.recurringTableView.reloadData()
                })
            }
            else
            {
                if (error!.value(forKey: "code") as! NSNumber).stringValue == "-1001"
                {ProgressIndicatorController.dismissProgressView()
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
                        ProgressIndicatorController.dismissProgressView()
                        let alertController = UIAlertController(title: Constants.alertTitle, message:
                            Constants.noInternet, preferredStyle: UIAlertControllerStyle.alert)
                        alertController.addAction(UIAlertAction(title:Constants.alertAction, style: UIAlertActionStyle.default,handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                        
                    })
                }
            }
        }
    }
    

}

extension ViewRecurringViewController:UITableViewDataSource{
    
   func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
       
        return 1
    }
    
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
      
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecurringTableViewCell", for: indexPath) as! RecurringTableViewCell
            cell.statusLabel.text = self.status
        cell.dateLabel.text = self.date
        cell.profileLabel.text  = self.profile_id
        cell.productLabel.text = self.product
        cell.orderID.text = self.orderid
        cell.amountLabel.text = self.amount
        cell.referenceLabel.text = self.referance
        cell.descriptionLabel.text = self.orderDescription
         cell.quantityLabel.text = self.qty
        cell.paymentLabel.text = self.payment
        cell.dateTransactionLabel.text = self.transactionDate
        cell.typeLabel.text  = self.transactionType
            return cell
            
        
    }
    
    
    
    
}
 extension ViewRecurringViewController:UITableViewDelegate{
    
}
