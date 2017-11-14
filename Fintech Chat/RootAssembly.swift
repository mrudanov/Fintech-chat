//
//  RootAssembly.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 29/10/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import Foundation

class RootAssembly {
    
    private var _coreDataStack: ICoreDataStack?
    private var coreDataStack: ICoreDataStack {
        get {
            if _coreDataStack == nil {
                _coreDataStack = CoreDataStack()
            }
            return _coreDataStack!
        }
    }
    
    private var _storageManager: StorageManager?
    private var storageManager: StorageManager {
        get {
            if _storageManager == nil {
                _storageManager = CoreDataStorageManager(coreDataStack: coreDataStack)
            }
            return _storageManager!
        }
    }
    
    private var _communicationManager: ICommunicationManager?
    private var communicationManager: ICommunicationManager {
        get {
            if _communicationManager == nil {
                _communicationManager = CommunicationManager(storageManager: storageManager)
                _communicationManager?.online = true
            }
            
            return _communicationManager!
        }
    }
    
    
    private var _conversationsListModule: ConversationsListAssembly?
    public var conversationsListModule: ConversationsListAssembly {
        get {
            if _conversationsListModule == nil {
                _conversationsListModule = ConversationsListAssembly(storageManager: storageManager)
            }
            
            return _conversationsListModule!
        }
    }
    
    private var _conversationModule: ConversationAssembly?
    public var conversationModule: ConversationAssembly {
        get {
            if _conversationModule == nil {
                _conversationModule = ConversationAssembly(storageManager: storageManager, communicationManager: communicationManager)
            }
            
            return _conversationModule!
        }
    }
    
    private var _profileModule: ProfileAssembly?
    public var profileModule: ProfileAssembly {
        get {
            if _profileModule == nil {
                _profileModule = ProfileAssembly(storageManager: storageManager, communicationManager: communicationManager)
            }
            
            return _profileModule!
        }
    }
    
    public func turnOffCommunicator() {
        communicationManager.online = false
        storageManager.setAllUsersOffline()
    }
    
    public func turnOnCommunicator() {
        communicationManager.online = true
    }
}
