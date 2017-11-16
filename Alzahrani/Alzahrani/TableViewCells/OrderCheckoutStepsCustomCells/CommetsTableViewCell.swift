//
//  CommetsTableViewCell.swift
//  Alzahrani
//
//  Created by Hardwin on 13/07/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

protocol CommentsStepDelegate: NSObjectProtocol {
    func didTapCommentsContinueButton(atCell cell: CommetsTableViewCell)
    func didTapDoneButton(atCell cell: CommetsTableViewCell)
    func didTapPolicyButton()
}

class CommetsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var commentsTextView: UITextView!
		@IBOutlet weak var termsAndConditionsCheckbox: CheckBox!
	
    
    weak var delegate: CommentsStepDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initialUISetup()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func continueButtonTapped(_ sender: Any) {
        self.delegate?.didTapCommentsContinueButton(atCell: self)
    }
    
    @IBAction func policyButtonTapped(_ sender: Any) {
        self.delegate?.didTapPolicyButton()
    }
}

extension CommetsTableViewCell {
    
    func initialUISetup() {
        self.commentsTextView.delegate = self
        self.commentsTextView.layer.borderWidth = 2.0
        self.commentsTextView.layer.borderColor = UIColor.lightGray.cgColor
    }
}

extension CommetsTableViewCell: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
            textView.resignFirstResponder()
            self.delegate?.didTapDoneButton(atCell: self)
            return false
        } else {
            return true
        }
    }
}
