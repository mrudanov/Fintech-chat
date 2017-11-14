//
//  ProfileService.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 11/11/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import Foundation

protocol IProfileService {
    func updateAppUserInfo(userInfo: UserInfo, completionHandler: (()->Void)? )
    func getAppUserInfo() -> UserInfo
    func getAppUserId() -> String
}

class ProfileService: IProfileService {
    private let storageManager: StorageManager
    private let communicationManager: ICommunicationManager
    
    init(storageManager: StorageManager, communicationManager: ICommunicationManager) {
        self.storageManager = storageManager
        self.communicationManager = communicationManager
    }
    
    public func updateAppUserInfo(userInfo: UserInfo, completionHandler: (()->Void)? ) {
        let userId = storageManager.getAppUserId()
        
        storageManager.updateUser(userID: userId, userName: userInfo.name, info: userInfo.info, image: userInfo.image, isOnline: false) { [weak self] in
            completionHandler?()
            self?.communicationManager.reloadCommunicator()
        }
    }
    
    public func getAppUserInfo() -> UserInfo {
        let (name, info, image) = storageManager.getAppUserInfo()
        
        return UserInfo(name: name, info: info, image: image)
    }
    
    public func getAppUserId() -> String {
        return storageManager.getAppUserId()
    }
}
