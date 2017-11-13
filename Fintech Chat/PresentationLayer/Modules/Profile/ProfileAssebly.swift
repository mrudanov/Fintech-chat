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
    
    private let profileService: IProfileService
    
    init(profileService: IProfileService) {
        self.profileService = profileService
    }
    
    func embededInNavProfileVC() -> UINavigationController {
        let navigationController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "ProfileNavigation") as! UINavigationController
        navigationController.viewControllers[0] = profileViewController()
        return navigationController
    }
    
    // MARK: - PRIVATE SECTION
    private func profileViewController() -> ProfileViewController {
        let model = profileDataModel(profileService: profileService)
        
        let profileVC = ProfileViewController.initVC(model: model)
        
        return profileVC
    }
    
    private func profileDataModel(profileService: IProfileService) -> IProfileModel {
        return ProfileModel(profileService: profileService)
    }
    
}
