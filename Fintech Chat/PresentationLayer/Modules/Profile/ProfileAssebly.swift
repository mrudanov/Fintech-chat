//
//  ProfileAssebly.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 31/10/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import Foundation
import UIKit

class ProfileAssembly {
    
    private let storageManager: StorageManager
    private let communicationManager: ICommunicationManager
    
    init(storageManager: StorageManager, communicationManager: ICommunicationManager) {
        self.storageManager = storageManager
        self.communicationManager = communicationManager
    }
    
    func embededInNavProfileVC() -> UINavigationController {
        let navigationController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "ProfileNavigation") as! UINavigationController
        navigationController.viewControllers[0] = profileViewController()
        return navigationController
    }
    
    // MARK: - PRIVATE SECTION
    private func profileViewController() -> ProfileViewController {
        let service = profileService(storageManager: storageManager, communicationManager: communicationManager)
        let model = profileDataModel(profileService: service)
        
        let profileVC = ProfileViewController.initVC(model: model)
        
        return profileVC
    }
    
    private func profileDataModel(profileService: IProfileService) -> IProfileModel {
        return ProfileModel(profileService: profileService)
    }
    
    private func profileService(storageManager: StorageManager, communicationManager: ICommunicationManager) -> IProfileService {
        return ProfileService(storageManager: storageManager, communicationManager: communicationManager)
    }
    
}
