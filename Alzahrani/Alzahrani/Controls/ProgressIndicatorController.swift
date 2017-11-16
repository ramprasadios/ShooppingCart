//
//  ProgressIndicatorController.swift
//  nHance
//
//  Created by Ramprasad A on 02/03/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class ProgressIndicatorController: UIViewController {
    
    class var sharedProgressController: ProgressIndicatorController {
        struct Static {
            static let storyBoard = UIStoryboard(name: Constants.storyBoardMain, bundle: nil)
            static let instance = storyBoard.instantiateViewController(withIdentifier: ProgressIndicatorController.selfName()) as! ProgressIndicatorController
        }
        return Static.instance
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBOutlet weak var progressIndicationView: ProgressIndicatorView!
    
    var activityIndicator: UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
    }
}

extension ProgressIndicatorController {
    
	func updateProgress(withProgress progress: Float? = nil) {
		if let progressValue = progress {
			self.progressIndicationView.progressView?.progress = progressValue
			if (self.progressIndicationView.progressView?.progress == 1.0) {
				self.progressIndicationView.progressView.progress = 0.0
			}
		}
    }
	
    @discardableResult
    class func showLoading(withText message: String? = NSLocalizedString("Please Wait...", comment: ""), closure : @escaping (_ some: ProgressIndicatorController) -> Void = { _ in }) {
        
        DispatchQueue.main.async { 
            let progressView = ProgressIndicatorController.sharedProgressController
            progressView.modalPresentationStyle = .overCurrentContext
            progressView.definesPresentationContext = true
            AppDelegate.currentController()?.present(progressView, animated: false, completion: nil)
            
            progressView.progressIndicationView.mainLabel.text = message
            progressView.progressIndicationView.progressContainer.isHidden = false
            progressView.progressIndicationView.progressView?.isHidden = true
            if let image = UIImage(named: "checked") {
                let circleLoader = CircleLoader(frame: CGRect(x: 0, y: 0, width: 38.0, height: 38.0), centreImage: image, isAnimating: true)
                progressView.progressIndicationView.progressContainer.addSubview(circleLoader)
                
                closure(progressView)
            }
        }
    }
    
    @discardableResult
    class func showProgress(withText message: String? = NSLocalizedString("Please Wait...", comment: ""), closure : @escaping (_ some: ProgressIndicatorController) -> Void = { _ in }) {
        
        DispatchQueue.main.async { 
            let progressView = ProgressIndicatorController.sharedProgressController
            
            progressView.modalPresentationStyle = .overCurrentContext
            progressView.definesPresentationContext = true
            AppDelegate.currentController()?.present(progressView, animated: false, completion: nil)
            
            progressView.progressIndicationView.mainLabel.text = message
            progressView.progressIndicationView.progressView?.isHidden = false
            progressView.progressIndicationView.progressContainer.isHidden = true
            
            closure(progressView)
        }
    }
    
    class func dismissProgressView(withSuccessHandler successHandler: SuccessHandler? = nil) {
        
        DispatchQueue.main.async { 
            let progressView = ProgressIndicatorController.sharedProgressController
            progressView.dismiss(animated: false, completion: {
                successHandler?(true)
            })

        }
    }
}


