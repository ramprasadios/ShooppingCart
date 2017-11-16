//
//  ListViewController.swift
//  Yatchtzapp
//
//  Created by Ashok Kumar on 04/10/16.
//  Copyright © 2016 hardwin. All rights reserved.
//

import UIKit

protocol listDelegate
{
    func selectedList(_ listValue: NSString,selectedrow:Int)->Void
}

class ListViewController: UITableViewController {
    
    var delegate: listDelegate! = nil
    var listArray = [AnyObject]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "ListTableViewCell", bundle: nil), forCellReuseIdentifier: "listcell")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return listArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listcell", for: indexPath) as! ListTableViewCell
        cell.selectionStyle = .none
        cell.areaLabel.text = listArray[indexPath.row] as? String
        
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        delegate!.selectedList(listArray[indexPath.row] as! NSString,selectedrow: indexPath.row)
        self.dismiss(animated: true, completion: nil)
    }
    
    func prepareForPopoverPresentation(popoverPresentationController: UIPopoverPresentationController) {
        popoverPresentationController.permittedArrowDirections = .any
        
    }
}
