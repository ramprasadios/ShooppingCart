//
//  ExpandableSectionsView.swift
//  Alzahrani
//
//  Created by Hardwin on 08/05/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

protocol HandleSectionExpansionDelegate: NSObjectProtocol {
    func didTapSectionView(_ sectionHeaderView: ExpandableSectionsView?, atSectionIndex index: Int)
    func didTapSectionHeaderView(atSection section: Int)
}

class ExpandableSectionsView: UITableViewHeaderFooterView {

    //Properties:
    weak var sectionDelegate: HandleSectionExpansionDelegate?
    var isSectionTapped: Bool = false
    
    //IB-Outlet:
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var subCategoryName: UILabel!
    
    
    
    //MARK:- Life Cycle
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupTapGesture()
    }

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.setupTapGesture()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if AppManager.languageType() == .english {
            self.moreButton.setImage(UIImage(named: "right_arrow_icon"), for: .normal)
            self.moreButton.setImage(UIImage(named: "right_arrow_icon"), for: .highlighted)
        } else {
            self.moreButton.setImage(UIImage(named: "left_arrow_icon"), for: .normal)
            self.moreButton.setImage(UIImage(named: "left_arrow_icon"), for: .highlighted)
        }
    }
    
    @IBAction func expandCurrentSectionTapped(_ sender: UIButton) {
        self.sectionDelegate?.didTapSectionView(self, atSectionIndex: sender.tag)
    }
}

extension ExpandableSectionsView {
    func setupTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(ExpandableSectionsView.handleTap))
        self.addGestureRecognizer(tap)
    }
    
    func handleTap() {
        self.sectionDelegate?.didTapSectionHeaderView(atSection: self.moreButton.tag)
    }
    
}
