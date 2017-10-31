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
    
    func embededInNavProfileVC() -> UINavigationController {
        let navigationController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "ProfileNavigation") as! UINavigationController
        navigationController.viewControllers[0] = profileViewController()
        return navigationController
    }
    
    // MARK: - PRIVATE SECTION
    
    private func profileViewController() -> ProfileViewController {
        let GCDtasker: Tasker = GCDTasker()
        let operationTasker: Tasker = OperationTasker()
        
        let GCDModel = profileDataModel(tasker: GCDtasker)
        let operationModel = profileDataModel(tasker: operationTasker)
        
        let profileVC = ProfileViewController.initVC(GCDmodel: GCDModel, operationModel: operationModel)
        
        return profileVC
    }
    
    private func profileDataModel(tasker: Tasker) -> IProfileModel {
        return ProfileModel(dataService: dataService(tasker: tasker))
    }
    
    private func dataService(tasker: Tasker) -> DataSerivce {
        return DataManager(tasker: tasker, storage: storage())
    }
    
    private func storage() -> Storage {
        return FileStorage()
    }
}
