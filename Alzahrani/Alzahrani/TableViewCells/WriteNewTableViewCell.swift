//
//  WriteNewTableViewCell.swift
//  Alzahrani
//
//  Created by shilpa shree on 5/25/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class WriteNewTableViewCell: UITableViewCell {
    @IBOutlet weak var rateCotrol: RatingControl!

    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var reviewTextView: UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//       // self.reviewTextView.delegate = self
//        reviewTextView.layer.borderWidth =
//        1
//        reviewTextView.layer.borderColor = UIColor.lightGray.cgColor
//        reviewTextView.layer.cornerRadius = 3
//        reviewTextView.layer.masksToBounds = true
        
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
}

extension WriteNewTableViewCell: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == reviewTextView{
            textView.returnKeyType = .done
        }
        
    }
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView == reviewTextView{
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
