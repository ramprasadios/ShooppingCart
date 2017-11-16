//
//  NewAddressViewController.swift
//  Alzahrani
//
//  Created by shilpa shree on 5/23/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class NewAddressViewController: UIViewController {

    @IBOutlet weak var addressTextView: UITextView!
    
    @IBOutlet weak var backupView: UIView!
    
    @IBOutlet weak var holderView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

         setup()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setup(){
        addressTextView.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(NewAddressViewController.closeSearchPopUP))
        self.backupView.addGestureRecognizer(tapGesture)
    }
    
    func closeSearchPopUP()
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitAction(_ sender: Any) {
        
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
extension NewAddressViewController:UITextViewDelegate{
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == addressTextView{
            textView.returnKeyType = .done
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView == addressTextView{
            textView.returnKeyType = .done
            return true
        }
        return false
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
}
