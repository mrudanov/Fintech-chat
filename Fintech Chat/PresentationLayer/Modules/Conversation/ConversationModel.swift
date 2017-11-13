//
//  ConversationModel.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 30/10/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import Foundation

enum MessagePresentation {
    case input(String)
    case output(String)
}

protocol ConversationDataModel {
    weak var delegate: ConversationDataModelDelegate? {get set}
    func getMessagesCount() -> Int
    func getMessage(atIndex: Int) -> MessagePresentation
    func sendMessage(text: String, to userID: String) -> Void
}

protocol ConversationDataModelDelegate: class {
    func didAddMessage() -> Void
    func didFailedSendMessage(text: String) -> Void
}

class ConversationModel: ConversationDataModel {
    
    var messages: [MessagePresentation] = [ ]

    weak var delegate: ConversationDataModelDelegate?
    private let communicationService: CommunicationService
    private let contactID: String

    init(communicationService: CommunicationService, contactID: String) {
        self.communicationService = communicationService
        self.contactID = contactID
    }

    // MARK: - PreviewDataModel protocol

    func getMessagesCount() -> Int {
        return messages.count
    }

    func getMessage(atIndex: Int) -> MessagePresentation {
        return messages[atIndex]
    }
    
    func sendMessage(text: String, to userID: String) {
        communicationService.sendMessage(text: text, to: userID) { [weak self] flag, error in
            if !flag {
                self?.delegate?.didFailedSendMessage(text: text)
            }
        }
    }
}

extension ConversationModel: CommunicationServiceDelegate {
    func didSendMessage(to: String, date: Date, text: String) {
        messages.append(MessagePresentation.output(text))
        delegate?.didAddMessage()
    }
    
    func didFoundUser(userID: String, userName: String?) { }
    
    func didLostUser(userID: String) { }

    func didRecieveMessage(text: String, date: Date, fromUser: String) {
        if fromUser == contactID {
            messages.append(MessagePresentation.input(text))
            delegate?.didAddMessage()
        }
    }
}


