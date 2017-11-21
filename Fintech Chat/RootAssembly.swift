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
    var conversationsListModule: ConversationsListAssembly {
        get {
            if _conversationsListModule == nil {
                _conversationsListModule = ConversationsListAssembly(storageManager: storageManager)
            }
            
            return _conversationsListModule!
        }
    }
    
    private var _conversationModule: ConversationAssembly?
    var conversationModule: ConversationAssembly {
        get {
            if _conversationModule == nil {
                _conversationModule = ConversationAssembly(storageManager: storageManager, communicationManager: communicationManager)
            }
            
            return _conversationModule!
        }
    }
    
    private var _profileModule: ProfileAssembly?
    var profileModule: ProfileAssembly {
        get {
            if _profileModule == nil {
                _profileModule = ProfileAssembly(storageManager: storageManager, communicationManager: communicationManager)
            }
            
            return _profileModule!
        }
    }
    
    private var _imageCollectionModule: ImageCollectionAssembly?
    var imageCollectionModule: ImageCollectionAssembly {
        get {
            if _imageCollectionModule == nil {
                _imageCollectionModule = ImageCollectionAssembly()
            }
            
            return _imageCollectionModule!
        }
    }
    
    func turnOffCommunicator() {
        communicationManager.online = false
        storageManager.setAllUsersOffline()
    }
    
    func turnOnCommunicator() {
        communicationManager.online = true
    }
}
