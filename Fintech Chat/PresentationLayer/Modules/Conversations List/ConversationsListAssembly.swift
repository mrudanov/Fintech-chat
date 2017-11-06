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
    
    private let communicationService: CommunicationService
    
    init(communicationService: CommunicationService) {
        self.communicationService = communicationService
    }
    
    func embededInNavProfileVC() -> UINavigationController {
        let navigationController = UIStoryboard(name: "ConversationsList", bundle: nil).instantiateViewController(withIdentifier: "ConversationsNavigation") as! UINavigationController
        navigationController.viewControllers[0] = conversationsListViewController(service: communicationService)
        return navigationController
    }
    
    // MARK: - PRIVATE SECTION
    
    private func conversationsListViewController(service: CommunicationService) -> ConversationsListViewController {
        let model = previewDataModel(communicationService: service)
        let communicationListVC = ConversationsListViewController.initVC(with: model)
        model.delegate = communicationListVC
        service.addDelegate(delegate: model)
        return communicationListVC
    }
    
    private func previewDataModel(communicationService: CommunicationService) -> ConversationsPreviewModel {
        return ConversationsPreviewModel(communicationService: communicationService)
    }
}
