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
    
    private let storageManager: IStorageManager
    
    init(storageManager: IStorageManager) {
        self.storageManager = storageManager
    }
    
    func embededInNavProfileVC() -> UINavigationController {
        let navigationController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "ProfileNavigation") as! UINavigationController
        navigationController.viewControllers[0] = profileViewController()
        return navigationController
    }
    
    // MARK: - PRIVATE SECTION
    private func profileViewController() -> ProfileViewController {
        let model = profileDataModel(storageManager: storageManager)
        
        let profileVC = ProfileViewController.initVC(model: model)
        
        return profileVC
    }
    
    private func profileDataModel(storageManager: IStorageManager) -> IProfileModel {
        return ProfileModel(storageManager: storageManager)
    }
    
}
