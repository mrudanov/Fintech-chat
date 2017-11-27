//
//  ConversationService.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 14/11/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import Foundation
import CoreData

protocol IConversationService: class {
    weak var delegate: (ConversationsServicesDelegate & OnlineMonitoringDelegate)? {get set}
    func numberOfRowsInSections(_ section: Int) -> Int
    func objectForRowAt(indexPath: IndexPath) -> Message
    func sendMessage(text: String, to userID: String, completiionHandler: ((Bool, Error?) -> ())?) -> Void
}

protocol OnlineMonitoringDelegate: class {
    func userBecameOnline()
    func userBecameOffline()
}

class ConversationService: IConversationService {
    
    private let fetchedResultsController: NSFetchedResultsController<Message>
    private let communicationManager: ICommunicationManager
    private let storageManager: StorageManager
    private let conversationWithUserId: String
    
    weak var delegate: (ConversationsServicesDelegate & OnlineMonitoringDelegate)? {
        didSet {
            fetchedResultsController.delegate = delegate
        }
    }
    
    init(userId: String, storageManager: StorageManager, communicationManager: ICommunicationManager) {
        self.storageManager = storageManager
        fetchedResultsController = storageManager.getConversationWithUserFRC(userId: userId)
        self.communicationManager = communicationManager
        conversationWithUserId = userId
        self.storageManager.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Error fetching: \(error)")
        }
    }
    
    deinit {
        self.storageManager.delegate = nil
    }
    
    public func numberOfSections() -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    public func numberOfRowsInSections(_ section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    public func objectForRowAt(indexPath: IndexPath) -> Message {
        return fetchedResultsController.object(at: indexPath)
    }
    
    func sendMessage(text: String, to userID: String, completiionHandler: ((Bool, Error?) -> ())?) {
        communicationManager.sendMessage(text: text, to: userID, completionHandler: completiionHandler)
    }
}

extension ConversationService: StorageManagerDelegate {
    func didChangeData() {
        guard let user = storageManager.getUserById(conversationWithUserId) else {
            print("Did not found conversation's user")
            return
        }
        
        if user.isOnline {
            delegate?.userBecameOnline()
        } else {
            delegate?.userBecameOffline()
        }
    }
}
