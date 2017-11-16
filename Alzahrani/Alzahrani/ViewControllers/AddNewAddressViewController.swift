//
//  AddNewAddressViewController.swift
//  Alzahrani
//
//  Created by Hardwin on 13/06/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

protocol AddressDataDelegate: NSObjectProtocol {
    func didFinishPickingAddress()
}

typealias TextUpdater = ((_ success: Bool, _ text: String) -> Void)

struct CountryData {
    
    let name: String?
    let id: String?
    let code: String?
    
    init(withName name: String, _ id: String, _ code: String) {
        self.name = name
        self.id = id
        self.code = code
    }
}

struct StateRegionData {
    let name: String?
    let zoneId: String?
    
    init(withName name: String, andZoneId id: String) {
        self.name = name
        self.zoneId = id
    }
}

struct CityData {
    
    let name: String?
    let zoneId: String?
    
    init(withName name: String, andZoneId id: String) {
        self.name = name
        self.zoneId = id
    }
}

struct UserData {
    let firstName: String?
    let lastName: String?
    let address1: String?
    let address2: String?
    let postCode: String?
    let country: String?
    let city: String?
    
    init(_ firstName: String, _ lastName: String, _ address1: String, _ address2: String, _ postCode: String, _ country: String, _ city: String ) {
        self.firstName = firstName
        self.lastName = lastName
        self.address1 = address1
        self.address2 = address2
        self.postCode = postCode
        self.country = country
        self.city = city
    }
}

enum RegionType {
    case city
    case country
    case state
}

struct FieldDataSource {
    let fieldName: String?
    let index: Int?
}


class AddNewAddressViewController: UIViewController {
    
    @IBOutlet weak var addressTableView: UITableView!
    
    @IBOutlet weak var addNewAddressLabel: UILabel!
    let palceholderTexts = ["* First Name", "* Last Name", "Company", "* Address 1", "Address 2", "* Country", "* Region / State", "* City", "Postal Code"]
    let palceholderTextsEmployee = ["* First Name", "* Last Name", "Company", "* Address 1", "Address 2", "* Country", "* Region / State", "* City", "Postal Code"]
    var placeHolderArray = [FieldDataSource]()
    var countiesList = [CountryData]()
    var stateRegionNameList = [StateRegionData]()
    var citiesList = [CityData]()
    
    var _selectedCountry: String?
    var selectedCountry: String? {
        get {
            return _selectedCountry ?? ""
        } set {
            self._selectedCountry = newValue
            
        }
    }
    var textStringUpdate: TextUpdater?
    var cityTextUpdate: TextUpdater?
    var regionType: RegionType = .country
    var cellData = [String]()
    var selectedCityZoneId: String?
    var billingAddressType: UserAddressType = .existingAddress
    var deleveryAddressType: UserAddressType = .existingAddress
    var userAddressInfoType: AddressType? = .delevery
    
    weak var delegate: AddressDataDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetup()
        self.addNewAddressLabel.text = NSLocalizedString("Add your new address", comment: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UploadTaskHandler.sharedInstance.newAddressInfo = []
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        self.cellData = []
        self.getTextFiledValue()
        
        print("Cell Data \(cellData)")
        
        if validateUserData() {
            self.storeUserData()
            self.postUserData()
        }
    }
}

//MARK:- Helper Methods:
extension AddNewAddressViewController {
    
    func initialSetup() {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(AddNewAddressViewController.dismissViewController))
        self.view.addGestureRecognizer(tap)
        self.setPlaceHolderDataSource()
    }
    
    func setPlaceHolderDataSource() {
        
        for (index, placeholderText) in self.palceholderTexts.enumerated() {
            let fieldDataSource = FieldDataSource(fieldName: placeholderText, index: index)
            self.placeHolderArray.append(fieldDataSource)
        }
    }

    
    func dismissViewController() {
        dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "ShowTabBarNotify"), object: nil)
        })
    }
    
    func getCountriesList(withCompletion completion: @escaping DownloadCompletion) {
        
        SyncManager.syncOperation(operationType: .getCountiesList, info: "") { (response, error) in
            if error == nil {
                print("Countries: \(response)")
                if let countryResponse = response as? [[String: AnyObject]] {
                    for countries in countryResponse {
                        if let name = countries["name"] as? String, let id = countries["country_id"] as? String, let code = countries["iso_code_2"] as? String {
                            let countryInfo = CountryData(withName: name, id, code)
                            self.countiesList.append(countryInfo)
                        }
                    }
                }
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func getStateOrRegionList(withCompletion completion: @escaping DownloadCompletion) {
        if let selectedCountryID = self.selectedCountry {
            SyncManager.syncOperation(operationType: .getCitiesList, info: selectedCountryID, completionHandler: { (response, error) in
                if error == nil {
                    print("State/Region Response: \(response)")
                    if let cityInfo = response as? [String: AnyObject] {
                        if let cityList = cityInfo["zone"] as? [[String: AnyObject]] {
                            for city in cityList {
                                if let cityName = city["name"] as? String, let zoneId = city["zone_id"] as? String {
                                    let cityData = StateRegionData(withName: cityName, andZoneId: zoneId)
                                    self.stateRegionNameList.append(cityData)
                                }
                            }
                        }
                    }
                    completion(true)
                } else {
                    completion(false)
                }
            })
        }
    }
    
    func getCitiesList(withCompletion completion: @escaping DownloadCompletion) {
        if let selectedCityZoneId = self.selectedCityZoneId {
            SyncManager.syncOperation(operationType: .getCitiesBasedOnZoneId, info: selectedCityZoneId, completionHandler: { (response, error) in
                if error == nil {
                    print("City Response: \(response)")
                    if let cityInfo = response as? [[String: AnyObject]] {
                        for city in cityInfo {
                            if let cityName = city["name"] as? String, let zoneId = city["zone_id"] as? String {
                                let cityData = CityData(withName: cityName, andZoneId: zoneId)
                                self.citiesList.append(cityData)
                            }
                        }
                    }
                    completion(true)
                } else {
                    completion(false)
                }
            })
        }
    }
    
    func showStateOrRegionList(atTextField textField: UITextField) {
        
        self.getStateOrRegionList { (success) in
            
            let dropDownMenuVc = self.storyboard?.instantiateViewController(withIdentifier: MenuPopTableViewController.selfName()) as? MenuPopTableViewController
            dropDownMenuVc?.delegate = self
            dropDownMenuVc?.contentSize = CGSize(width: CGFloat(textField.frame.size.width),height: CGFloat(44 * self.numberOfMenu()))
            dropDownMenuVc?.popoverPresentationController?.permittedArrowDirections = .any
            dropDownMenuVc?.popoverPresentationController?.sourceView = textField as UIView
            dropDownMenuVc?.popoverPresentationController?.sourceRect = textField.bounds
            dropDownMenuVc?.popoverPresentationController?.delegate = dropDownMenuVc
            dropDownMenuVc?.sourceRect = textField.bounds
            
            self.present(dropDownMenuVc!, animated: true, completion: nil)
        }
    }
    
    func showCountriesList(atTextField textField: UITextField) {
        self.getCountriesList { (success) in
            if success {
                let dropDownMenuVc = self.storyboard?.instantiateViewController(withIdentifier: MenuPopTableViewController.selfName()) as? MenuPopTableViewController
                dropDownMenuVc?.delegate = self
                dropDownMenuVc?.contentSize = CGSize(width: CGFloat(textField.frame.size.width),height: CGFloat(44 * self.numberOfMenu()))
                dropDownMenuVc?.popoverPresentationController?.permittedArrowDirections = .any
                dropDownMenuVc?.popoverPresentationController?.sourceView = textField as UIView
                dropDownMenuVc?.popoverPresentationController?.sourceRect = textField.bounds
                dropDownMenuVc?.popoverPresentationController?.delegate = dropDownMenuVc
                dropDownMenuVc?.sourceRect = textField.bounds
                
                self.present(dropDownMenuVc!, animated: true, completion: nil)
            }
        }
    }
    
    func showCitiesList(atTextField textField: UITextField) {
        self.getCitiesList { (success) in
            if success {
                let dropDownMenuVc = self.storyboard?.instantiateViewController(withIdentifier: MenuPopTableViewController.selfName()) as? MenuPopTableViewController
                dropDownMenuVc?.delegate = self
                dropDownMenuVc?.contentSize = CGSize(width: CGFloat(textField.frame.size.width),height: CGFloat(44 * self.numberOfMenu()))
                dropDownMenuVc?.popoverPresentationController?.permittedArrowDirections = .any
                dropDownMenuVc?.popoverPresentationController?.sourceView = textField as UIView
                dropDownMenuVc?.popoverPresentationController?.sourceRect = textField.bounds
                dropDownMenuVc?.popoverPresentationController?.delegate = dropDownMenuVc
                dropDownMenuVc?.sourceRect = textField.bounds
                
                self.present(dropDownMenuVc!, animated: true, completion: nil)
            }
        }
    }
    
    func getCellData(asString text: String) {
        self.cellData.append(text)
    }
    
    func getTextFiledValue() {
        for (index, placeHolderString) in self.palceholderTexts.enumerated() {
            let indexPath = IndexPath(row: index, section: 0)
            guard let cell = self.addressTableView.cellForRow(at: indexPath) else {
                return
            }
            
            if let text = (cell as? AddNewAddressTableViewCell)?.newAddressTextField.text {
                if !text.isEmpty || (placeHolderString == "Company") {
                    self.cellData.append(text)
                } else {
                    self.cellData.append("")
                }
            } else {
                self.cellData.append("")
            }
        }
    }
    
    func storeUserData() {
        let userId = UserDefaultManager.sharedManager().loginUserId
        let custGrpId = UserDefaultManager.sharedManager().customerGroupId
        if self.userAddressInfoType == .delevery {
            UserShipppingAddress.sharedInstance.deleveryNewAddressData = []
            let userAddressData = UserAddressData(customerId: userId ?? "", custGrpId ?? "", cellData[0], cellData[1], "", "", cellData[3], cellData[4], cellData[7], cellData[8], cellData[5], selectedCityZoneId!, cellData[7], selectedCityZoneId!, "")
            UserShipppingAddress.sharedInstance.deleveryNewAddressData.append(userAddressData)
        } else {
            UserShipppingAddress.sharedInstance.billingNewAddressData = []
            let userAddressData = UserAddressData(customerId: userId ?? "", custGrpId ?? "", cellData[0], cellData[1], "", "", cellData[3], cellData[4], cellData[7], cellData[8], cellData[5], selectedCityZoneId!, cellData[7], selectedCityZoneId!, "")
            UserShipppingAddress.sharedInstance.billingNewAddressData.append(userAddressData)
        }
    }
    
    func validateUserData() -> Bool {
        var retVal: Bool? = false
        for (index, data) in cellData.enumerated() {
            if index != 2 {
                if !data.isEmpty && data.characters.count >= 3 {
                    retVal = true
                    continue
                } else {
                    return false
                }
            }
        }
        return retVal!
    }
    
    func postUserData() {
        if let loggedInUserId = UserDefaultManager.sharedManager().loginUserId {
            if let zoneId = selectedCityZoneId, let countryId = self.selectedCountry {
                let syncFormat = "firstname=\(cellData[0])&lastname=\(cellData[1])&company=\(cellData[2])&address_1=\(cellData[3])&address_2=\(cellData[4])&city=\(cellData[7])&postcode=\(cellData[8])&country_id=\(countryId)&zone_id=\(zoneId)&customer_id=\(loggedInUserId)"
                
                SyncManager.syncOperation(operationType: .addNewAddress, info: syncFormat, completionHandler: { (response, error) in
                    if error == nil {
                        self.delegate?.didFinishPickingAddress()
                        self.dismiss(animated: true, completion: nil)
                        print("New Address is Added")
                    }
                })
            }
        }
    }
}

extension AddNewAddressViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let custormerGroupId = UserDefaultManager.sharedManager().customerGroupId {
            if custormerGroupId == "1" {
                return self.placeHolderArray.count
            } else {
                return self.placeHolderArray.count
            }
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
       
        //let custormerGroupId = UserDefaultManager.sharedManager().customerGroupId
        if self.placeHolderArray[indexPath.row].fieldName == NSLocalizedString("* Country", comment: "") {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CountryTableViewCell", for: indexPath) as! AddNewAddressTableViewCell
            let localizedString = NSLocalizedString(self.placeHolderArray[indexPath.row].fieldName!, comment: "")
            cell.newAddressTextField.placeholder = localizedString
            return cell
        } else if self.placeHolderArray[indexPath.row].fieldName == NSLocalizedString(self.placeHolderArray[indexPath.row].fieldName!, comment: "") {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CityTableViewCell", for: indexPath) as! AddNewAddressTableViewCell
            let localizedString = NSLocalizedString(self.placeHolderArray[indexPath.row].fieldName!, comment: "")
            cell.newAddressTextField.placeholder = localizedString
            return cell
        } else if self.placeHolderArray[indexPath.row].fieldName == NSLocalizedString(self.placeHolderArray[indexPath.row].fieldName!, comment: "") {
            let cell = tableView.dequeueReusableCell(withIdentifier: "StateTableViewCell", for: indexPath) as! AddNewAddressTableViewCell
            let localizedString = NSLocalizedString(self.placeHolderArray[indexPath.row].fieldName!, comment: "")
            cell.newAddressTextField.placeholder = localizedString
            return cell
        } else if self.placeHolderArray[indexPath.row].fieldName == NSLocalizedString(self.placeHolderArray[indexPath.row].fieldName!, comment: "") {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PasswordTableViewCell", for: indexPath) as! AddNewAddressTableViewCell
            let localizedString = NSLocalizedString(self.placeHolderArray[indexPath.row].fieldName!, comment: "")
            cell.newAddressTextField.placeholder = localizedString
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: AddNewAddressTableViewCell.selfName(), for: indexPath) as! AddNewAddressTableViewCell
            let localizedString = NSLocalizedString(self.placeHolderArray[indexPath.row].fieldName!, comment: "")
            cell.newAddressTextField.placeholder = localizedString
            return cell
        }
        
        
        /* if custormerGroupId == "1" {
            if self.placeHolderArray[indexPath.row].index == indexPath.row  {
                cell.newAddressTextField.placeholder = self.placeHolderArray[indexPath.row].fieldName
                if ((self.palceholderTexts[indexPath.row] == "* Country") || (self.palceholderTexts[indexPath.row] == "* City") || (self.palceholderTexts[indexPath.row] == "* Region / State")) {
                    cell.accessoryType = .disclosureIndicator
                }
            }
        } else {
            if self.placeHolderArray[indexPath.row].index == indexPath.row {
                cell.newAddressTextField.placeholder = self.placeHolderArray[indexPath.row].fieldName
                if ((self.palceholderTexts[indexPath.row] == "* Country") || (self.palceholderTexts[indexPath.row] == "* City") || (self.palceholderTexts[indexPath.row] == "* Region / State")) {
                    cell.accessoryType = .disclosureIndicator
                }
            }
        }
        return cell */
    }
}

extension AddNewAddressViewController: UITableViewDelegate {
    
    
}

extension AddNewAddressViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if ((textField.placeholder == NSLocalizedString("* City", comment: "")) || (textField.placeholder == NSLocalizedString("* Country", comment: "")) || (textField.placeholder == NSLocalizedString("* Region / State", comment: ""))){
            print("Region / State Text Field Tapped")
            if textField.placeholder == NSLocalizedString("* Country", comment: "") {
                self.regionType = .country
                self.countiesList = []
                self.showCountriesList(atTextField: textField)
                self.textStringUpdate = { (success, text) in
                    if success {
                        textField.text = text
                    }
                }//
            } else if textField.placeholder == NSLocalizedString("* Region / State", comment: "") {
                self.regionType = .city
                if self.selectedCountry != "" {
                    self.showStateOrRegionList(atTextField: textField)
                    self.cityTextUpdate = { (success, text) in
                        if success {
                            textField.text = text
                        }
                    }
                }
            } else if textField.placeholder == NSLocalizedString("* City", comment: "") {
                self.regionType = .state
                self.showCitiesList(atTextField: textField)
                self.cityTextUpdate = { (success, text) in
                    if success {
                        textField.text = text
                    }
                }
            }
            textField.resignFirstResponder()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//MARK:- MenuPopViewControllerDelegate
extension AddNewAddressViewController: MenuPopViewControllerDelegate {
    
    func numberOfMenu() -> Int {
        switch self.regionType {
        case .country:
            return self.countiesList.count
        case .city:
            return self.stateRegionNameList.count
        case .state:
            return self.citiesList.count
        }
    }
    
    func menuNameAtIndexPath(indexPath: IndexPath) -> String {
        
        switch self.regionType {
        case .country:
            return self.countiesList[indexPath.row].name!
        case .city:
            return self.stateRegionNameList[indexPath.row].name!
        case .state:
            return self.citiesList[indexPath.row].name!
        }
    }
    
    func didSelectMenuAtIndexPath(indexPath: IndexPath, menuController: MenuPopTableViewController) {
        
        switch self.regionType {
        case .country:
            self.selectedCountry = self.countiesList[indexPath.row].id!
            if self.countiesList[indexPath.row].name != nil {
                self.textStringUpdate!(true, self.countiesList[indexPath.row].name!)
            }
        case .city:
            self.selectedCityZoneId = self.stateRegionNameList[indexPath.row].zoneId
            self.cityTextUpdate!(true, self.stateRegionNameList[indexPath.row].name!)
        case .state:
            self.cityTextUpdate!(true, self.citiesList[indexPath.row].name!)
        }
    }
}
