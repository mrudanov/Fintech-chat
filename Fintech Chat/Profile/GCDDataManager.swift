//
//  GCDDataManager.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 15/10/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import Foundation

class GCDDataManager: DataManager {
    let queue = DispatchQueue.global(qos: .userInitiated)
    
    func saveUserInfo(_ userInfo: UserInfo, to fileURL: URL, completion: @escaping (Error?) -> (Void)){
        queue.async {
            do {
                let encoder = JSONEncoder()
                let data = try encoder.encode(userInfo)
                try data.write(to: fileURL)
                DispatchQueue.main.async {
                    completion(nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
    }
    
    func loadUserInfo(from url: URL, completion: @escaping (Error? ,String?, String?, String?) -> (Void)) {
        queue.async {
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: url.path) {
                do {
                    let data = try Data(contentsOf: url)
                    let decoder = JSONDecoder()
                    let userInfo = try decoder.decode(UserInfo.self, from: data)
                    DispatchQueue.main.async {
                        completion(nil, userInfo.name, userInfo.info, userInfo.image)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(error ,nil, nil, nil)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil ,nil, nil, nil)
                }
            }
        }
    }
}
