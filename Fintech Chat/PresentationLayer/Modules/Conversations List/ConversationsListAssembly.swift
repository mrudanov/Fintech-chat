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
    
    private let communicator: Communicator
    private let coreDataStack: ICoreDataStack
    
    init(communicator: Communicator, coreDataStack: ICoreDataStack) {
        self.communicator = communicator
        self.coreDataStack = coreDataStack
    }
    
    func embededInNavProfileVC() -> UINavigationController {
        let navigationController = UIStoryboard(name: "ConversationsList", bundle: nil).instantiateViewController(withIdentifier: "ConversationsNavigation") as! UINavigationController
        navigationController.viewControllers[0] = conversationsListViewController(communicator: communicator, coreDataStack: coreDataStack)
        return navigationController
    }
    
    // MARK: - PRIVATE SECTION
    private func conversationsListViewController(communicator: Communicator, coreDataStack: ICoreDataStack) -> ConversationsListViewController {
        let service = conversationPreviewsService(coreDataStack: coreDataStack)
        let model = tableDataSource(conversationService: service)
        let communicationListVC = ConversationsListViewController.initVC(with: model)
        service.FRCDelegate = model
        communicator.delegate = service
        return communicationListVC
    }
    
    private func tableDataSource(conversationService: IConversationPreviewsService) -> ConversationsListTableDataSource {
        return ConversationsListTableDataSource(service: conversationService)
    }
    private func conversationPreviewsService(coreDataStack: ICoreDataStack) -> ConversationPreviewsService {
        return ConversationPreviewsService(coreDataStack: coreDataStack)
    }
}
