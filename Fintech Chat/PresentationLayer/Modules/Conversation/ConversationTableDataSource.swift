////
////  ConversationTableDataSource.swift
////  Fintech Chat
////
////  Created by Mikhail Rudanov on 12/11/2017.
////  Copyright © 2017 Mikhail Rudanov. All rights reserved.
////
//
//import Foundation
//import UIKit
//import CoreData
//
//protocol ConversationTableDataSourceDelegate: class {
//    func deleteRow(at: IndexPath) -> Void
//    func insertRow(at: IndexPath) -> Void
//    func updateRow(at: IndexPath) -> Void
//    func beginUpdates() -> Void
//    func endUpdates() -> Void
//}
//
//class ConversationTableDataSource: NSObject, UITableViewDataSource {
//    private let service: IConversationPreviewsService
//    weak var delegate: ConversationsListTableDataSourceDelegate?
//
//    init(service: IConversationPreviewsService) {
//        self.service = service
//    }
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return service.numberOfSections()
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return service.numberOfRowsInSections(section)
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell", for: indexPath)
//
//        let message = service.objectForRowAt(indexPath: indexPath)
//
//        return prepareCell(cell, with: user)
//    }
//
//    private func prepareCell(_ cell: UITableViewCell ,with message: Massage) -> UITableViewCell {
//        if let conversationCell = cell as? ConversationTableViewCell {
//            conversationCell.name = user.name
//            conversationCell.message = user.conversation?.lastMessage?.text
//            conversationCell.date = user.conversation?.lastMessage?.date
//            conversationCell.online = user.isOnline
//            conversationCell.updateCellUI()
//            if let count = user.conversation?.unreadMessages?.count {
//                conversationCell.hasUnreadMessages = count != 0
//            } else {
//                conversationCell.hasUnreadMessages = false
//            }
//        }
//
//        return cell
//    }
//
//    public func getObjectForRowAt(indexPath: IndexPath) -> User {
//        return service.objectForRowAt(indexPath: indexPath)
//    }
//
//}
//
//extension ConversationTableDataSource: NSFetchedResultsControllerDelegate {
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        print("Object changed.")
//        switch type {
//        case .delete:
//            if let indexPath = indexPath {
//                delegate?.deleteRow(at: indexPath)
//            }
//        case .insert:
//            if let newIndexPath = newIndexPath {
//                delegate?.insertRow(at: newIndexPath)
//            }
//        case .move:
//            if let indexPath = indexPath {
//                delegate?.deleteRow(at: indexPath)
//            }
//            if let newIndexPath = newIndexPath {
//                delegate?.insertRow(at: newIndexPath)
//            }
//        case .update:
//            if let indexPath = indexPath {
//                delegate?.updateRow(at: indexPath)
//            }
//        }
//    }
//
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        delegate?.beginUpdates()
//    }
//
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        delegate?.endUpdates()
//    }
//}

