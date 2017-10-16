//
//  OperationDataManager.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 15/10/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import Foundation

class SaveOperation: Operation {
    private let dataToSave: UserInfo
    private let destinationURL: URL
    private var completionHandler: (Error?) -> (Void)
    
    init(userData: UserInfo, url: URL, completion: @escaping (Error?) -> (Void)) {
        dataToSave = userData
        destinationURL = url
        completionHandler = completion
        super.init()
    }
    override func main() {
        let mainOperationQueue = OperationQueue.main
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(dataToSave)
            try data.write(to: destinationURL)
            mainOperationQueue.addOperation {
                self.completionHandler(nil)
            }
        } catch {
            mainOperationQueue.addOperation {
                self.completionHandler(error)
            }
        }
        
    }
}

class LoadOperation: Operation {
    private let loadURL: URL
    private var completionHandler: (Error?, String?, String?, String?) -> (Void)

    init(url: URL, completion: @escaping (Error?, String?, String?, String?) -> (Void)) {
        loadURL = url
        completionHandler = completion
        super.init()
    }
    
    override func main() {
        let mainOperationQueue = OperationQueue.main
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: loadURL.path) {
            do {
                let data = try Data(contentsOf: loadURL)
                let decoder = JSONDecoder()
                let userInfo = try decoder.decode(UserInfo.self, from: data)
                mainOperationQueue.addOperation {
                    self.completionHandler(nil, userInfo.name, userInfo.info, userInfo.image)
                }
            } catch {
                mainOperationQueue.addOperation {
                    self.completionHandler(error, nil, nil, nil)
                }
            }
        } else {
            mainOperationQueue.addOperation {
                self.completionHandler(nil, nil, nil, nil)
            }
        }
    }
}

class OperationDataManager: DataManager {
    func saveUserInfo(_ userInfo: UserInfo, to fileURL: URL, completion: @escaping (Error?) -> (Void)){
        let operationQueue = OperationQueue()
        let saveOperation = SaveOperation(userData: userInfo, url: fileURL, completion: completion)
        operationQueue.addOperation(saveOperation)
    }
    
    func loadUserInfo(from url: URL, completion: @escaping (Error?, String?, String?, String?) -> (Void)) {
        let operationQueue = OperationQueue()
        let loadOperation = LoadOperation(url: url, completion: completion)
        operationQueue.addOperation(loadOperation)
    }
}
