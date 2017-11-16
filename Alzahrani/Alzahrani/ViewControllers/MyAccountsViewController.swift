//
//  MyAccountsViewController.swift
//  Alzahrani
//
//  Created by shilpa shree on 5/26/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class MyAccountsViewController: UIViewController {
    
    @IBOutlet weak var myaccountView: UITableView!
    
    var accountArray = NSMutableArray()
    var firstName = ""
    var lastname = ""
    var secondName = ""
    var mobile = ""
    var email = ""
    var company = ""
    var address1 = ""
    var address2 = ""
    var city = ""
    var state = ""
    var country = ""
    var pincode = ""
    var addressid = ""
    var countryid = ""
    var stateid = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem?.tintColor = .white
        initialSetUp()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.title = NSLocalizedString("My Account", comment: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getPersonalDetails()
        self.setNavigationBarImage()
    }
    
    func initialSetUp(){
        //getPersonalDetails()
        myaccountView.register(UINib(nibName: "MyAccountTableViewCell", bundle: nil), forCellReuseIdentifier: "MyAccountTableViewCell")
        myaccountView.delegate = self
        myaccountView.dataSource = self
        accountArray = [NSLocalizedString("Edit your account information", comment: ""), NSLocalizedString("Change your password", comment: "") ,NSLocalizedString("Modify your address book entries", comment: ""), NSLocalizedString("Languages", comment: "")]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showUserMenu(_ sender: UIBarButtonItem) {
        NotificationCenter.default.post(name: Notification.Name(Constants.hambergerTappedNotification), object: nil)
    }
    
    func setNavigationBarImage() {
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
    }
    
    func getPersonalDetails(){
        
        if let customer_id = UserDefaultManager.sharedManager().loginUserId {
            ProgressIndicatorController.showLoading()
            WebserviceEngine().requestforAPI(service: "customer/getmyProfile&customer_id=\(customer_id)", method: "GET", token: "", body: "", productBody: NSData()) { (result, error) in
                
                if result != nil
                {
                    ProgressIndicatorController.dismissProgressView()
                    NSLog("reviewlist \(result)")
                    if let records = result?.value(forKey:"records"){
                        if let newrecords = records as? [[String: AnyObject]]{
                            for newelement in newrecords{
                                if let firstname =  newelement["firstname"] as? String{
                                    self.firstName = firstname
                                }
                                
                                
                                if let secondname =  newelement["lastname"] as? String{
                                    self.secondName = secondname
                                }
                                if let emailid =  newelement["email"] as? String{
                                    self.email = emailid
                                }
                                if let mobileno =  newelement["telephone"] as? String{
                                    self.mobile = mobileno
                                }
                                if let companyName =  newelement["company"] as? String{
                                    self.company  = companyName
                                    
                                }
                                if let address1 =  newelement["address_1"] as? String{
                                    self.address1  = address1
                                    
                                }
                                if let address2 =  newelement["address_2"] as? String{
                                    self.address2  = address2
                                    
                                }
                                if let city =  newelement["city"] as? String{
                                    self.city  = city
                                    
                                }
                                if let country =  newelement["country"] as? String{
                                    self.country  = country
                                    
                                }
                                if let state =  newelement["zone"] as? String{
                                    self.state  = state
                                    
                                }
                                if let pincode =  newelement["postcode"] as? String{
                                    self.pincode  = pincode
                                    
                                }
                                if let areaid =  newelement["address_id"] as? String{
                                    self.addressid =  areaid
                                    
                                }
                                if let stateid =  newelement["zone_id"] as? String{
                                    self.stateid =  stateid
                                    
                                }
                                if let countryid =  newelement["country_id"] as? String{
                                    self.countryid = countryid
                                    
                                }
                            }
                        }
                    }
                }
                else
                {
                    ProgressIndicatorController.dismissProgressView()
                    if (error!.value(forKey: "code") as! NSNumber).stringValue == "-1001"
                    {
                        DispatchQueue.main.sync(execute: { () -> Void in
							let message = NSLocalizedString("Internet too slow", comment: "")
                            let alertController = UIAlertController(title: Constants.alertTitle, message:
                                message, preferredStyle: UIAlertControllerStyle.alert)
                            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: {
                                (UIAlertAction) in
                                let _ = self.navigationController?.popViewController(animated: true)
                            }))
                            self.present(alertController, animated: true, completion: nil)
                        })
                    }
                    if (error!.value(forKey: "code") as! NSNumber).stringValue == "-1009"
                    {
                        DispatchQueue.main.sync(execute: { () -> Void in
                            let message = NSLocalizedString("NO internet connection", comment: "")
                            let alertController = UIAlertController(title: Constants.alertTitle, message:
                                message, preferredStyle: UIAlertControllerStyle.alert)
                            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil))
                            self.present(alertController, animated: true, completion: nil)
                            
                        })
                    }
                }
            }
        }
    }
}

extension MyAccountsViewController:UITableViewDelegate{
    
    
    //    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    //        let headerView = tableView.dequeueReusableCell(withIdentifier: "MyAccountTableViewCell") as! MyAccountTableViewCell
    //        headerView.profileImageView.layer.cornerRadius = headerView.profileImageView.frame.size.width / 2
    //        headerView.profileImageView.layer.masksToBounds = true
    //
    //        headerView.profileImageView.layer.borderColor = UIColor(red: 235/255, green: 62/255, blue: 16/255, alpha: 1).cgColor
    //        headerView.profileImageView.layer.borderWidth = 1
    //
    //        return  headerView
    //    }
    //
    //    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    //        return 190
    //    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
			if AppManager.isUserLoggedIn {
				let vc = self.storyboard?.instantiateViewController(withIdentifier: "PersonalDetailViewController") as! PersonalDetailViewController
				vc.firstname = self.firstName
				vc.secondName = self.secondName
				vc.mobile = self.mobile
				
				vc.email = self.email
				self.navigationController?.pushViewController(vc , animated: false)

			}
		}
		
        if indexPath.row == 1 {
			if AppManager.isUserLoggedIn {
				let vc = self.storyboard?.instantiateViewController(withIdentifier: "PasswordUpdateViewController"
					) as! PasswordUpdateViewController
				self.navigationController?.pushViewController(vc , animated: false)
			}
        }
        if indexPath.row == 2 {
			if AppManager.isUserLoggedIn {
				let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddressViewController"
					) as! AddressViewController
				vc.firstname = self.firstName
				vc.lastname = self.secondName
				vc.company = self.company
				vc.city = self.city
				vc.address1 = self.address1
				vc.address2 = self.address2
				vc.pincode = self.pincode
				vc.state = self.state
				vc.country = self.country
				vc.selectedZoneID = self.stateid
				vc.selectedcountryID = self.countryid
				vc.addressid = self.addressid
				self.navigationController?.pushViewController(vc , animated: false)
			}
        }
        if indexPath.row == 3{
			
			if AppManager.currentApplicationMode() == .online {
				if let vc = self.storyboard?.instantiateViewController(withIdentifier: "LanguageViewController"
					) as? LanguageViewController {
					self.navigationController?.pushViewController(vc , animated: false)
				}
			} else {
				ALAlerts.showToast(message: NSLocalizedString("Not available in Offline Mode", comment: ""))
			}
		}
    }
}
extension MyAccountsViewController:UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return  accountArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if UIDevice.current.userInterfaceIdiom == .pad {
			return 80.0
		} else {
			return 40.0
		}
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyAccountNameTableViewCell", for: indexPath) as! MyAccountNameTableViewCell
        cell.headingLabel.text = accountArray[indexPath.row] as? String
        
        cell.arrow.addTarget(self, action: #selector(MyAccountsViewController.buttonClicked), for: UIControlEvents.touchUpInside)
        cell.arrow.tag = indexPath.row
		
		if UIDevice.current.userInterfaceIdiom == .pad {
			cell.headingLabel.font = UIFont.systemFont(ofSize: 22.0)
		} else {
			cell.headingLabel.font = UIFont.systemFont(ofSize: 14.0)
		}
        return cell
    }
	
    func buttonClicked(sender:UIButton){
        if sender.tag == 0{
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PersonalDetailViewController"
                ) as! PersonalDetailViewController
            vc.firstname = self.firstName
            vc.secondName = self.secondName
            vc.mobile = self.mobile
            
            vc.email = self.email
            self.navigationController?.pushViewController(vc , animated: false)
            
        }
        if sender.tag == 1{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PasswordUpdateViewController"
                ) as! PasswordUpdateViewController
            self.navigationController?.pushViewController(vc , animated: false)
        }
        if sender.tag == 2{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddressViewController"
                ) as! AddressViewController
            vc.firstname = self.firstName
            vc.lastname = self.secondName
            vc.company = self.company
            vc.city = self.city
            vc.address1 = self.address1
            vc.address2 = self.address2
            vc.pincode = self.pincode
            vc.state = self.state
            vc.country = self.country
            vc.selectedZoneID = self.stateid
            vc.selectedcountryID = self.countryid
            vc.addressid = self.addressid
            self.navigationController?.pushViewController(vc , animated: false)
        }
        if sender.tag == 3{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "LanguageViewController"
                ) as! LanguageViewController
            self.navigationController?.pushViewController(vc , animated: false)
            
            
            
        }
        
    }
    
}
