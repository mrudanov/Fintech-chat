//
//  CommunicationManager.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 13/11/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import Foundation

protocol ICommunicationManager: class {
    var online: Bool {get set}
    func sendMessage(text: String, to userID: String, completionHandler : ((_ success : Bool, _ error : Error?) -> ())?)
    func reloadCommunicator()
}

class CommunicationManager: ICommunicationManager {
    
    private var _online: Bool = false
    public var online: Bool {
        get {
            return _online
        }
        set{
            _online = newValue
            self.communicator?.online = newValue
        }
    }
    
    private var storageManager: StorageManager
    private var communicator: Communicator?
    
    init(storageManager: StorageManager) {
        self.storageManager = storageManager
        self.configureCommunicator()
    }
    
    func reloadCommunicator() {
        communicator?.online = false
        communicator = nil
        configureCommunicator()
    }
    
    private func configureCommunicator() {
        communicator = nil
        let userID = storageManager.getAppUserId()
        let (name, _, _) = storageManager.getAppUserInfo()
        communicator = MultipeerCommunicator(userId: userID, name: name)
        communicator?.delegate = self
        communicator?.online = online
    }
    
    func sendMessage(text: String, to toUserID: String, completionHandler : ((_ success : Bool, _ error : Error?) -> ())?) {
        let currentUserID = storageManager.getAppUserId()
        communicator?.sendMessage(string: text, to: toUserID) { [weak self] success, error in
            if let strongSelf = self, success {
                strongSelf.storageManager.insertMessage(text: text, fromUserID: currentUserID, toUserID: toUserID)
                completionHandler?(true, error)
            } else {
                completionHandler?(false, error)
            }
        }
    }
}

extension CommunicationManager: CommunicatorDelegate {
    func didFoundUser(userID : String, userName : String?) {
        storageManager.updateUser(userID: userID, userName: userName, info: nil, image: nil, isOnline: true, completionHandler: nil)
    }
    
    func didLostUser(userID : String) {
        storageManager.updateUser(userID: userID, userName: nil, info: nil, image: nil, isOnline: false, completionHandler: nil)
    }
    
    func failedToStartBrowsingForUsers(error : Error) {
        print(error.localizedDescription)
    }
    
    func failedToStartAdvertising(error : Error) {
        print(error.localizedDescription)
    }
    
    func didReceiveMessage(text: String, fromUser: String, toUser: String) {
        storageManager.insertMessage(text: text, fromUserID: fromUser, toUserID: toUser)
    }
}
