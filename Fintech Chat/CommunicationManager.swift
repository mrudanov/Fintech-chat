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
    
    func didFoundUser(userID: String, userName: String?) {
        users[userID] = User(userID: userID, userName: userName)
        let messagesForUser = messages.filter() { $0.from == userID || $0.to == userID }
        let sortedMessages = messagesForUser.sorted() { $0.date < $1.date }
        let lastMessage = sortedMessages.isEmpty ? nil : sortedMessages[sortedMessages.endIndex - 1]
        var user: [String: Any] = ["userID": userID]
        user["name"] = userName
        if lastMessage != nil {
            user["text"] = lastMessage!.text
            user["date"] = lastMessage!.date
        }
        print("Sending notification")
        NotificationCenter.default.post(name: NSNotification.Name("DidFoundUser"), object: nil, userInfo: user)
    }
    
    func didLostUser(userID: String) {
        users[userID] = nil
        NotificationCenter.default.post(name: NSNotification.Name("DidLostUser"), object: nil, userInfo: ["userID": userID])
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
                let message: [String: Any] = ["text": text, "from": fromUser, "date": recievedDate]
                NotificationCenter.default.post(name: NSNotification.Name("DidRecievedMessage"), object: nil, userInfo: message)
            }
        }
    }
    
    func sendMessage(text: String, to userID: String, completiionHandler: ((Bool, Error?) -> ())?){
        if communicator != nil {
            communicator!.sendMessage(string: text, to: userID) { [weak self] flag, error in
                completiionHandler?(flag, error)
                let sendDate = Date()
                self?.messages.append(Message(text: text, date: sendDate, from: self!.communicator!.peer.displayName, to: userID))
                let message: [String: Any] = ["text": text, "to": userID, "date": sendDate]
                NotificationCenter.default.post(name: NSNotification.Name("DidSendMessage"), object: nil, userInfo: message)
            }
        } else {
            completiionHandler?(false, nil)
        }
    }
}
