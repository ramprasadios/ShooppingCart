//
//  EDropdownList.swift
//  EDropdownList
//
//  Created by Lucy Nguyen on 11/10/15.
//  Copyright © 2015 econ. All rights reserved.
//
//  This class is used for creating custom dropdown list in iOS in Swift.

import UIKit

@objc protocol EdropdownListDelegate {
    func didSelectItem(selectedItem: String, index: Int,selectedList:Int)
}

class EDropdownList: UIView {
    var dropdownButton: UIButton!
    var listTable: UITableView!
    var arrowImage: UIImageView!
    var valueList: [String]!
    var delegate: EdropdownListDelegate!
    var isShown: Bool! = false
    var selectedValue: String!
    
    var maxHeight: CGFloat = 200.0
    var cellSelectedColor = UIColor(red: 209.0 / 255.0, green: 209.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
    var textColor = UIColor.black
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
        setupArrowImage()
        setupListTable()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupButton()
        setupArrowImage()
        setupListTable()
    }
    
    // MARK: - Create interface.
    
    func setupButton() {
        dropdownButton = UIButton(type: UIButtonType.custom)
     //   dropdownButton.backgroundColor = UIColor(red: 102.0 / 255.0, green: 102.0 / 255.0, blue: 255.0 / 255.0, alpha: 1)
        dropdownButton.backgroundColor = UIColor.white
       
        dropdownButton.titleLabel!.font = UIFont(name: "System Bold", size: 10)
        dropdownButton.setTitleColor(UIColor.black, for: UIControlState.normal)
        dropdownButton.frame = CGRect(x: 0, y: 0, width:self.frame.width, height:  self.frame.height)
           // CGRectMake(0, 0, self.frame.width, self.frame.height)
        dropdownButton.setTitle("Price Heigh to Low", for: UIControlState.normal)
        dropdownButton.addTarget(self, action: #selector(EDropdownList.showHideDropdownList(sender:)), for: UIControlEvents.touchUpInside)
        //Selector(("showHideDropdownList:")
        self.addSubview(self.dropdownButton)
    }
    
    func setupArrowImage() {
        
        arrowImage = UIImageView(image: UIImage(named: "downArrow"))
        arrowImage.frame = CGRect(x: self.frame.width - self.frame.height / 2, y: self.frame.height / 4, width:self.frame.height / 2, height:  self.frame.height / 2)
            //CGRectMake(self.frame.width - 3 * self.frame.height / 4, self.frame.height / 4, self.frame.height / 2, self.frame.height / 2)
        
        // Add the arrow image at the end of the button.
        self.addSubview(arrowImage)
    }
    
    func setupListTable() {
        let yLocation = self.frame.minY + dropdownButton.frame.height
        listTable = UITableView(frame: CGRect(x:self.frame.minX, y: yLocation, width:self.frame.width, height:0))
        //CGRectMake(self.frame.minX, yLocation, self.frame.width, 0)
        listTable.dataSource = self
        listTable.delegate = self
        listTable.isUserInteractionEnabled = true
        
        // Disable scrolling the tableview after it reach the top or bottom.
        listTable.bounces = false
    }
    
    // MARK: - User setting
    
    func dropdownColor(backgroundColor: UIColor, selectedColor: UIColor, textColor: UIColor) {
        listTable.backgroundColor = backgroundColor
        cellSelectedColor = selectedColor
        self.textColor = textColor
    }
    
    func dropdownColor(backgroundColor: UIColor, buttonColor: UIColor, selectedColor: UIColor, textColor: UIColor) {
        dropdownColor(backgroundColor: backgroundColor, selectedColor: selectedColor, textColor: textColor)
        dropdownButton.backgroundColor = buttonColor
    }
    
    func dropdownMaxHeight(height: CGFloat) {
        maxHeight = height
    }
    
    // MARK: - Action
    
    func showHideDropdownList(sender: UIButton) {
        if selectedValue != nil {
            dropdownButton.setTitle(selectedValue, for: UIControlState.normal)
        }
        
        if !isShown {
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.superview?.addSubview(self.listTable)
                
                var height = self.tableviewHeight()
                
                if height > self.maxHeight {
                    height = self.maxHeight
                }
                
                var frame = self.listTable.frame
                frame.size.height = CGFloat(height)
                
                self.listTable.frame = frame
                }, completion: { (animated) -> Void in
                    self.arrowImage.image = UIImage(named: "dropdown.png")
            })
        }
        else {
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                    let height = 0
                    var frame = self.listTable.frame
                    frame.size.height = CGFloat(height)
                
                    self.listTable.frame = frame
                }, completion: { (animated) -> Void in
                    self.listTable.removeFromSuperview()
                    self.arrowImage.image = UIImage(named: "dropdown.png")
            })
        }
        
        isShown = !isShown
    }
}

// MARK: - UITableViewDataSource
extension EDropdownList: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = valueList?.count
        
        if count! > 0 {
            return count!
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: cellIdentifier)
        }
        
        // Set selected background color.
        let colorView = UIView()
        colorView.backgroundColor = cellSelectedColor
        cell.selectedBackgroundView = colorView
        cell.textLabel?.font = UIFont(name: "System Bold", size: 14)
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.textColor = textColor
        cell.textLabel?.text = valueList?[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.responds(to: #selector(setter: UITableView.separatorInset))
        {
            tableView.separatorInset = UIEdgeInsets.zero
        }
        
        if  tableView.responds(to: #selector(setter: UITableView.layoutMargins))
        {
            tableView.layoutMargins = UIEdgeInsets.zero
        }
        
        if cell.responds(to: #selector(setter: UITableViewCell.layoutMargins)) {
            cell.layoutMargins = UIEdgeInsets.zero
        }
    }
    
    func tableviewHeight() -> CGFloat {
        listTable.layoutIfNeeded()
        return listTable.contentSize.height
    }
}

// MARK: - UITableViewDelegate
extension EDropdownList: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
  
        // Get selected value.
        let selectedCell = tableView.cellForRow(at: indexPath as IndexPath)
        selectedValue = selectedCell?.textLabel?.text
        
        // Hide the dropdown table and pass the selected value.
        showHideDropdownList(sender: dropdownButton)
        delegate?.didSelectItem(selectedItem: (selectedCell?.textLabel?.text)!, index: indexPath.row,selectedList:self.tag)
    }
}

