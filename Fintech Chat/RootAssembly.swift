//
//  RootAssembly.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 29/10/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import Foundation

class RootAssembly {
    // Убрать
    private let communicationService: CommunicationService
    
    private let communicator: Communicator
    private let coreDataStack: ICoreDataStack
    
    let conversationsListModule: ConversationsListAssembly
    let conversationModule: ConversationAssembly
    let profileModule: ProfileAssembly
    
    init() {
        coreDataStack = CoreDataStack()
        let profileService = ProfileService(coreDataStack: coreDataStack)
        
        communicator = MultipeerCommunicator()
        profileService.getAppUserInfo() { [weak communicator] userInfo in
            if let name = userInfo.name {
                communicator?.setDisplayName(name)
            }
            communicator?.online = true
        }
        
        
        // Убрать
        communicationService = CommunicationManager(communicator: communicator)
        communicator.delegate = communicationService as? CommunicatorDelegate
        
        
        
        profileModule = ProfileAssembly(profileService: profileService)
        conversationsListModule = ConversationsListAssembly(communicator: communicator, coreDataStack: coreDataStack)
        conversationModule = ConversationAssembly(communicationService: communicationService)
    }
}
