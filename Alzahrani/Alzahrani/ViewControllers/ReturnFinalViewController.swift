//
//  ReturnFinalViewController.swift
//  Alzahrani
//
//  Created by shilpa shree on 5/29/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class ReturnFinalViewController: UIViewController {
    @IBOutlet weak var backView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
setup()
        // Do any additional setup after loading the view.
    }
    func setup(){
       
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ReturnFinalViewController.closePopUP))
        self.backView.addGestureRecognizer(tapGesture)
        
        
        
    }
    func closePopUP()
    {
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
