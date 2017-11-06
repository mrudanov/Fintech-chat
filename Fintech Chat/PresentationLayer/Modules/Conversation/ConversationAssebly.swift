//
//  ConversationAssebly.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 30/10/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import Foundation

class ConversationAssembly {
    
    private let communicationService: CommunicationService
    
    init(communicationService: CommunicationService) {
        self.communicationService = communicationService
    }
    
    func conversationViewController(userID: String, userName: String) -> ConversationViewController {
        let model = conversationDataModel(communicationService: communicationService, userID: userID)
        let conversationVC = ConversationViewController.initVC(with: model, userID: userID, userName: userName)
        model.delegate = conversationVC
        communicationService.addDelegate(delegate: model)
        return conversationVC
    }
    
    // MARK: - PRIVATE SECTION
    private func conversationDataModel(communicationService: CommunicationService, userID: String) -> ConversationModel {
        return ConversationModel(communicationService: communicationService, contactID: userID)
    }
}
