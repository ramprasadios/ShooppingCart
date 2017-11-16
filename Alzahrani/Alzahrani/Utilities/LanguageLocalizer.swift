//
//  LanguageLocalizer.swift
//  Alzahrani
//
//  Created by Hardwin on 09/06/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation
import UIKit
import Localize_Swift

class LanguageLocalizer: NSObject {
    
    class func DoTheSwizzling() {
        //1
        if AppDelegate.delegate().isOnlinePaymentInitiated == false {
            MethodSwizzleGivenClassName(cls: Bundle.self, originalSelector: #selector(Bundle.localizedString(forKey:value:table:)), overrideSelector: #selector(Bundle.specialLocalizedStringForKey(key:value:table:)))
            MethodSwizzleGivenClassName(cls: UIApplication.self, originalSelector: #selector(getter: UIApplication.userInterfaceLayoutDirection), overrideSelector: #selector(getter: UIApplication.cstm_userInterfaceLayoutDirection))
        }
    }
}

extension Bundle {
    func specialLocalizedStringForKey(key: String, value: String?, table tableName: String?) -> String {
        if AppDelegate.delegate().isOnlinePaymentInitiated == false {
            let currentLanguage = LanguageManager.currentAppleLanguage()
            var bundle = Bundle()
            if let _path = Bundle.main.path(forResource: currentLanguage, ofType: "lproj") {
                bundle = Bundle(path: _path)!
            } else {
                let _path = Bundle.main.path(forResource: "Base", ofType: "lproj")!
                bundle = Bundle(
                    path: _path)!
            }
            return (bundle.specialLocalizedStringForKey(key: key, value: value, table: tableName))
        } else {
            if AppManager.languageType() == .arabic {
                return getArabicString(forKey: key)
            } else {
                return getEnglistString(forKey: key)
            }
        }
    }
}

/// Exchange the implementation of two methods for the same Class
func MethodSwizzleGivenClassName(cls: AnyClass, originalSelector: Selector, overrideSelector: Selector) {
    let origMethod: Method = class_getInstanceMethod(cls, originalSelector);
    let overrideMethod: Method = class_getInstanceMethod(cls, overrideSelector);
    if (class_addMethod(cls, originalSelector, method_getImplementation(overrideMethod), method_getTypeEncoding(overrideMethod))) {
        class_replaceMethod(cls, overrideSelector, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    } else {
        method_exchangeImplementations(origMethod, overrideMethod);
    }
}

func getEnglistString(forKey key: String) -> String {
    switch key {
    case "titleviewLbl":
        return PaymentEnglishKeys.titleviewLbl.rawValue
    case "CardNumberPl":
        return PaymentEnglishKeys.CardNumberPl.rawValue
    case "ExpDateLbl":
        return PaymentEnglishKeys.ExpDateLbl.rawValue
    case "CVCtxt":
        return PaymentEnglishKeys.CVCtxt.rawValue
    case "PayBtn":
        return PaymentEnglishKeys.PayBtn.rawValue
    case "Init_conn":
        return PaymentEnglishKeys.Init_conn.rawValue
    case "CardNamePl":
        return PaymentEnglishKeys.CardNamePl.rawValue
    case "YourReceiptLbl":
        return PaymentEnglishKeys.YourReceiptLbl.rawValue
    case "monthyearLbl":
        return PaymentEnglishKeys.monthyearLbl.rawValue
    case "saveCarLbl":
        return PaymentEnglishKeys.saveCarLbl.rawValue
        
    case "yesBtn":
        return PaymentEnglishKeys.yesBtn.rawValue
        case "noBtn":
        return PaymentEnglishKeys.noBtn.rawValue
    case "alertTitle":
        return PaymentEnglishKeys.alertTitle.rawValue
    case "titleMessage":
        return PaymentEnglishKeys.titleMessage.rawValue
    case "pf_cancel_required_field":
        return PaymentEnglishKeys.pf_cancel_required_field.rawValue
    default:
        return ""
    }
}

func getArabicString(forKey key: String) -> String {
    switch key {
    case "titleviewLbl":
        return PaymentArabicKeys.titleviewLbl.rawValue
    case "CardNumberPl":
        return PaymentArabicKeys.CardNamePl.rawValue
    case "ExpDateLbl":
        return PaymentArabicKeys.ExpDateLbl.rawValue
    case "CVCtxt":
        return PaymentArabicKeys.CVCtxt.rawValue
    case "PayBtn":
        return PaymentArabicKeys.PayBtn.rawValue
    case "Init_conn":
        return PaymentArabicKeys.Init_conn.rawValue
    case "CardNamePl":
        return PaymentArabicKeys.CardNamePl.rawValue
    case "YourReceiptLbl":
        return PaymentArabicKeys.YourReceiptLbl.rawValue
    case "monthyearLbl":
        return PaymentArabicKeys.monthyearLbl.rawValue
    case "saveCarLbl":
        return PaymentArabicKeys.saveCarLbl.rawValue
        
    case "yesBtn":
        return PaymentArabicKeys.yesBtn.rawValue
    case "noBtn":
        return PaymentArabicKeys.noBtn.rawValue
    case "alertTitle":
        return PaymentArabicKeys.alertTitle.rawValue
    case "titleMessage":
        return PaymentArabicKeys.titleMessage.rawValue
    case "pf_cancel_required_field":
        return PaymentArabicKeys.pf_cancel_required_field.rawValue
    default:
        return ""
    }
}

extension UIApplication {
    
    var cstm_userInterfaceLayoutDirection : UIUserInterfaceLayoutDirection {
        get {
            var direction = UIUserInterfaceLayoutDirection.leftToRight
            if LanguageManager.currentAppleLanguage() == "ar" {
                direction = .rightToLeft
            }
            return direction
        }
    }
}
