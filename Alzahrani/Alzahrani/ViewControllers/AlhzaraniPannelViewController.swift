//
//  AlhzaraniPannelViewController.swift
//  Alzahrani
//
//  Created by Hardwin on 11/05/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

enum SlideMasterState: Int {
    case HideMaster = 0,
    ShowMaster
    
    func toString() -> String {
        return "\(self.rawValue)"
    }
}

class AlhzaraniPannelViewController: UIViewController {
    
    fileprivate var sliderState = SlideMasterState.HideMaster
    
    var sliderStatus: SlideMasterState {
        get {
            return sliderState
        } set {
            sliderState = newValue
            self.updateMasterState()
        }
    }
    
    ///Controller to display Menu Slider
    fileprivate var masterViewController: MyMenuTableViewController? {
        willSet {
            if self.masterViewController != nil {
                self.masterViewController?.view.removeFromSuperview()
                self.masterViewController?.removeFromParentViewController()
            }
        } didSet {
            if self.masterViewController != nil {
                self.view.addSubview(self.masterViewController!.view)
                self.addChildViewController(self.masterViewController!)
            }
        }
    }
    
    ///To display TaBar Controller
    fileprivate var detailViewController: HomeViewController? {
        willSet {
            if self.detailViewController != nil {
                self.detailViewController?.view.removeFromSuperview()
                self.detailViewController?.removeFromParentViewController()
            }
        } didSet {
            if self.detailViewController != nil {
                self.view.addSubview(self.detailViewController!.view)
                self.addChildViewController(self.detailViewController!)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.showMainScreenController()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNotificationObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.updateMasterState()
    }
    
    @IBAction func handleRightGesture(_ sender: Any) {
//            self.sliderStatus = .ShowMaster
    }
    
    @IBAction func handleLeftGesture(_ sender: Any) {
//        if self.sliderStatus == .ShowMaster {
//            self.sliderStatus = .HideMaster
//        }
    }
}

extension AlhzaraniPannelViewController {
    
    fileprivate func showMainScreenController() {
        if AppDelegate.delegate().isInitialDownload! {
//            self.initialProductDownload()
        }
        
        self.initialRootController()
    }
    
    func initialRootController() {
        
        let storyBoard = UIStoryboard(name: Constants.storyBoardMain, bundle: nil)
        
        let mainNavigationViewController: HomeViewController = storyBoard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        
        let menuViewController: MyMenuTableViewController = storyBoard.instantiateViewController(withIdentifier: "MyMenuTableViewController") as! MyMenuTableViewController
        
        mainNavigationViewController.sliderDelegate = self
        self.detailViewController = mainNavigationViewController
        self.masterViewController = menuViewController
        
        self.sliderStatus = .HideMaster
    }
    
    func initialProductDownload() {
        let backgroundQueue = DispatchQueue(label: "BackgroundQueue", attributes: .concurrent)
        backgroundQueue.async {
            if AppManager.currentApplicationMode() == .offline {
                ProductsDownloader.sharedInstance.configureDownload(withType: .firstTime)
                AppDelegate.delegate().isInitialDownload = false
            }
        }
    }
}


extension AlhzaraniPannelViewController {
    
    fileprivate func updateMasterState() {
        
        switch sliderState {
        case .HideMaster:
            self.hideMaster()
        case .ShowMaster:
            self.showMaster()
        }
    }
    
    private func showMaster() {
        guard self.masterViewController != nil else {
            return
        }
        
        self.detailViewController?.dimOverlay(direction: .ShowDim, color: UIColor.black, alpha: 0.3, duration: 0.3, animationBlock: {
            
            let screenSize = UIScreen.main.bounds
			var screenWidth: CGFloat!
			if UIDevice.current.userInterfaceIdiom == .pad {
				screenWidth = screenSize.width * 0.4
			} else {
				screenWidth = screenSize.width * 0.7
			}
            let remainingWidth = screenSize.width - screenWidth
            if LanguageType(rawValue: UserDefaultManager.sharedManager().selectedLanguageId!) == .arabic {
                self.masterViewController?.view.frame = CGRect(x: self.view.frame.origin.x + remainingWidth, y: self.view.frame.origin.y, width: screenWidth, height: screenSize.height)
            } else {
                self.masterViewController?.view.frame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y, width: screenWidth, height: screenSize.height)

            }
            
        }, dimGestureHandler: { (tapped) in
            self.sliderStatus = .HideMaster
            
        }, completionBlock: { (comBlock) in
        })
    }
    
    private func hideMaster() {
        
        guard self.masterViewController != nil else {
            return
        }
        self.detailViewController?.dimOverlay(direction: .RemoveDim, color: UIColor.black, alpha: 0.3, duration: 0.3, animationBlock: {
            
            let screenSize = UIScreen.main.bounds
            self.masterViewController?.view.frame = CGRect(x: 0, y: self.view.frame.origin.y, width: 0, height: screenSize.height)
            
        }, dimGestureHandler: { (tapped) in
            
        }, completionBlock: { (comBlock) in
            
        })
    }
    
    func setNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(AlhzaraniPannelViewController.hambergerMenuButtonTapped), name: Notification.Name(Constants.hambergerTappedNotification), object: nil)
    }

    func hambergerMenuButtonTapped() {
        if self.sliderStatus == .HideMaster {
            self.sliderStatus = .ShowMaster
        }
    }
}

//MARK:- SlideMenuDelegate
extension AlhzaraniPannelViewController : ProgramMenuDelegate {
    
    func handleSlideOperation(menuState master : MenuMaster , slideState state : SlideMasterState) {
        self.sliderStatus = state
    }
}


