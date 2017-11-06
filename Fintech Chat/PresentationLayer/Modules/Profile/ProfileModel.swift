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
    func saveUserInfo(_ userInfo: UserInfo, completion: @escaping () -> (Void))
    func loadUserInfo(completionHandler: ((UserInfo)->Void)?)
}

struct UserInfo {
    var name: String?
    var info: String?
    var image: Data?
}

class ProfileModel: IProfileModel {
    private let storageManager: IStorageManager
    
    init(storageManager: IStorageManager) {
        self.storageManager = storageManager
    }
    
    func saveUserInfo(_ userInfo: UserInfo, completion: @escaping () -> (Void)) {
        storageManager.updateAppUserInfo(userInfo: userInfo, completionHandler: completion)
    }
    
    func loadUserInfo(completionHandler: ((UserInfo)->Void)?) {
        return storageManager.getAppUserInfo(completionHandler: completionHandler)
    }
}
