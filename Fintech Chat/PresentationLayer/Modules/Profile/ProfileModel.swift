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
    func saveUserInfo(_ userInfo: UIUserInfo, completion: @escaping () -> (Void))
    func loadUserInfo() -> UIUserInfo
}

struct UserInfo {
    var name: String?
    var info: String?
    var image: Data?
}

class ProfileModel: IProfileModel {
    private let profileService: IProfileService
    
    init(profileService: IProfileService) {
        self.profileService = profileService
    }
    
    func saveUserInfo(_ userInfo: UIUserInfo, completion: @escaping () -> (Void)) {
        let image = userInfo.image == nil ? nil : UIImageJPEGRepresentation(userInfo.image!, 0.8)
        let infoToSave = UserInfo(name: userInfo.name, info: userInfo.info, image: image)
        profileService.updateAppUserInfo(userInfo: infoToSave, completionHandler: completion)
    }
    
    func loadUserInfo() -> UIUserInfo {
        let userInfo = profileService.getAppUserInfo()
        var uiUserInfo = UIUserInfo(name: userInfo.name, info: userInfo.info, image: nil)
        if let imageData = userInfo.image {
            uiUserInfo.image = UIImage(data: imageData)
        }
        
        return uiUserInfo
    }
}
