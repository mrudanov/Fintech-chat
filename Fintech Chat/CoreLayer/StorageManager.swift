//
//  StorageManager.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 13/11/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import Foundation
import CoreData

protocol StorageManager: class {
    func updateUser(userID: String, userName: String?, info: String?, image: Data?, isOnline: Bool, completionHandler: (() -> Void)?)
    func insertMessage(text: String, fromUserID: String, toUserID: String)
    func getAppUserId() -> String
    func getAppUserInfo() -> (name: String?, info: String?, image: Data?)
    func getConversationsPreviewFRC() -> NSFetchedResultsController<User>
    func getConversationWithUserFRC(userId: String) -> NSFetchedResultsController<Message>
    func setAllUsersOffline()
}

class CoreDataStorageManager: StorageManager {
    
    private let coreDataStack: ICoreDataStack
    
    init(coreDataStack: ICoreDataStack) {
        self.coreDataStack = coreDataStack
    }
    
    public func updateUser(userID: String, userName: String?, info: String?, image: Data?, isOnline: Bool, completionHandler: (() -> Void)?) {
        print("Updating user \(userName ?? "")")
        guard let mainContext = coreDataStack.mainContext else {
            assert(false, "No main context!")
        }
        
        mainContext.perform { [weak self] in
            if let mainContext = self?.coreDataStack.mainContext {
                let user = User.findOrInsertUser(with: userID, in: mainContext)
                user?.isOnline = isOnline
                if userName != nil {
                    user?.name = userName
                }
                if info != nil {
                    user?.info = info
                }
                if image != nil {
                    user?.image = image
                }
                
                self?.coreDataStack.performSave(context: mainContext, completionHandler: completionHandler)
            }
        }
    }
    
    public func insertMessage(text: String, fromUserID: String, toUserID: String) {
        print("Adding message: \"\(text)\" from \(fromUserID)")
        guard let mainContext = coreDataStack.mainContext else {
            assert(false, "No main context!")
        }
        
        mainContext.perform { [weak self] in
            if let mainContext = self?.coreDataStack.mainContext {
                if let fromUser = User.findUser(with: fromUserID, in: mainContext) {
                    if let toUser = User.findUser(with: toUserID, in: mainContext) {
                        let message = Message.insertMessage(in: mainContext)
                        message?.sender = fromUser
                        message?.reciever = toUser
                        message?.text = text
                        message?.date = Date()
                        
                        var conversation: Conversation?
                        let currentUserId = self?.getAppUserId()
                        if currentUserId == fromUserID {
                            if toUser.conversation == nil {
                                toUser.conversation = Conversation.insertConversation(in: mainContext)
                            }
                            conversation = toUser.conversation
                        } else {
                            if fromUser.conversation == nil {
                                fromUser.conversation = Conversation.insertConversation(in: mainContext)
                            }
                            conversation = fromUser.conversation
                        }
                        message?.unreadInConversation = conversation
                        message?.conversation = conversation
                        message?.lastMessageInConversation = conversation
                        
                        self?.coreDataStack.performSave(context: mainContext, completionHandler: nil)
                    }
                }
            }
        }
    }
    
    public func getAppUserInfo() -> (name: String?, info: String?, image: Data?) {
        guard let mainContext = coreDataStack.mainContext else {
            assert(false, "No save context!")
        }
        var userInfo: (name: String?, info: String?, image: Data?) = (nil, nil ,nil)
        mainContext.performAndWait { [weak self] in
            let appUser = AppUser.findOrInsertAppUser(in: mainContext)
            userInfo.name = appUser?.currentUser?.name
            userInfo.info = appUser?.currentUser?.info
            userInfo.image = appUser?.currentUser?.image
            
            self?.coreDataStack.performSave(context: mainContext, completionHandler: nil)
        }
        return userInfo
    }
    
    public func getAppUserId() -> String {
        guard let mainContext = coreDataStack.mainContext else {
            assert(false, "No save context!")
        }
        var id = String()
        mainContext.performAndWait { [weak self] in
            let appUser = AppUser.findOrInsertAppUser(in: mainContext)
            guard appUser?.currentUser?.userId != nil else {
                assert(false, "Current user doesn`t have userId!")
            }
            id = (appUser?.currentUser?.userId)!
            
            self?.coreDataStack.performSave(context: mainContext, completionHandler: nil)
        }
        return id
    }
    
    public func getConversationsPreviewFRC() -> NSFetchedResultsController<User> {
        guard let mainContext = coreDataStack.mainContext else {
            assert(false, "No main context!")
        }
        
        guard let model = mainContext.persistentStoreCoordinator?.managedObjectModel else {
            print("Model is not available in context!")
            assert(false)
        }
        
        let fetchRequest = User.fetchRequestUserOnlineOrWithConversation(model: model)
        return NSFetchedResultsController<User>(fetchRequest: fetchRequest, managedObjectContext: mainContext, sectionNameKeyPath: #keyPath(User.isOnline), cacheName: nil)
    }
    
    public func getConversationWithUserFRC(userId: String) -> NSFetchedResultsController<Message> {
        guard let mainContext = coreDataStack.mainContext else {
            assert(false, "No main context!")
        }
        
        guard let model = mainContext.persistentStoreCoordinator?.managedObjectModel else {
            print("Model is not available in context!")
            assert(false)
        }
        
        let fetchRequest = Message.fetchRequestMessagesFromDialogWithUser(userId, model: model)
        return NSFetchedResultsController<Message>(fetchRequest: fetchRequest, managedObjectContext: mainContext, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    public func setAllUsersOffline() {
        guard let mainContext = coreDataStack.mainContext else {
            assert(false, "No main context!")
        }
        
        guard let model = mainContext.persistentStoreCoordinator?.managedObjectModel else {
            print("Model is not available in context!")
            assert(false)
        }
        
        mainContext.perform { [weak self] in
            let fetchRequest = User.fetchRequestOnlineUsers(model: model)
            do {
                let results = try mainContext.fetch(fetchRequest)
                for user in results {
                    user.isOnline = false
                }
            } catch {
                print("Failed to fetch AppUser: \(error)")
            }
            
            self?.coreDataStack.performSave(context: mainContext, completionHandler: nil)
        }
    }
}
