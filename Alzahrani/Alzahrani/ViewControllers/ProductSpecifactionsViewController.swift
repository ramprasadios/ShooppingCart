//
//  ProductSpecifactionsViewController.swift
//  Alzahrani
//
//  Created by Hardwin on 03/07/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class ProductSpecifactionsViewController: UIViewController {
    
    var specificationInfo = [ProductSpecification]()

    @IBOutlet weak var productSpecificationTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableViewSetup()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.title = NSLocalizedString("SPECIFICATION", comment: "")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension ProductSpecifactionsViewController {
    
    func tableViewSetup() {
		
	  self.productSpecificationTableView.estimatedRowHeight = 44.0
		self.productSpecificationTableView.rowHeight = UITableViewAutomaticDimension
        let cellNib = UINib(nibName: SpecificationsTableViewCell.selfName(), bundle: nil)
        self.productSpecificationTableView.register(cellNib, forCellReuseIdentifier: SpecificationsTableViewCell.selfName())
        let sectionNib = UINib(nibName: ProductSpecificationHeaderView.selfName(), bundle: nil)
        self.productSpecificationTableView.register(sectionNib, forHeaderFooterViewReuseIdentifier: ProductSpecificationHeaderView.selfName())
    }
}

//MARK:- UITableViewDataSource:
extension ProductSpecifactionsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.specificationInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SpecificationsTableViewCell.selfName(), for: indexPath) as? SpecificationsTableViewCell
        
        cell?.specificationTitle.text = self.specificationInfo[indexPath.row].details ?? ""
        cell?.specificationDetail.text = self.specificationInfo[indexPath.row].title ?? ""
		
		if UIDevice.current.userInterfaceIdiom == .pad {
			cell?.specificationTitle.font = UIFont.systemFont(ofSize: 24.0)
			cell?.specificationDetail.font = UIFont.systemFont(ofSize: 24.0)
		} else {
			cell?.specificationTitle.font = UIFont.systemFont(ofSize: 14.0)
			cell?.specificationDetail.font = UIFont.systemFont(ofSize: 14.0)
		}
		
        return cell!
    }
}

extension ProductSpecifactionsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionView = tableView.dequeueReusableHeaderFooterView(withIdentifier: ProductSpecificationHeaderView.selfName()) as? ProductSpecificationHeaderView
        return sectionView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
}
