//
//  EnumConstants.swift
//  Alzahrani
//
//  Created by Hardwin on 11/05/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation
import UIKit

struct LocalizedString: ExpressibleByStringLiteral, Equatable {
    
    let v: String
    
    init(key: String) {
        self.v = NSLocalizedString(key, comment: "")
    }
    init(localized: String) {
        self.v = localized
    }
    init(stringLiteral value:String) {
        self.init(key: value)
    }
    init(extendedGraphemeClusterLiteral value: String) {
        self.init(key: value)
    }
    init(unicodeScalarLiteral value: String) {
        self.init(key: value)
    }
}

func ==(lhs:LocalizedString, rhs:LocalizedString) -> Bool {
    return lhs.v == rhs.v
}

enum MenuTapHandler: String {
    case home = "HomeViewControler"
    case subCategories = "SubCategoriesViewController"
    case login = "LoginViewController"
}

enum SalesRepMenu: String {
    case LogoutUser = "Logout"
    case MyAccount = "My Account"
    case MyWishList = "My Wishlist"
    case OrderHistory = "Order History"
    case CustomerService = "Customer Service"
    case Settings = "Settings"
    case ShareApp = "Share App"
    case RateUs = "Rate us"
}

extension SalesRepMenu {
    
    static let enumValues = [MyAccount, MyWishList, OrderHistory, CustomerService, Settings, ShareApp, RateUs, LogoutUser]
    
    static func countEnums() -> Int {
        return enumValues.count
    }
    
    func getImage() -> String {
        switch self {
        case .MyAccount:
            return "my_account_logo"
        case .MyWishList:
            return "my_wishList_logo"
        case .OrderHistory:
            return "order_history_logo"
        case .CustomerService:
            return "customer_service_logo"
        case .Settings:
            return "settings_logo"
        case .ShareApp:
            return "share_app_logo"
        case .RateUs:
            return "rate_us_logo"
        case .LogoutUser:
            return "logout_logo"
        }
    }
}

enum LoggedInUser: String {
    case LogoutUser = "Logout"
    case MyAccount = "My Account"
    case MyWishList = "My Wishlist"
    case OrderHistory = "Order History"
    //case Settings = "Settings"
    case CustomerService = "Customer Service"
    case ShareApp = "Share App"
    case RateUs = "Rate us"
}

extension LoggedInUser {
    
    static let enumValues = [MyAccount, MyWishList, OrderHistory, /*Settings, */ CustomerService, ShareApp, RateUs, LogoutUser]
    
    static func countEnums() -> Int {
        return enumValues.count
    }
    
    func getImage() -> String{
        switch self {
        case .MyAccount:
            return "my_account_logo"
        case .MyWishList:
            return "my_wishList_logo"
        case .OrderHistory:
            return "order_history_logo"
        /*case .Settings:
            return "settings_logo" */
        case .CustomerService:
            return "customer_service_logo"
        case .ShareApp:
            return "share_app_logo"
        case .RateUs:
            return "rate_us_logo"
        case .LogoutUser:
            return "logout_logo"
        }
    }
}

enum NewUser : String {
    case Register = "Register"
    case Login = "Login"
    case MyAccount = "My Account"
    case MyWishList = "My WishList"
    case OrderHistory = "Order History"
    //case Settings = "Settings"
    case CustomerService = "Customer Service"
    case ShareApp = "Share App"
    case RateUs = "Rate us"
}

extension NewUser {
    
    static let enumValues = [Register, Login, /* MyAccount, MyWishList, OrderHistory, */ CustomerService, /*Settings, */ ShareApp, RateUs]
    
    static func countEnums() -> Int {
        return enumValues.count
    }
    
    func getImage() -> String{
        switch self {
        case .MyAccount:
            return "my_account_logo"
        case .MyWishList:
            return "my_wishList_logo"
        case .OrderHistory:
            return "order_history_logo"
        case .CustomerService:
            return "customer_service_logo"
        /* case .Settings:
            return "settings_logo" */
        case .ShareApp:
            return "share_app_logo"
        case .RateUs:
            return "rate_us_logo"
        case .Register:
            return "Register_logo"
        case .Login:
            return "login_logo"
        }
    }
}

enum BrandImage: String {
    case Leifheit = "Leifheit"
    case LockLock = "Lock &amp; lock "
    case Grandeur = "Grandeur"
    case Fest     = "Fest"
    case TVS      = "TVS"
    case Tescoma  = "Tescoma"
    case Misfer   = "Misfer"
    case Omada    = "Omada"
    case Zahrani  = "Zahrani"
    case Sarayli  = "Sarayli"
    case Fissler  = "Fissler"
    case Meiwa    = "Meiwa"
    case Tiger    = "Tiger"
    case Ocarina  = "Ocarina"
    case Barmioli = "Bormioli"
    case Soehnle  = "Soehnle"
    case Dosel    = "Dosel"
    case OtherItems = "Other"
}

enum ProductFilterTypes: String {
    case LowToHigh = "Low price to high price"
    case HighToLow = "HIGH_TO_LOW"
    case None = ""
    case InStock = "In Stock"
    case OutOfStock = "Out of stock"
    case filterBrands = "filterBrands"
}

extension ProductFilterTypes {
    
    static let caseValues = [LowToHigh, HighToLow]
    
    static func count() -> Int {
        return self.caseValues.count
    }
}

enum CheckOutSteps: String {
    case first =    "Step 1: Checkout Options"
    case second =   "Step 2: Billing Details"
    case third =    "Step 3: Delivery Details"
    case fourth =   "Step 4: Delivery Method"
    case fifth =    "Step 5: Payment Method"
    case sixth =    "Step 6: Confirm Order"
}

extension CheckOutSteps {
    
    static let caseValues = [first, second, third, fourth, fifth, sixth]
    
    static func count() -> Int {
        return self.caseValues.count
    }
}

enum PaymentMethodTypes: String {
    case temp   =  ""
    case bank   =  "Bank Transfer"
    case cod    =  "Cash On Delivery"
    case online =  "Credit / Debit Card"
    //case sadad  =  "SADAD"
    case salary =  "Salary Deduction"
}

enum PaymentCode: String {
    case onlinePayment = "payfort_fort"
    case cashOnDelevery = "cod"
    case salaryDeduction = "codd"
    case bankTransfer = "bank_transfer"
}

extension PaymentMethodTypes {
    
    static let caseValues = [temp, bank, cod, online, salary]
    
    static func count() -> Int {
        return self.caseValues.count
    }
}

enum ShippingOptions: String {
    case free_shipping = "free_shipping"
    case cash_on_delevery = "cash_on_delivery"
}

enum ShippingType: String {
    case aramex_shipping = "Aramex Shipping"
    case free_shipping = "Free Shipping"
}

enum ShippingCode: String {
    case aramex = "wk_aramex.wk_aramex"
    case free = "free.free"
}

enum TotalsKeys: String {
    case sub_total = "Sub-Total"
    case cod = "Cash on delivery fee"
    case freeShipping = "Free Shipping"
    case aramex = "Aramex Shipping"
    case total = "Total"
}

enum FromScreenType {
    case banner, offers, category, brands, home, search
}

enum PaymentEnglishKeys: String {
    case titleviewLbl = "CREDIT CARD"
    case CardNumberPl = "CARD NUMBER"
    case CardNamePl = "CARDHOLDER NAME"
    case ExpDateLbl = "EXPIRY DATE"
    case CVCtxt = "CVV"
    case PayBtn = "PAY"
    case Init_conn = "Init a secure Connection..."
    case YourReceiptLbl = "Reciept"
    case monthyearLbl = "Month"
    case saveCarLbl = "Save"
    case alertTitle = "Alert"
    case titleMessage = "Cancel this patyment?"
    case yesBtn = "YES"
    case noBtn = "NO"
    case pf_cancel_required_field = "Required field,cannot be left empty"
}

enum PaymentArabicKeys: String {
    case titleviewLbl = "تفاصيل بطاقة الائتمان"
    case CardNumberPl = "رقم البطاقة"
    case CardNamePl = "اسم حامل البطاقة"
    case ExpDateLbl = "تاريخ الانتهاء"
    case CVCtxt = "رمز التحقق"
    case PayBtn = "دفع"
    case Init_conn = "إينيت اتصال آمن ..."
    case YourReceiptLbl = "إيصال"
    case monthyearLbl = "شهر"
    case saveCarLbl = "حفظ"
    case alertTitle = "تنبية‎"
    case titleMessage = "هل تريد إلغاء الدفع"
    case yesBtn = "نعم "
    case noBtn = "لا"
    case pf_cancel_required_field = "الحقل المطلوب فارغ"
}

//
//
//alertTitle
//titleMessage
//yesBtn
//noBtn
//case "titleviewLbl":
//return PaymentKeys.titleviewLbl.rawValue
//case "CardNumberPl":
//return PaymentKeys.CardNamePI.rawValue
//case "ExpDateLbl":
//return PaymentKeys.ExpDateLbl.rawValue
//case "CVCtxt":
//return PaymentKeys.CVCtxt.rawValue
//case "PayBtn":
//return PaymentKeys.payBtn.rawValue
//case "Init_conn":
//return PaymentKeys.ExpDateLbl.rawValue
//case "CardNamePl":
//return PaymentKeys.ExpDateLbl.rawValue
//case "YourReceiptLbl":
//return PaymentKeys.ExpDateLbl.rawValue
//case "monthyearLbl":
//return PaymentKeys.ExpDateLbl.rawValue
//case "saveCarLbl":
//return PaymentKeys.ExpDateLbl.rawValue
//default:
//return ""
