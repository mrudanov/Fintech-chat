//
//  ConversationsTableDataSource.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 11/11/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol ConversationsListTableDataSourceDelegate: class {
    func deleteRow(at: IndexPath) -> Void
    func insertRow(at: IndexPath) -> Void
    func updateRow(at: IndexPath) -> Void
    func beginUpdates() -> Void
    func endUpdates() -> Void
    func deleteSection(sectionIndex: Int) -> Void
    func insertSection(sectionIndex: Int) -> Void
    func prepareCell(with user: User, at indexPath: IndexPath) -> UITableViewCell
}

protocol IConversationsListTableModel {
    weak var delegate: ConversationsListTableDataSourceDelegate? {get set}
    func getUserForRowAt(indexPath: IndexPath) -> User
}

typealias IConversationsListTableDataSource = IConversationsListTableModel & UITableViewDataSource

class ConversationsListTableDataSource: NSObject, IConversationsListTableDataSource {
    
    private let service: IConversationsPreviewsService
    weak var delegate: ConversationsListTableDataSourceDelegate?
    
    init(service: IConversationsPreviewsService) {
        self.service = service
        super.init()
        service.delegate = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return service.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return service.numberOfRowsInSections(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = service.objectForRowAt(indexPath: indexPath)
        
        return delegate?.prepareCell(with: user, at: indexPath) ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let serviceTitle = service.titlerForSection(section)
        return serviceTitle == "1" ? "Online" : "History"
    }
    
    public func getUserForRowAt(indexPath: IndexPath) -> User {
        return service.objectForRowAt(indexPath: indexPath)
    }
}

extension ConversationsListTableDataSource: ConversationsServicesDelegate {
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
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .delete:
            delegate?.deleteSection(sectionIndex: sectionIndex)
        case .insert:
            delegate?.insertSection(sectionIndex: sectionIndex)
        case .move, .update: break
        }
    }
}
