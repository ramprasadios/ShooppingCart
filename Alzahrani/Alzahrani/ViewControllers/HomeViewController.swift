//
//  HomeViewController.swift
//  Alzahrani
//
//  Created by Hardwin on 28/04/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class HomeViewController: UITabBarController {
    
    //Properties:
    weak var sliderDelegate: ProgramMenuDelegate?
    
    //IB-Outlet:
    @IBOutlet weak var menuTabBar: UITabBar!
    
    //MARK:- Life Cycle:
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.initialUISetup()
        self.addNotificationObserver()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
    }
}

//MARK:- Helper Methods:
extension HomeViewController {
    
    func initialUISetup() {
        self.menuTabBar = UITabBar.appearance()
        self.menuTabBar.barTintColor = UIColor.clear
        self.menuTabBar.backgroundImage = UIImage()
        self.menuTabBar.shadowImage = UIImage()
    }
    
    func addNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.hideNavigationSlider), name: NSNotification.Name(rawValue: Constants.sliderMenuFieldTapNotification), object: nil)
    }
    
    func hideNavigationSlider(notification: Notification) {

        self.sliderDelegate?.handleSlideOperation(menuState: .Home, slideState: .HideMaster)
        self.selectedIndex = 0
    }
}

extension HomeViewController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        print("Current View Controller selected is \(viewController)")
    }
}
