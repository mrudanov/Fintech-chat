//
//  ConversationPreviewsService.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 11/11/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import Foundation
import CoreData

protocol IConversationPreviewsService: class {
    weak var FRCDelegate: NSFetchedResultsControllerDelegate? {get set}
    func numberOfSections() -> Int
    func numberOfRowsInSections(_ section: Int) -> Int
    func objectForRowAt(indexPath: IndexPath) -> User
}

class ConversationPreviewsService: IConversationPreviewsService {
    private let fetchedResultsController: NSFetchedResultsController<User>
    
    private var coreDataStack: ICoreDataStack?
    weak var FRCDelegate: NSFetchedResultsControllerDelegate? {
        didSet {
            fetchedResultsController.delegate = FRCDelegate
        }
    }

    init(coreDataStack: ICoreDataStack) {
        self.coreDataStack = coreDataStack
        
        guard let mainContext = coreDataStack.mainContext else {
            assert(false, "No main context!")
        }
        
        guard let model = mainContext.persistentStoreCoordinator?.managedObjectModel else {
            print("Model is not available in context!")
            assert(false)
        }
        
        let fetchRequest: NSFetchRequest<User> = User.fetchRequestUserOnlineOrWithConversation(model: model)
        fetchedResultsController = NSFetchedResultsController<User>(fetchRequest: fetchRequest, managedObjectContext: mainContext, sectionNameKeyPath: #keyPath(User.isOnline), cacheName: nil)
        
        do {
            try self.fetchedResultsController.performFetch()
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
    
    public func objectForRowAt(indexPath: IndexPath) -> User {
        return fetchedResultsController.object(at: indexPath)
    }

}

extension ConversationPreviewsService: CommunicatorDelegate {
    func didFoundUser(userID: String, userName: String?) {
        print("Adding user \(userName ?? "") to Core Data.")
        guard let mainContext = coreDataStack?.mainContext else {
            assert(false, "No main context!")
        }
        
        mainContext.perform { [weak self] in
            if let mainContext = self?.coreDataStack?.mainContext {
                let user = User.findOrInsertUser(with: userID, in: mainContext)
                user?.isOnline = true
                user?.name = userName
                
                self?.coreDataStack?.performSave(context: mainContext, completionHandler: nil)
            }
        }
    }
    
    func didLostUser(userID: String) {
        print("User \(userID) did become offline.")
        guard let mainContext = coreDataStack?.mainContext else {
            assert(false, "No main context!")
        }
        
        mainContext.perform { [weak self] in
            if let mainContext = self?.coreDataStack?.mainContext {
                let user = User.findUser(with: userID, in: mainContext)
                user?.isOnline = false
                
                self?.coreDataStack?.performSave(context: mainContext, completionHandler: nil)
            }
        }
    }
    
    func failedToStartBrowsingForUsers(error: Error) {
        print(error.localizedDescription)
    }
    
    func failedToStartAdvertising(error: Error) {
        print(error.localizedDescription)
    }
    
    func didRecieveMessage(text: String, fromUser: String) {
        print("Recieved message: \"\(text)\" from \(fromUser)")
        guard let mainContext = coreDataStack?.mainContext else {
            assert(false, "No main context!")
        }
        
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            print("Error fetching: \(error)")
        }
        
        mainContext.perform { [weak self] in
            if let mainContext = self?.coreDataStack?.mainContext {
                if let user = User.findUser(with: fromUser, in: mainContext) {
                    let appUser = AppUser.findAppUser(in: mainContext)
                    let message = Message.insertMessage(in: mainContext)
                    
                    message?.sender = user
                    message?.reciever = appUser?.currentUser
                    message?.text = text
                    message?.date = Date()
                    if user.conversation == nil {
                        user.conversation = Conversation.insertConversation(in: mainContext)
                    }
                    message?.unreadInConversation = user.conversation
                    message?.conversation = user.conversation
                    message?.lastMessageInConversation = user.conversation
                    
                    self?.coreDataStack?.performSave(context: mainContext, completionHandler: nil)
                    
                    do {
                        try self?.fetchedResultsController.performFetch()
                    } catch {
                        print("Error fetching: \(error)")
                    }
                }
            }
        }
    }
}
