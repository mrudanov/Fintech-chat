//
//  RootAssembly.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 29/10/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import Foundation

class RootAssembly {
    private let communicationService: CommunicationService
    private let storageManager: IStorageManager
    
    let conversationsListModule: ConversationsListAssembly
    let conversationModule: ConversationAssembly
    let profileModule: ProfileAssembly
    
    init() {
        let coreDataStack: ICoreDataStack = CoreDataStack()
        storageManager = StorageManager(coreDataStack: coreDataStack)
        
        let communicator: Communicator = MultipeerCommunicator()
        communicationService = CommunicationManager(communicator: communicator)
        communicator.delegate = communicationService as? CommunicatorDelegate
        
        storageManager.getAppUserInfo() { [weak communicator] userInfo in
            if let name = userInfo.name {
                communicator?.setDisplayName(name)
            }
            communicator?.online = true
        }
        
        profileModule = ProfileAssembly(storageManager: storageManager)
        conversationsListModule = ConversationsListAssembly(communicationService: communicationService)
        conversationModule = ConversationAssembly(communicationService: communicationService)
    }
}
