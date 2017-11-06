//
//  StorageManager.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 06/11/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import Foundation
import UIKit

protocol IStorageManager {
    func updateAppUserInfo(userInfo: UserInfo, completionHandler: (()->Void)? )
    func getAppUserInfo(completionHandler: ((UserInfo)->Void)? )
}

class StorageManager: IStorageManager {
    private let coreDataStack: ICoreDataStack
    
    init(coreDataStack: ICoreDataStack) {
        self.coreDataStack = coreDataStack
        guard let saveContext = coreDataStack.saveContext else {
            assert(false, "No save context!")
        }
        _ = AppUser.findOrInsertAppUser(in: saveContext)
        coreDataStack.performSave(context: saveContext, completionHandler: nil)
    }
    
    public func updateAppUserInfo(userInfo: UserInfo, completionHandler: (()->Void)? ) {
        guard let saveContext = coreDataStack.saveContext else {
            assert(false, "No save context!")
        }
        
        saveContext.perform { [weak self] in
            let appUser = AppUser.findOrInsertAppUser(in: saveContext)
            appUser?.currentUser?.name = userInfo.name
            appUser?.currentUser?.info = userInfo.info
            appUser?.currentUser?.image = userInfo.image
            
            self?.coreDataStack.performSave(context: saveContext, completionHandler: completionHandler)
        }
    }
    
    public func getAppUserInfo(completionHandler: ((UserInfo)->Void)?) {
        guard let mainContext = coreDataStack.saveContext else {
            assert(false, "No save context!")
        }
        
        mainContext.perform { [weak self] in
            let appUser = AppUser.findOrInsertAppUser(in: mainContext)
            let name = appUser?.currentUser?.name
            let info = appUser?.currentUser?.info
            let image = appUser?.currentUser?.image
            
            self?.coreDataStack.performSave(context: mainContext, completionHandler: nil)
            completionHandler?(UserInfo(name: name, info: info, image: image))
        }
    }
}
