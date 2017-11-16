//
//  MyMenu1TableViewController.swift
//  DrOwl
//
//  Created by prashanthi on 10/29/15.
//  Copyright © 2015 hardwin. All rights reserved.
//

import UIKit
import CoreData

class MyMenuTableViewController: UITableViewController {
    
    var sideMenuArray:[NSManagedObject] = []
    var loginType:String = ""
    
    var destViewController:UIViewController!
    var afterLoginListArray = ["Register","Login","My Account","My Wishlist","Order history","Customer service","Settings","ShareApp","Rate Us"]
    var selectedMenuItem = 0
    var imageArray = ["Register_logo","login_logo","my_account_logo","my_wishList_logo","order_history_logo","customer_service_logo","settings_logo","share_app_logo","rate_us_logo"]
    var mainStoryboard: UIStoryboard!
    // var beforeLoginListArray =  ["Home","Sign In","Register","Contact Us"]
    
    var listArray:Array<String>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // NotificationCenter.default.addObserver(self, selector: #selector(MyMenuTableViewController.updateMenu), name: NSNotification.Name(rawValue: "updatemenu"), object: nil)
        tableView.register(UINib(nibName: "MenuHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: "menuheadercell")
        let nib = UINib(nibName: "MenuCustomTableViewCells", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "MenuCustomTableViewCells")
        // if UserDefaults.standard.value(forKey: "Authentication") != nil
        //{
        self.listArray = self.afterLoginListArray
        //        }
        //        else
        //        {
        //            self.listArray = self.beforeLoginListArray
        //
        //
        //        }
        self.tableView.rowHeight = UITableViewAutomaticDimension
        // self.tableView.estimatedRowHeight = 50
        self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        // self.tableView.estimatedSectionHeaderHeight = 250
        
        // Customize apperance of table view
        tableView.contentInset = UIEdgeInsetsMake(0.0, 0
            , 0, 0) //
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.white
        tableView.scrollsToTop = false
        
        tableView.isScrollEnabled = true
        
        // Preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        
        tableView.selectRow(at: IndexPath(row: selectedMenuItem, section: 0), animated: false, scrollPosition: .middle)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MyMenuTableViewController.reloadTableView), name: Notification.Name(Constants.userLoggedOutNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MyMenuTableViewController.reloadTableView), name: Notification.Name(Constants.loginSuccessNotification), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateMenu()
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func updateMenu()
    {
        //        if UserDefaults.standard.value(forKey: "Authentication") != nil
        //        {
        //            self.listArray = self.afterLoginListArray
        //
        //            if let login = UserDefaults.standard.value(forKey:"LoginType") as? String
        //            {
        //                loginType = login
        //                if loginType == "FaceBook" || loginType == "Gmail"
        //                {
        //                    self.listArray.remove(at: 3)
        //                }
        //            }
        //        }
        //        else
        // {
        self.listArray = self.afterLoginListArray
        
        //}
        tableView.reloadData()
    }
    
    func reloadTableView() {
        self.tableView.reloadData()
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if AppManager.isUserLoggedIn {
            if (AppManager.getLoggedInUserType() == .salesExecutive) {
                return SalesRepMenu.countEnums()
            } else {
                return LoggedInUser.countEnums()
            }
        } else {
            return NewUser.countEnums()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if UIDevice.current.userInterfaceIdiom == .pad {
			return 350.0
		} else {
			return 200.0
		}
		
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = tableView.dequeueReusableCell(withIdentifier: "menuheadercell") as! MenuHeaderTableViewCell
        
        if AppManager.isUserLoggedIn {
            if let userName = UserDefaultManager.sharedManager().userFirstName {
                headerView.welcomeMessageLabel.text = NSLocalizedString("Hello", comment: "") + " " + userName
            }
        } else {
            headerView.welcomeMessageLabel.text = NSLocalizedString("Welcome to Alzahrani", comment: "")
        }
        //if UserDefaults.standard.value(forKey: "usertoken") != nil
        //{
        // if FileManager.default.fileExists(atPath: Constants().userProfileImagePath())
        //{
        //headerView.userImage.image = Constants().userProfileImage()
        
        //}
        
        // headerView.userName.text = Utilities.getValueFromUserDefults(for:"UserName") as! String?
        // headerView.usermobile.text = Utilities.getValueFromUserDefults(for: "UserMobile") as! String?
        //headerView.useremail.text = Utilities.getValueFromUserDefults(for:"UserEmail") as! String?
        //        headerView.userName.text = "Alahara"
        //        headerView.usermobile.text = "1234567890"
        //        headerView.useremail.text = "shilpa@hardwinsoftware.com"
        //            headerView.userName.font = UIFont(name: "ProximaNova-Regular", size: 10)
        //            headerView.usermobile.font = UIFont(name: "ProximaNova-Regular", size: 10)
        //            headerView.useremail.font = UIFont(name: "ProximaNova-Regular", size: 10)
//        headerView.dismissButton.addTarget(self,action: #selector(MyMenuTableViewController.dismissAction), for: .touchUpInside)
        
        // }
        
        
        //headerView.userImage.layer.cornerRadius = headerView.userImage.frame.size.width / 2
        //headerView.userImage.layer.masksToBounds = true
        
        //         headerView.userImage.layer.borderColor = UIColor(red: 235/255, green: 62/255, blue: 16/255, alpha: 1).cgColor
        //         headerView.userImage.layer.borderWidth = 1
        
        return headerView
        
    }
    
    func dismissAction(){
        //AppManager.setDefaultRootViewController(state: .Home)
        self.dismiss(animated:true, completion:nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let menuCell = tableView.dequeueReusableCell(withIdentifier: "MenuCustomTableViewCells", for: indexPath) as? MenuCustomTableViewCells
        
        if AppManager.isUserLoggedIn {
            if AppManager.getLoggedInUserType() == .salesExecutive {
                let logoImage = SalesRepMenu.enumValues[indexPath.row].getImage()
                menuCell?.menuFieldImageView.image = UIImage(named: logoImage)
                let menuLabel = SalesRepMenu.enumValues[indexPath.row].rawValue
                menuCell?.menuFieldNameLabel.text = NSLocalizedString(menuLabel, comment: "")
            } else {
                let logoImage = LoggedInUser.enumValues[indexPath.row].getImage()
                menuCell?.menuFieldImageView.image = UIImage(named: logoImage)
                let menuLabel = LoggedInUser.enumValues[indexPath.row].rawValue
                menuCell?.menuFieldNameLabel.text = NSLocalizedString(menuLabel, comment: "")
            }
        } else {
            let logoImage = NewUser.enumValues[indexPath.row].getImage()
            menuCell?.menuFieldImageView.image = UIImage(named: logoImage)
            let menuLabel = NewUser.enumValues[indexPath.row].rawValue
            menuCell?.menuFieldNameLabel.text = NSLocalizedString(menuLabel, comment: "")
        }
		
		if UIDevice.current.userInterfaceIdiom == .pad {
			menuCell?.menuFieldNameLabel.font = UIFont.boldSystemFont(ofSize: 24.0)
		} else {
			menuCell?.menuFieldNameLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
		}
        return menuCell!
        //    var cell = tableView.dequeueReusableCell(withIdentifier: "CELL")
        //
        //    if (cell == nil) {
        //
        //        cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "CELL")
        //        cell!.backgroundColor = UIColor.clear
        //        cell?.selectionStyle = UITableViewCellSelectionStyle.none
        //        let label = UILabel(frame: CGRect(x: 60, y: 18, width: 200, height: 25))
        //        label.textColor = UIColor.black
        //        label.font = UIFont(name: "ProximaNova-Regular", size: 12)
        //        label.text = self.listArray[indexPath.row]
        //
        //
        //        label.tag = 1
        //        cell!.addSubview(label)
        //        var logoImage : UIImageView
        //        logoImage  = UIImageView(frame:CGRect(x: 10, y: 18, width: 25, height: 25))
        //        logoImage.image = UIImage(named:self.imageArray[(indexPath as NSIndexPath).row] )
        //        logoImage.layer.borderColor = UIColor(red: 235/255, green: 62/255, blue: 16/255, alpha: 1).cgColor
        // logoImage.layer.borderWidth = 1
        //        logoImage.tag = 2
        //        cell!.addSubview(logoImage)
        //
        //    //  cell?.accessoryType = .disclosureIndicator
        //        return cell!
        
        
        
        //    }
        //    let label = cell?.viewWithTag(1) as? UILabel
        //    label!.text = self.listArray[indexPath.row]
        //
        //    let iconimageView = cell?.viewWithTag(2) as? UIImageView
        //    iconimageView!.image = UIImage(named:self.imageArray[(indexPath as NSIndexPath).row] )
        //    return cell!
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		
		if UIDevice.current.userInterfaceIdiom == .pad {
			return 80.0
		} else {
			return 40.0
		}
		
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var menuTappedInfo = [String: AnyObject]()
        
        if AppManager.isUserLoggedIn {
            if AppManager.getLoggedInUserType() == .salesExecutive {
                let tappedFieldInfo = SalesRepMenu.enumValues[indexPath.row]
                menuTappedInfo = [Constants.keyLogin: tappedFieldInfo as AnyObject]
            } else {
                let tappedFieldInfo = LoggedInUser.enumValues[indexPath.row]
                menuTappedInfo = [Constants.keyLogin: tappedFieldInfo as AnyObject]
            }
        } else {
            let tappedFieldInfo = NewUser.enumValues[indexPath.row]
            menuTappedInfo = [Constants.keyLogin: tappedFieldInfo as AnyObject]
        }
        
//        switch (indexPath.row) {
//        case 0:
//            break
//        case 1:
////            if let loginViweController = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
////                self.navigationController?.pushViewController(loginViweController, animated: true)
////            }
//            
//            break
//        case 2:
//            
//            break
//        case 3:
//            
//            break
//        case 4:
//            
//            break
//            
//        case 5:
//            
//            break
//        case 6:
//            break
//        case 7:
//            break
//        case 8:
//            break
//            
//            
//        //  Constants.application.keyWindow?.rootViewController = destViewController
//        default:
//            break
//        }
        
        NotificationCenter.default.post(name: Notification.Name(Constants.sliderMenuFieldTapNotification), object: nil, userInfo: menuTappedInfo)
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}






