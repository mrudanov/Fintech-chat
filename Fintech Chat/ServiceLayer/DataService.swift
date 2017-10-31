//
//  DataService.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 31/10/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import Foundation

protocol DataSerivce {
    func saveUserData(_ data: Data, completion: @escaping (Error?) -> (Void))
    func loadUserData(completion: @escaping (Data?, Error?) -> (Void))
}

class DataManager: DataSerivce {
    private var tasker: Tasker?
    private var storage: Storage
    
    init(tasker: Tasker, storage: Storage) {
        self.tasker = tasker
        self.storage = storage
    }
    
    func saveUserData(_ data: Data, completion: @escaping (Error?) -> (Void)) {
        tasker?.performBackgroundTask { [weak self] in
            if self != nil {
                let error = self!.storage.saveData(data)
                completion(error)
            }
        }
    }
    
    func loadUserData(completion: @escaping (Data?, Error?) -> (Void)) {
        tasker?.performBackgroundTask { [weak self] in
            if self != nil {
                let (data, error) = self!.storage.loadData()
                completion(data, error)
            }
        }
    }
}
