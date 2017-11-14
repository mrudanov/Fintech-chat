//
//  ConversationsListAssembly.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 29/10/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import Foundation
import UIKit

class ConversationsListAssembly {
    private let storageManager: StorageManager
    
    init(storageManager: StorageManager) {
        self.storageManager = storageManager
    }
    
    public func embededInNavProfileVC() -> UINavigationController {
        let navigationController = UIStoryboard(name: "ConversationsList", bundle: nil).instantiateViewController(withIdentifier: "ConversationsNavigation") as! UINavigationController
        navigationController.viewControllers[0] = conversationsListViewController()
        return navigationController
    }
    
    // MARK: - PRIVATE SECTION
    private func conversationsListViewController() -> ConversationsListViewController {
        let service = conversationsPreviewsService(storageManager: storageManager)
        let model = conversationsListTableDataSource(service: service)
        let communicationListVC = ConversationsListViewController.initVC(with: model)
        return communicationListVC
    }
    
    private func conversationsPreviewsService(storageManager: StorageManager) -> IConversationsPreviewsService {
        return ConversationsPreviewsService(storageManager: storageManager)
    }
    
    private func conversationsListTableDataSource(service: IConversationsPreviewsService) -> IConversationsListTableDataSource {
        return ConversationsListTableDataSource(service: service)
    }
}
