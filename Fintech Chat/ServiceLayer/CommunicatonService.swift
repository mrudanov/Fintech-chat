//
//  CommunicatonService.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 29/10/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import Foundation

protocol CommunicationService: class {
    func addDelegate(delegate: CommunicationServiceDelegate) -> ()
    func sendMessage(text: String, to userID: String, completiionHandler: ((Bool, Error?) -> ())?) -> Void
}

private class WeakDelegateWrapper {
    weak var value: CommunicationServiceDelegate?
    
    init(value: CommunicationServiceDelegate) {
        self.value = value
    }
}

protocol CommunicationServiceDelegate: class {
    func didFoundUser(userID: String, userName: String?)
    func didLostUser(userID: String)
    func didRecieveMessage(text: String, date: Date, fromUser: String)
    func didSendMessage(to: String, date: Date, text: String)
}

class CommunicationManager: CommunicationService {
    
    private var communicator: Communicator?
    private var delegates: [WeakDelegateWrapper] = []
    
    init(communicator: Communicator) {
        self.communicator = communicator
    }
    
    func addDelegate(delegate: CommunicationServiceDelegate) {
        delegates.append(WeakDelegateWrapper(value: delegate))
    }
    
    func sendMessage(text: String, to userID: String, completiionHandler: ((Bool, Error?) -> ())?){
        if communicator != nil {
            communicator!.sendMessage(string: text, to: userID) { [weak self] flag, error in
                if self != nil {
                    for delegate in self!.delegates {
                        delegate.value?.didSendMessage(to: userID, date: Date(), text: text)
                    }
                }
                completiionHandler?(flag, error)
            }
        } else {
            completiionHandler?(false, nil)
        }
    }
}

extension CommunicationManager: CommunicatorDelegate {
    func didFoundUser(userID: String, userName: String?) {
        for delegate in delegates {
            delegate.value?.didFoundUser(userID: userID, userName: userName)
        }
    }
    
    func didLostUser(userID: String) {
        for delegate in delegates {
            delegate.value?.didLostUser(userID: userID)
        }
    }
    
    func failedToStartBrowsingForUsers(error: Error) {
        print(error.localizedDescription)
    }
    
    func failedToStartAdvertising(error: Error) {
        print(error.localizedDescription)
    }
    
    func didRecieveMessage(text: String, fromUser: String, toUser: String) {
        let recievedDate = Date()
        for delegate in delegates {
            delegate.value?.didRecieveMessage(text: text, date: recievedDate, fromUser: fromUser)
        }
    }
}
