//
//  DBManager.swift
//  Alhzarani
//
//  Created by Ramprasad A on 05/12/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import Foundation
import MagicalRecord

class DBManager : NSObject {
    
    class var DBUrlPath: URL {
        get {
            return NSPersistentStore.mr_url(forStoreName: DBManager.dbStore())!
        }
    }
    
    private struct Constants {
        static let sharedManager = DBManager()
    }
    
    class func sharedManager() -> DBManager {
        return Constants.sharedManager
    }
    
    override init() {
        super.init()
    }
    
    class func dbStore() -> String {
        return "DB/\(Bundle.bundleID()).sqlite"
    }
}

extension DBManager {
    
    //DB setup
    func setupDB() {
        MagicalRecord.setupCoreDataStack(withAutoMigratingSqliteStoreNamed: DBManager.dbStore())
        print("FIletype root \(DBManager.DBUrlPath.absoluteString)")
    }
    
    @discardableResult
    func cleanAndResetupDB() -> Bool {
        let dbStore = DBManager.dbStore()
        let fileManager = FileManager.default
        var deleteSuccess = true
        var retVal = false
        
        let storeURL = NSPersistentStore.mr_url(forStoreName: dbStore)
        let walURL = storeURL?.deletingPathExtension().appendingPathExtension("sqlite-wal")
        let shmURL = storeURL?.deletingPathExtension().appendingPathExtension("sqlite-shm")
        
        for eachURL in [storeURL, walURL, shmURL] {
            if let eachURL = eachURL {
                if fileManager.fileExists(atPath: eachURL.path) {
                    do {
                        try fileManager.removeItem(at: eachURL)
                        deleteSuccess = true
                        
                    } catch _ {
                        
                    }
                }
            }
        }
        
        MagicalRecord.cleanUp()
        
        if deleteSuccess {
            self.setupDB()
            retVal = true
        } else {
            
        }
        
        return retVal
    }
}
