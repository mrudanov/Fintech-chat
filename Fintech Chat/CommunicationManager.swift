//
//  CommunicationManager.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 21/10/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import Foundation

protocol CommunicatorDelegate: class {
    // discivering
    func didFoundUser(userID: String, userName: String?)
    func didLostUser(userID: String)
    
    // errors
    func failedToStartBrowsingForUsers(error: Error)
    func failedToStartAdvertising(error: Error)
    
    // messages
    func didRecieveMessage(text: String, fromUser: String, toUser: String)
}

protocol CommunicationManagerDelegate: class {
    func addOnlineUser(userID: String, name: String?, lastText: String?, lastTextDate: Date?)
    func removeOnlineUser(userID: String)
    func recievedMessage(text: String, fromUser: String, date: Date)
}

class CommunicationManager: CommunicatorDelegate {
    
    struct User {
        let userID: String
        var userName: String?
    }
    
    struct Message {
        let text: String
        let date: Date
        let from: String
        let to: String
    }
    
    private var users: [String: User] = [:]
    private var messages: [Message] = []
    var communicator: MultipeerCommunicator?
    
    weak var delegate: CommunicationManagerDelegate?
    
    func didFoundUser(userID: String, userName: String?) {
        users[userID] = User(userID: userID, userName: userName)
        let messagesForUser = messages.filter() { $0.from == userID || $0.to == userID }
        let sortedMessages = messagesForUser.sorted() { $0.date < $1.date }
        let lastMessage = sortedMessages.isEmpty ? nil : sortedMessages[sortedMessages.endIndex - 1]
        delegate?.addOnlineUser(userID: userID, name: userName, lastText: lastMessage?.text, lastTextDate: lastMessage?.date)
    }
    
    func didLostUser(userID: String) {
        users[userID] = nil
        delegate?.removeOnlineUser(userID: userID)
    }
    
    func failedToStartBrowsingForUsers(error: Error) {
        print(error.localizedDescription)
    }
    
    func failedToStartAdvertising(error: Error) {
        print(error.localizedDescription)
    }
    
    func didRecieveMessage(text: String, fromUser: String, toUser: String) {
        let recievedDate = Date()
        messages.append(Message(text: text, date: recievedDate, from: fromUser, to: toUser))
        
        if communicator != nil {
            if communicator!.peer.displayName == toUser {
                delegate?.recievedMessage(text: text, fromUser: fromUser, date: recievedDate)
                let message = ["text": text, "from": fromUser]
                NotificationCenter.default.post(name: NSNotification.Name.DidRecievedMessage, object: nil, userInfo: message)
            }
        }
    }
    
    func sendMessage(text: String, to userID: String, completiionHandler: ((Bool, Error?) -> ())?){
        if communicator != nil {
            communicator!.sendMessage(string: text, to: userID) { [weak self] flag, error in
                completiionHandler?(flag, error)
                self?.messages.append(Message(text: text, date: Date(), from: self!.communicator!.peer.displayName, to: userID))
            }
        } else {
            completiionHandler?(false, nil)
        }
    }
    
    func updateOnlineUsers() {
        for user in users {
            let userID = user.key
            let messagesForUser = messages.filter() { $0.from == userID || $0.to == userID }
            let sortedMessages = messagesForUser.sorted() { $0.date < $1.date }
            let lastMessage = sortedMessages.isEmpty ? nil : sortedMessages[sortedMessages.endIndex - 1]
            delegate?.addOnlineUser(userID: userID, name: user.value.userName, lastText: lastMessage?.text, lastTextDate: lastMessage?.date)
        }
    }
}

extension NSNotification.Name {
    
    public static let DidRecievedMessage: NSNotification.Name
    
    public static let UITextFieldTextDidEndEditing: NSNotification.Name
    
    public static let UITextFieldTextDidChange: NSNotification.Name
    
}
