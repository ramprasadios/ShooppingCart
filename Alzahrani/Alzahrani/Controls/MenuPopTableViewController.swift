//
//  MenuPopTableViewController.swift
//  nHance
//
//  Created by Ramprasad A on 04/06/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation
import UIKit

protocol MenuPopViewControllerDelegate: NSObjectProtocol {
    func numberOfMenu() -> Int
    func menuNameAtIndexPath(indexPath: IndexPath) -> String
    func didSelectMenuAtIndexPath(indexPath: IndexPath,
                                  menuController: MenuPopTableViewController)
}

class MenuPopTableViewController: UITableViewController {
    
    weak var delegate: MenuPopViewControllerDelegate?
    let menuCellIdentifier = "MenuCell"
    var sourceView: UIView?
    var contentSize: CGSize?
    var arrowDirection = UIPopoverArrowDirection.any
    var barButtonItem: UIBarButtonItem?
    var sourceRect: CGRect?
    
    required init!(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .popover
        popoverPresentationController!.delegate = self
    }
    
    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.popoverPresentationController?.backgroundColor = UIColor.clear
        self.tableView.backgroundView = nil
    }
    
    deinit {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.preferredContentSize = contentSize!
    }
    
    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        preferredContentSize = contentSize!
        popoverPresentationController.sourceRect = sourceRect!
        popoverPresentationController.permittedArrowDirections = self.arrowDirection
    }
}

//MARK: - UITableViewDataSource
extension MenuPopTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return delegate!.numberOfMenu()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: menuCellIdentifier, for: indexPath)
        cell.textLabel!.text = delegate?.menuNameAtIndexPath(indexPath: indexPath)
        cell.textLabel?.font = UIFont.systemFont(ofSize: 12.0)
        return cell
    }
}

//MARK: - UITableViewDelegate
extension MenuPopTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true, completion: nil)
        delegate?.didSelectMenuAtIndexPath(indexPath: indexPath, menuController: self)
    }
}

//MARK: - UIPopoverPresentationControllerDelegate
extension MenuPopTableViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        return UINavigationController(rootViewController: self)
    }
}

