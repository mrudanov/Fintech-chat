//
//  ConversationTableDataSource.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 12/11/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol ConversationTableDataSourceDelegate: class {
    func deleteRow(at: IndexPath) -> Void
    func insertRow(at: IndexPath) -> Void
    func updateRow(at: IndexPath) -> Void
    func beginUpdates() -> Void
    func endUpdates() -> Void
    func prerapeCell(with message: Message, at indexPath: IndexPath) -> UITableViewCell
}

protocol IConversationTableModel {
    weak var delegate: ConversationTableDataSourceDelegate? {get set}
    func sendMessage(text: String, to: String, completiionHandler: ((Bool, Error?) -> ())?)
}

typealias IConversationTableDataSource = IConversationTableModel & UITableViewDataSource

class ConversationTableDataSource: NSObject, IConversationTableDataSource {
    private let service: IConversationService
    weak var delegate: ConversationTableDataSourceDelegate?
    private let userId: String

    init(userId: String, conversationService: IConversationService) {
        service = conversationService
        self.userId = userId
        super.init()
        service.delegate = self
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return service.numberOfRowsInSections(section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = service.objectForRowAt(indexPath: indexPath)
        return delegate?.prerapeCell(with: message, at: indexPath) ?? UITableViewCell()
        
    }
    
    public func sendMessage(text: String, to: String, completiionHandler: ((Bool, Error?) -> ())?) {
        service.sendMessage(text: text, to: userId, completiionHandler: completiionHandler)
    }

}

extension ConversationTableDataSource: ConversationsServicesDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        print("Object at section: \(String(describing: indexPath?.section)), row: \(String(describing: indexPath?.row)) is going to be")
        switch type {
        case .delete:
            print("deleted")
            if let indexPath = indexPath {
                delegate?.deleteRow(at: indexPath)
            }
        case .insert:
            print("inserted")
            if let newIndexPath = newIndexPath {
                delegate?.insertRow(at: newIndexPath)
            }
        case .move:
            print("moved")
            if let indexPath = indexPath {
                delegate?.deleteRow(at: indexPath)
            }
            if let newIndexPath = newIndexPath {
                delegate?.insertRow(at: newIndexPath)
            }
        case .update:
            print("updated")
            if let indexPath = indexPath {
                delegate?.updateRow(at: indexPath)
            }
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.endUpdates()
    }
}

