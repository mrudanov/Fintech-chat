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
    func getAppUserInfo(completionHandler: ((UserInfo)->Void)? )
}

class ProfileService: IProfileService {
    private let coreDataStack: ICoreDataStack
    
    init(coreDataStack: ICoreDataStack) {
        self.coreDataStack = coreDataStack
        guard let mainContext = coreDataStack.mainContext else {
            assert(false, "No save context!")
        }
        mainContext.perform {
            if let mainContext = coreDataStack.mainContext {
                _ = AppUser.findOrInsertAppUser(in: mainContext)
                coreDataStack.performSave(context: mainContext, completionHandler: nil)
            }
        }
    }
    
    public func updateAppUserInfo(userInfo: UserInfo, completionHandler: (()->Void)? ) {
        guard let saveContext = coreDataStack.saveContext else {
            assert(false, "No save context!")
        }
        
        saveContext.perform { [weak self] in
            if let saveContext = self?.coreDataStack.saveContext {
                let appUser = AppUser.findOrInsertAppUser(in: saveContext)
                appUser?.currentUser?.name = userInfo.name
                appUser?.currentUser?.info = userInfo.info
                appUser?.currentUser?.image = userInfo.image
                
                self?.coreDataStack.performSave(context: saveContext, completionHandler: nil)
                completionHandler?()
            }
        }
    }
    
    public func getAppUserInfo(completionHandler: ((UserInfo)->Void)?) {
        guard let mainContext = coreDataStack.saveContext else {
            assert(false, "No save context!")
        }
        
        mainContext.perform {
            let appUser = AppUser.findAppUser(in: mainContext)
            let name = appUser?.currentUser?.name
            let info = appUser?.currentUser?.info
            let image = appUser?.currentUser?.image
            
            completionHandler?(UserInfo(name: name, info: info, image: image))
        }
    }
}
