//
//  ImportSyncOperation.swift
//  Alzahrani
//
//  Created by Hardwin on 05/06/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation
import Alamofire
import MagicalRecord

class ImportSyncOperation: BaseSyncOperation {
    
}

extension ImportSyncOperation {
    
    override func startProcessing() {
        switch (self.operationType) {
        case .importOperation:
            self.importAllProductsToDB()
        default:
            break
        }
    }
}

extension ImportSyncOperation {
    
    func importAllProductsToDB() {
        if let userDict = userDict {
            for product in userDict {
                self.didFinishDownloadingAllProducts(data: product)
            }
        }
    }
}

//MARK:- Helper Methods:
extension ImportSyncOperation {
    
    func didFinishDownloadingAllProducts(data: [String: AnyObject]) {
        if AppManager.currentApplicationMode() == .offline {
            MagicalRecord.save(blockAndWait: { context in
                _ = Product.mr_import(from: data, in: context)
            })
        }
    }
}
