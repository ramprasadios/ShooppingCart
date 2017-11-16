//
//  BaseOperationQueueManager.swift
//  Alzahrani
//
//  Created by Ramprasad on 05/05/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class BaseOperationQueueManager: NSObject {
    
    fileprivate var downloadSyncQueue: OperationQueue?
    var uploadSyncQueue: OperationQueue?
    fileprivate var avatarProfileQueue: OperationQueue?
    fileprivate var pictureMetaDataQueue : OperationQueue?
    fileprivate var backgroundTaskQueueForUI : OperationQueue?
    fileprivate var productDownloadTaskQueue: OperationQueue?
    
    //MARK:- Super Methods:
    
    override init() {
        super.init()
        
        downloadSyncQueue = OperationQueue()
        downloadSyncQueue?.name = "BaseDownloadOperationQueue"
        
        uploadSyncQueue = OperationQueue()
        uploadSyncQueue?.name = "BaseUploadOperationQueue"
        
        pictureMetaDataQueue = OperationQueue()
        pictureMetaDataQueue?.name = "pictureMetaDataOperationQueue"
        
        backgroundTaskQueueForUI = OperationQueue()
        backgroundTaskQueueForUI?.name = "backgroundTaskQueueForUI"
        
        avatarProfileQueue = OperationQueue()
        avatarProfileQueue?.name = "avatarProfileQueue"
        
        productDownloadTaskQueue = OperationQueue()
        productDownloadTaskQueue?.name = "productDownloadTaskQueue"
    }
}

//MARK:- Helper Methods:
extension BaseOperationQueueManager {
    
    func addDownloadOperation(operation: Operation) {
        downloadSyncQueue?.addOperation(operation)
    }
    
    func addUploadOperation(operation: Operation) {
        uploadSyncQueue?.addOperation(operation)
        let _ = getUploadSyncQueueCount()
    }
    
    func addPictureMetaDataOperation(operation: Operation) {
        pictureMetaDataQueue?.addOperation(operation)
    }
    
    func addBackgroundTaskUIOperation(operation: Operation) {
        backgroundTaskQueueForUI?.addOperation(operation)
    }
    
    func addAvatarProfileOperation(operation: Operation) {
        avatarProfileQueue?.addOperation(operation)
    }
    
    func addProductDownloadOperation(operation: Operation) {
        productDownloadTaskQueue?.addOperation(operation)
    }
    
    func cancelAllQueues() {
        downloadSyncQueue?.cancelAllOperations()
        uploadSyncQueue?.cancelAllOperations()
        pictureMetaDataQueue?.cancelAllOperations()
        backgroundTaskQueueForUI?.cancelAllOperations()
        avatarProfileQueue?.cancelAllOperations()
        productDownloadTaskQueue?.cancelAllOperations()
    }
    
    func getUploadSyncQueueCount() -> Int{
        print("sync count is \(self.uploadSyncQueue?.operationCount)")
        return (self.uploadSyncQueue?.operationCount)!
    }
    
    func getCurrentOperation() -> Operation? {
        print("sync count is \(OperationQueue.current?.operations)")
        return OperationQueue.current?.operations.first
    }
    
    func cancelUploadOperation() {
        self.uploadSyncQueue?.cancelAllOperations()
    }
    
    func canceldownloadOperation() {
        self.downloadSyncQueue?.cancelAllOperations()
    }

}

