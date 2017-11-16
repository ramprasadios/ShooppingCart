//
//  DropDownMenuView.swift
//  nHance
//
//  Created by Ramprasad A on 30/01/17.
//  Copyright © 2017 Pradeep BM. All rights reserved.
//

import Foundation
import UIKit

protocol DropDownMenuViewDelegate : NSObjectProtocol {
    func menuDropDownSelected(index: Int, withSectionId id: String?)
}

@IBDesignable class DropDownMenuView: UIView {
   
    //MARK:- Properties
    var contentTextField: UITextField!
    var isShown: Bool = false
    var setBottomBorder = true
    var sectionArray: [String] = []
    var tap: UITapGestureRecognizer?
    var parentViewTap: UITapGestureRecognizer?

    
    weak var delegate: DropDownMenuViewDelegate?
    
    var optionsArray: [String] = [] {
        didSet {
            self.contentTextField.text = self.optionsArray.first
            reload()
        }
    }
    
    /*
    var menuDictionary: [[String: AnyObject]]? {
        didSet {
            getArray(formDict: menuDictionary!)
            getSectionId(formDict: menuDictionary!)
            
            reload()
        }
    } */
    
    public var fontSize: UIFont? {
        didSet {
            contentTextField.font = fontSize
        }
    }
    
    var defaultYPosition: CGFloat = 0.0
    public var yPosition: CGFloat? = 0.0 {
        didSet {
            defaultYPosition = self.yPosition!
            reload()
        }
    }
    
    public var menuWidth: CGFloat? = 0.0 {
        didSet {
            reload()
        }
    }

    fileprivate lazy var menuTableView: UITableView = {
        let table = UITableView(frame: CGRect(x: self.frame.origin.x, y: self.frame.origin.y + self.frame.size.height, width: UIScreen.main.bounds.size.width, height: 0), style: .plain)
        table.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        table.dataSource = self
        table.delegate = self
        table.layer.borderColor = UIColor.lightGray.cgColor
        table.layer.borderWidth = 0.5
        table.isScrollEnabled = true
//        self.superview?.addSubview(table)
        AppDelegate.currentController()?.view.addSubview(table)
        AppDelegate.currentController()?.view.bringSubview(toFront: table)
        return table
    }()
    
    fileprivate var actualRowHeigh: CGFloat = 0
    var newRowHeight: CGFloat {
        get{
            if actualRowHeigh == 0 {
                return self.frame.size.height
            }
            return self.newRowHeight
        } set {
            self.newRowHeight = newValue
            reload()
        }
    }
    
    fileprivate var maxMenuHeigh: CGFloat = 0
    var menuHeight: CGFloat {
        get {
            if maxMenuHeigh == 0 {
                return CGFloat(self.optionsArray.count) * self.actualRowHeigh
            }
            return min(maxMenuHeigh, CGFloat(self.optionsArray.count) * self.newRowHeight)
        } set {
            maxMenuHeigh = newValue
            reload()
        }
    }
    
    @IBInspectable var containerView: UIViewController? {
        willSet {
            if self.menuTableView.superview != nil {
                self.menuTableView.removeFromSuperview()
            }
        }
        didSet {
            if self.menuTableView.superview == nil {
                self.containerView?.view.addSubview(self.menuTableView)
            }
        }
    }
    
    @IBInspectable var tableBackgroundColor: UIColor? {
        didSet {
            reload()
        }
    }
    
    @IBInspectable var cellFontColor: UIColor? {
        didSet {
            reload()
        }
    }
    
    @IBInspectable public var editable:Bool = false {
        didSet {
            contentTextField.isEnabled = editable
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialSetup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(self, selector: #selector(DropDownMenuView.removeDropDown), name: Notification.Name("RemoveDropDownNotification"), object: nil)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.contentTextField.frame = CGRect(x: 8.0, y: 0.0, width: self.frame.size.width - 8.0, height: self.frame.size.height)
//        if setBottomBorder {
//            self.contentTextField.setBottomBorder(color: "#000000")
//        }
    }
}

extension DropDownMenuView {
    
    func initialSetup() {
        self.contentTextField = UITextField(frame: CGRect.zero)
        self.contentTextField.delegate = self
        self.contentTextField.isEnabled = false
        self.contentTextField.font = fontSize
        self.contentTextField.text = "Loading..."
        self.addSubview(contentTextField)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(DropDownMenuView.hideOrShowMenu))
        tap?.numberOfTapsRequired = 1
        parentViewTap = UITapGestureRecognizer(target: self, action: #selector(DropDownMenuView.hideOrShowMenu))
        self.addGestureRecognizer(tap!)
        setupViewLayout()
        registerNotificationObservers()
    }
    
    func hideOrShowMenu() {
        if self.isShown {
            self.menuTableView.isHidden = false
            self.menuTableView.frame = CGRect(x: self.frame.origin.x, y: defaultYPosition + self.frame.size.height - 0.5, width: UIScreen.main.bounds.size.width, height: 0)
            //AppDelegate.currentController()?.view.removeGestureRecognizer(self.parentViewTap!)
            self.isShown = false
            
        } else {
            self.menuTableView.isHidden = false
            self.contentTextField.resignFirstResponder()
            menuTableView.reloadData()
//            let properConvertRect = self.convert(self.frame, to: AppDelegate.currentController()?.view)
            let properConvertRect = self.convert(self.parentView().frame, to: AppDelegate.currentController()?.view)
            let menuWidth = self.menuWidth == CGFloat(0.0) ? UIScreen.main.bounds.size.width - 16.0 : self.frame.width
            let yPosition = self.yPosition == CGFloat(0.0) ? properConvertRect.origin.y: CGFloat(self.frame.origin.y)
            self.menuTableView.frame = CGRect(x: self.frame.origin.x, y: yPosition + self.frame.size.height - 0.5, width: menuWidth, height: self.menuHeight)
            //AppDelegate.currentController()?.view.addGestureRecognizer(self.parentViewTap!)
            self.isShown = true
        }
    }
    
    func reload() {
        if !self.isShown {
            return
        }
        menuTableView.reloadData()
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.menuTableView.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y + self.frame.size.height-0.5, width: self.frame.size.width, height: self.menuHeight)
        })
    }
    
    /* func getArray(formDict menuDict: [[String: AnyObject]]) {
        var array: [String] = []
        for menuInfo in menuDict {
            array.append(menuInfo[NetKey.keyCategoryName] as? String ?? "")
        }
        self.optionsArray = array
        
        if self.contentTextField.text!.isEmpty {
            if let text = optionsArray.first {
                self.contentTextField.text = text
            }
        }
    }
    
    func getSectionId(formDict menuDict: [[String: AnyObject]]) {
        var array: [String] = []
        for menuInfo in menuDict {
            array.append(menuInfo[NetKey.keyCategoryId] as? String ?? "")
        }
        self.sectionArray = array
    } */
    
    func setupViewLayout() {
        let dropDownImageView = UIImageView(image: UIImage(named: "customDropDown"))
        dropDownImageView.frame = CGRect(x: 0.0, y: 0.0, width: 15, height: 15)
        dropDownImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let trailingConstraint = NSLayoutConstraint(item: dropDownImageView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: dropDownImageView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        let widhtConstraint = NSLayoutConstraint(item: dropDownImageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 15)
        let heightConstraint = NSLayoutConstraint(item: dropDownImageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 15)
        dropDownImageView.contentMode = .scaleAspectFit
        
        self.addSubview(dropDownImageView)
        NSLayoutConstraint.activate([trailingConstraint, bottomConstraint, widhtConstraint, heightConstraint])
    }
    
    func removeDropDown() {
        self.menuTableView.isHidden = true
    }
    
    func updateContentText(notification: Notification) {
        
//        let userInfo = notification.object as? [String: AnyObject]
//        if let selectedProgram = userInfo?[DictionaryKeys.programName] as? String {
//            self.contentTextField.text = selectedProgram
//        }
    }
    
    func registerNotificationObservers() {
//        NotificationCenter.default.addObserver(self, selector: #selector(DropDownMenuView.updateContentText), name: Notification.Name(NotificationNames.seletedSectionProgramInfoNotification), object: nil)
    }
}

extension DropDownMenuView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return optionsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "MenuCell")
        cell.contentView.backgroundColor = self.tableBackgroundColor
        cell.textLabel?.text = optionsArray[indexPath.row]
        cell.textLabel?.textColor = self.cellFontColor
		if UIDevice.current.userInterfaceIdiom == .pad {
			cell.textLabel?.font = UIFont.systemFont(ofSize: 18)
		} else {
			cell.textLabel?.font = UIFont.systemFont(ofSize: 12)
		}
		
        cell.selectionStyle = .none
        return cell
    }
}

extension DropDownMenuView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.contentTextField.text = optionsArray[indexPath.row]
        delegate?.menuDropDownSelected(index: indexPath.row, withSectionId: "")

        hideOrShowMenu()
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.newRowHeight
    }
}

extension DropDownMenuView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
