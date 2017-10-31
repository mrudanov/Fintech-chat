//
//  ConversationsPreviewModel.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 29/10/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import Foundation

struct ConversationPreview {
    var userID: String
    var name: String?
    var message: String?
    var date: Date?
    var hasUnreadMessages: Bool
}

protocol PreviewModel: class {
    weak var delegate: PreviewDataModelDelegate? {get set}
    func getOnlineUsersCount() -> Int
    func getOfflineUsersCount() -> Int
    func getOnlineUser(atIndex: Int) -> ConversationPreview
    func getOfflineUser(atIndex: Int) -> ConversationPreview
}

protocol PreviewDataModelDelegate: class {
    func didUpdatedUsersList()
}

class ConversationsPreviewModel: PreviewModel {
    
    private var onlineUsers: [ConversationPreview] = []
    private var offlineUsers: [ConversationPreview] = []
    
    weak var delegate: PreviewDataModelDelegate?
    
    private let communicationService: CommunicationService
    
    init(communicationService: CommunicationService) {
        self.communicationService = communicationService
    }
    
    // MARK: - PreviewDataModel protocol
    
    func getOnlineUsersCount() -> Int {
        return onlineUsers.count
    }
    
    func getOfflineUsersCount() -> Int {
        return offlineUsers.count
    }
    
    func getOnlineUser(atIndex index: Int) -> ConversationPreview {
        return onlineUsers[index]
    }
    
    func getOfflineUser(atIndex index: Int) -> ConversationPreview {
        return onlineUsers[index]
    }
    
    // MARK: - PRIVATE SECTION
    
    private func sortOnlineUsers() {
        onlineUsers = onlineUsers.sorted() {
            if $0.date != nil && $1.date != nil {return $0.date! > $1.date!}
            if $0.date != nil && $1.date == nil {return true}
            if $0.date == nil && $1.date != nil {return false}
            if $0.name != nil && $1.name != nil {return $0.name! < $1.name!}
            if $0.name != nil && $1.name == nil {return true}
            if $0.name == nil && $1.name != nil {return false}
            return $0.userID > $1.userID
        }
        delegate?.didUpdatedUsersList()
    }
}

extension ConversationsPreviewModel: CommunicationServiceDelegate {
    func didSendMessage(to: String, date: Date, text: String) {
        if let index = onlineUsers.index(where: { $0.userID == to }) {
            onlineUsers[index].date = date
            onlineUsers[index].message = text
        }
        sortOnlineUsers()
    }
    
    func didFoundUser(userID: String, userName: String?) {
        print("Adding user")
        if let index = onlineUsers.index(where: { $0.userID == userID }) {
            if onlineUsers[index].name != userName {onlineUsers[index].name = userName}
        } else {
            onlineUsers.append(ConversationPreview(userID: userID, name: userName, message: nil, date: nil, hasUnreadMessages: false))
        }
        sortOnlineUsers()
    }
    
    func didLostUser(userID: String) {
        print("Removing user")
        onlineUsers = onlineUsers.filter() { $0.userID != userID }
        sortOnlineUsers()
    }
    
    func didRecieveMessage(text: String, date: Date, fromUser: String) {
        if let index = onlineUsers.index(where: { $0.userID == fromUser }) {
            onlineUsers[index].message = text
            onlineUsers[index].date = date
            onlineUsers[index].hasUnreadMessages = true
        }
        sortOnlineUsers()
    }
}
