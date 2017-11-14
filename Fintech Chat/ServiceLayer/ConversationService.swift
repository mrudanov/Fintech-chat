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
    weak var delegate: ConversationsServicesDelegate? {get set}
    func numberOfRowsInSections(_ section: Int) -> Int
    func objectForRowAt(indexPath: IndexPath) -> Message
    func sendMessage(text: String, to userID: String, completiionHandler: ((Bool, Error?) -> ())?) -> Void
}

typealias ConversationsServicesDelegate = NSFetchedResultsControllerDelegate

class ConversationService: IConversationService {
    
    private let fetchedResultsController: NSFetchedResultsController<Message>
    private let communicationManager: ICommunicationManager
    private let storageManager: StorageManager
    
    weak var delegate: ConversationsServicesDelegate? {
        didSet {
            fetchedResultsController.delegate = delegate
        }
    }
    
    init(userId: String, storageManager: StorageManager, communicationManager: ICommunicationManager) {
        self.storageManager = storageManager
        fetchedResultsController = storageManager.getConversationWithUserFRC(userId: userId)
        self.communicationManager = communicationManager
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Error fetching: \(error)")
        }
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
