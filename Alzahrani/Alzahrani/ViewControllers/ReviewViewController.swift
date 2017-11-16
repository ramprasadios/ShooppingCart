//
//  ReviewViewController.swift
//
//
//  Created by shilpa shree on 5/18/17.
//
//

import UIKit

protocol ReviewHandlerDelegate: NSObjectProtocol {
    func didFinishReviewProduct()
}

struct ReviewsModel {
    let authorName: String
    let reviewText: String
    let ratingsCount: String
    
    init(withAuthorName author: String, andReviewText text: String, withRatings ratings: String) {
        self.authorName = author
        self.reviewText = text
        self.ratingsCount = ratings
    }
}

class ReviewViewController: UIViewController {
    
    //@Mark-IBOutlet
    
    @IBOutlet weak var reviewTableView: UITableView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var headingLabel: PaddingLabel!
    @IBOutlet weak var reviewTextView: UITextView!
    
    
    weak var reviewDelegate: ReviewHandlerDelegate?
    //@Mark - Properties
    var totalReview = ""
    var produtID = ""
    var text = ""
    var rating = 0
    var activeField:AnyObject!
    var textArray = [String]()
    var reviewArray = [String]()
    var reviewsDataArray = [ReviewsModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetUp()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func  initialSetUp(){
        reviewTableView.estimatedRowHeight = 90.0
        reviewTableView.rowHeight = UITableViewAutomaticDimension
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            
            self.getReviews()
            
        }
        addNotificationObservers()
        reviewTableView.delegate = self
        reviewTableView.dataSource = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ReviewViewController.closePopUP))
        self.backView.addGestureRecognizer(tapGesture)
    }
    func keyboardWillShow(_ notification:Notification)
    {
        adjustingHeight(true, notification: notification)
    }
    
    func keyboardWillHide(_ notification:Notification)
    {
        self.reviewTableView.contentInset = UIEdgeInsets.zero
        self.reviewTableView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
    func adjustingHeight(_ show:Bool, notification:Notification) {
        
        self.reviewTableView.isScrollEnabled = true
        let info : NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        var height:CGFloat = 0
        
        if activeField is UITextView
        {
            height = CGFloat(Constants.resizeWithoutToolbar)
        }
        else if activeField is  UITextField
        {
            height = CGFloat(Constants.resizeWithoutToolbar)
        }
        
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height + height, 0.0)
        
        self.reviewTableView.contentInset = contentInsets
        self.reviewTableView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.reviewTableView.frame
        aRect.size.height -= (keyboardSize!.height + height)
        if let activeFieldPresent = activeField
        {
            if (!aRect.contains(activeFieldPresent.frame.origin))
            {
                self.reviewTableView.scrollRectToVisible(activeFieldPresent.frame, animated: true)
            }
        }
    }
    
    func addNotificationObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(ReviewViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ReviewViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    func closePopUP(){
        self.reviewDelegate?.didFinishReviewProduct()
        self.dismiss(animated:true,completion:nil)
    }
    //@Mark:- API Methods
    func submitReview(){
        
        let cell = self.reviewTableView.cellForRow(at:IndexPath.init(row:self.reviewsDataArray.count, section: 0)) as! WriteNewTableViewCell
        if cell.reviewTextView.text.characters.count < 2{
            let alertController = UIAlertController(title: Constants.alertTitle, message:
                NSLocalizedString("REVIEW_ERROR_MESSAGE", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: { (UIAlertAction) in
                //self.dismiss(animated: true, completion: nil)
            })
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
        if self.rating == 0{
            let alertController = UIAlertController(title: Constants.alertTitle, message:
                NSLocalizedString("PLEASE_SELECT_RATING", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: Constants.alertAction, style: UIAlertActionStyle.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
        else{
            let userDefaults = UserDefaultManager.sharedManager()
            if let userFirstName = userDefaults.userFirstName, let userId =  userDefaults.loginUserId {
                
                let languageId = (AppManager.languageType() == .english) ? "1" : "2"
                let parameter = "name=\(userFirstName)&text=\(cell.reviewTextView.text!)&rating=\(self.rating)&customer_id=\(userId)&product_id=\(self.produtID)&language_id=\(languageId)"
                print("body",parameter)
                
                SyncManager.syncOperation(operationType: .writeReview, info: parameter, completionHandler: { (result, error) in
                    if error == nil {
                        NSLog("reviewlist \(result)")
                        if let successResponse = result as? [String: AnyObject] {
                            DispatchQueue.main.async {
                                
                                if let successMessage = successResponse["success"] as? String {
                                    let alertController = UIAlertController(title: Constants.alertTitle, message:
                                        successMessage, preferredStyle: UIAlertControllerStyle.alert)
                                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: { (UIAlertAction) in
                                        self.dismiss(animated: true, completion: {
                                            self.reviewDelegate?.didFinishReviewProduct()
                                        })
                                    })
                                    alertController.addAction(okAction)
                                    self.present(alertController, animated: true, completion: nil)
                                }
                            }
                        }
                    } else {
                        print("Error writing review")
                    }
                })
                
                /*WebserviceEngine().requestforProductAPI(service: "writeReview", method: "POST", token: "", body: parameter, productBody: NSData()) { (result, error) in
                    if result != nil
                    {
                        NSLog("reviewlist \(result)")
                        if let successResponse = result as? [String: AnyObject] {
                            DispatchQueue.main.async {
                                if let successMessage = successResponse["success"] as? String {
                                    let alertController = UIAlertController(title: Constants.alertTitle, message:
                                        successMessage, preferredStyle: UIAlertControllerStyle.alert)
                                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: { (UIAlertAction) in
                                        self.dismiss(animated: true, completion: nil)
                                    })
                                    alertController.addAction(okAction)
                                    self.present(alertController, animated: true, completion: nil)
                                }
                            }
                        }
                        DispatchQueue.main.sync(execute: { () -> Void in
                            SwiftLoader.hide()
                        })
                    }
                    else
                    {
                        if (error!.value(forKey: "code") as! NSNumber).stringValue == "-1001"
                        {
                            DispatchQueue.main.sync(execute: { () -> Void in
                                SwiftLoader.hide()
                                let alertController = UIAlertController(title: Constants.alertTitle, message:
                                    "internet too slow", preferredStyle: UIAlertControllerStyle.alert)
                                alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil))
                                self.present(alertController, animated: true, completion: nil)
                            })
                        }
                        if (error!.value(forKey: "code") as! NSNumber).stringValue == "-1009"
                        {
                            DispatchQueue.main.sync(execute: { () -> Void in
                                SwiftLoader.hide()
                                let alertController = UIAlertController(title: Constants.alertTitle, message:
                                    "check your internet connection", preferredStyle: UIAlertControllerStyle.alert)
                                alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil))
                                self.present(alertController, animated: true, completion: nil)
                                
                            })
                        }
                    }
                }*/
            }
        }
    }
    
    func getReviews(){
        
        let languageId = (AppManager.languageType() == .english) ? "1" : "2"
        WebserviceEngine().requestforAPI(service: "customer/getProductReviewsId&product_id=\(self.produtID)&language_id=\(languageId)", method: "GET", token: "", body: "", productBody: NSData()) { (result, error) in
            if result != nil
            {
                NSLog("reviewlist \(result)")
                DispatchQueue.main.sync(execute: { () -> Void in
                    SwiftLoader.hide()
                    if let records = result?.value(forKey:"records"){
                        if let newrecords = records as? [[String: AnyObject]] {
                            for reivew in newrecords {
                                if let author = reivew["author"] as? String, let ratingsCount = reivew["rating"] as? String, let reviewText = reivew["text"] as? String {
                                    
                                    let reviewData = ReviewsModel(withAuthorName: author, andReviewText: reviewText, withRatings: ratingsCount)
                                    self.reviewsDataArray.append(reviewData)
                                    
                                }
                                /*let text = reivew["text"] as! String
                                
                                self.textArray.append(text)
                                let rating = reivew["rating"] as! String
                                self.reviewArray.append(rating) */
                                
                            }
                        }
                        
                    }
                    
                    print("textarray",self.textArray)
                    
                    //DispatchQueue.main.sync(execute: { () -> Void in
                    self.reviewTableView.reloadData()
                })
            }
            else
            {
                if (error!.value(forKey: "code") as! NSNumber).stringValue == "-1001"
                {
                    DispatchQueue.main.sync(execute: { () -> Void in
                        SwiftLoader.hide()
                        let alertController = UIAlertController(title: Constants.alertTitle, message:
                            "internet too slow", preferredStyle: UIAlertControllerStyle.alert)
                        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                    })
                }
                if (error!.value(forKey: "code") as! NSNumber).stringValue == "-1009"
                {
                    DispatchQueue.main.sync(execute: { () -> Void in
                        SwiftLoader.hide()
                        let alertController = UIAlertController(title: Constants.alertTitle, message:
                            "check your internet connection", preferredStyle: UIAlertControllerStyle.alert)
                        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                        
                    })
                }
            }
        }
    }
}
extension  ReviewViewController:ButtonRating {
    func sendRating(ratng:Int){
        self.rating = ratng
    }
}
extension ReviewViewController:UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row != reviewsDataArray.count) {
        return UITableViewAutomaticDimension
    } else{
        return 168
        }
    }
    
}
extension ReviewViewController:UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int{
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.reviewsDataArray.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row != reviewsDataArray.count) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "WriteReviewCell", for: indexPath) as! WriteReviewTableViewCell
            cell.reviewHeadLabel.text = self.reviewsDataArray[indexPath.row].authorName
            cell.reviewHeadingLabel.text = self.reviewsDataArray[indexPath.row].reviewText
            let rating = self.reviewsDataArray[indexPath.row].ratingsCount
                if rating == "1"{
                    cell.starImageOne.image = UIImage(named:"star_icon_yellow")
                }
                if rating == "2"{
                    cell.starImageOne.image = UIImage(named:"star_icon_yellow")
                    cell.starImageTwo.image = UIImage(named:"star_icon_yellow")
                }
                if rating == "3"{
                    cell.starImageOne.image = UIImage(named:"star_icon_yellow")
                    cell.starImageTwo.image = UIImage(named:"star_icon_yellow")
                    cell.starImageThree.image = UIImage(named:"star_icon_yellow")
                }
                if rating == "4"{
                    cell.starImageOne.image = UIImage(named:"star_icon_yellow")
                    cell.starImageTwo.image = UIImage(named:"star_icon_yellow")
                    cell.starImageThree.image = UIImage(named:"star_icon_yellow")
                    cell.starImageFour.image = UIImage(named:"star_icon_yellow")
                }
                if rating == "5"{
                    cell.starImageOne.image = UIImage(named:"star_icon_yellow")
                    cell.starImageTwo.image = UIImage(named:"star_icon_yellow")
                    cell.starImageThree.image = UIImage(named:"star_icon_yellow")
                    cell.starImageFour.image = UIImage(named:"star_icon_yellow")
                    cell.starImageFive.image = UIImage(named:"star_icon_yellow")
                }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "secondcell", for: indexPath) as! WriteNewTableViewCell
            cell.rateCotrol.buttonDelegate = self
            
            cell .reviewTextView.delegate = self
            
            cell .reviewTextView.layer.borderWidth = 1
            cell.reviewTextView.layer.borderColor = UIColor.lightGray.cgColor
            cell.reviewTextView.layer.cornerRadius = 3
            cell.reviewTextView.layer.masksToBounds = true
            cell.reviewTextView.text = "Write your reivew here"
            cell.reviewTextView.textColor = UIColor.lightGray
            cell.submitButton.addTarget(self, action: #selector(ReviewViewController.submitReview), for: UIControlEvents.touchUpInside)
            
            return cell
        }
    }
}

extension ReviewViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
        textView.returnKeyType = .done
        
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        activeField = textView
        textView.returnKeyType = .done
        return true
        //}
        
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
}
