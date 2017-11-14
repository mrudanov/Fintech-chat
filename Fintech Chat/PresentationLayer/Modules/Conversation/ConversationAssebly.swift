//
//  ConversationAssebly.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 30/10/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import Foundation

class ConversationAssembly {
    
    private let storageManager: StorageManager
    private let communicationManager: ICommunicationManager
    
    init(storageManager: StorageManager, communicationManager: ICommunicationManager) {
        self.storageManager = storageManager
        self.communicationManager = communicationManager
    }
    
    func conversationViewController(userID: String, userName: String) -> ConversationViewController {
        let service = conversationService(userId: userID, storageManager: storageManager, communicationManager: communicationManager)
        
        let model = conversationsListTableDataSource(userId: userID, service: service)
        
        let conversationVC = ConversationViewController.initVC(with: model, userID: userID, userName: userName)
        return conversationVC
    }
    
    // MARK: - PRIVATE SECTION
    private func conversationService(userId: String, storageManager: StorageManager, communicationManager: ICommunicationManager) -> IConversationService {
        return ConversationService(userId: userId, storageManager: storageManager, communicationManager: communicationManager)
    }
    
    private func conversationsListTableDataSource(userId: String, service: IConversationService) -> IConversationTableDataSource {
        return ConversationTableDataSource(userId: userId, conversationService: service)
    }
}
