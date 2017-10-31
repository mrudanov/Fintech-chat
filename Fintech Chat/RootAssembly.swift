//
//  RootAssembly.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 29/10/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import Foundation

class RootAssembly {
    private let communicator: Communicator
    var communicationService: CommunicationService
    var conversationsListModule: ConversationsListAssembly = ConversationsListAssembly()
    var conversationModule: ConversationAssembly = ConversationAssembly()
    var profileModule: ProfileAssembly = ProfileAssembly()
    
    init() {
        communicator = MultipeerCommunicator(visibleName: UserDefaults.standard.string(forKey: "DiscoveryName"))
        communicationService = CommunicationManager(communicator: communicator)
        communicator.delegate = communicationService as? CommunicatorDelegate
    }
}
