//
//  ConversationsPreviewsService.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 11/11/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import Foundation
import CoreData

protocol IConversationsPreviewsService: class {
    weak var delegate: ConversationsServicesDelegate? {get set}
    func numberOfSections() -> Int
    func numberOfRowsInSections(_ section: Int) -> Int
    func objectForRowAt(indexPath: IndexPath) -> User
    func titlerForSection(_ section: Int) -> String?
}

typealias ConversationsServicesDelegate = NSFetchedResultsControllerDelegate

class ConversationsPreviewsService: IConversationsPreviewsService {
    private let fetchedResultsController: NSFetchedResultsController<User>
    private let storageManager: StorageManager
    
    weak var delegate: ConversationsServicesDelegate? {
        didSet {
            fetchedResultsController.delegate = delegate
        }
    }

    init(storageManager: StorageManager) {
        self.storageManager = storageManager
        fetchedResultsController = storageManager.getConversationsPreviewFRC()
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Error fetching: \(error)")
        }
    }
    
    public func numberOfSections() -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    public func numberOfRowsInSections(_ section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    public func objectForRowAt(indexPath: IndexPath) -> User {
        try? fetchedResultsController.performFetch()
        return fetchedResultsController.object(at: indexPath)
    }
    
    public func titlerForSection(_ section: Int) -> String? {
        return fetchedResultsController.sections?[section].name
    }
}
