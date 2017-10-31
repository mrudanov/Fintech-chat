//
//  ProfileModel.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 31/10/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import Foundation
import UIKit

protocol IProfileModel {
    func saveUserInfo(_ userInfo: UserInfo, completion: @escaping (Error?) -> (Void))
    func loadUserInfo(completion: @escaping (Error?, UserInfo?) -> (Void))
}

class ProfileModel: IProfileModel {
    private struct CodableUserInfo: Codable {
        var name: String?
        var info: String?
        var image: String?
    }
    
    private let dataService: DataSerivce
    
    init(dataService: DataSerivce) {
        self.dataService = dataService
    }
    
    func saveUserInfo(_ userInfo: UserInfo, completion: @escaping (Error?) -> (Void)) {
        var codableUserInfo = CodableUserInfo(name: userInfo.name, info: userInfo.info, image: nil)
        if userInfo.image != nil{
            let imageData = UIImageJPEGRepresentation(userInfo.image!, 0.85)
            let base64Image = imageData?.base64EncodedString()
            codableUserInfo.image = base64Image
        }
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(codableUserInfo)
            dataService.saveUserData(data, completion: completion)
        } catch {
            completion(error)
        }
    }
    
    func loadUserInfo(completion: @escaping (Error?, UserInfo?) -> (Void)) {
        dataService.loadUserData() { data, error in
            if data != nil {
                do {
                    let decoder = JSONDecoder()
                    let dacodedInfo = try decoder.decode(CodableUserInfo.self, from: data!)
                    var userInfo = UserInfo(name: dacodedInfo.name, info: dacodedInfo.info, image: nil)
                    UserDefaults.standard.set(userInfo.name, forKey: "DiscoveryName")
                    if dacodedInfo.image != nil, dacodedInfo.image != "", let data = Data(base64Encoded: dacodedInfo.image!) {
                        userInfo.image = UIImage(data: data)
                    }
                    completion(nil, userInfo)
                } catch {
                    completion(error ,nil)
                }
            } else {
                completion(error, nil)
            }
        }
    }
}
