//
//  CoreDataStack.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 05/11/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import Foundation
import CoreData

protocol ICoreDataStack {
    func performSave(context: NSManagedObjectContext, completionHandler: (()->Void)? )
    var mainContext: NSManagedObjectContext? { get }
    var saveContext: NSManagedObjectContext? { get }
}

class CoreDataStack: ICoreDataStack {
    
    // MARK: - Saving contexts
    public func performSave(context: NSManagedObjectContext, completionHandler: (()->Void)? ) {
        if context.hasChanges {
            context.perform { [weak self] in
                do {
                    try context.save()
                } catch {
                    print("Context save error: \(error)")
                }
                
                if let parent = context.parent {
                    self?.performSave(context: parent, completionHandler: completionHandler)
                } else {
                    completionHandler?()
                }
            }
        } else {
            completionHandler?()
        }
    }
    
    // MARK: - Store URL
    private var storeURL: URL {
        get {
            let documentsDirURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let url = documentsDirURL.appendingPathComponent("Store.sqlite")
            return url
        }
    }
    
    // MARK: - Managed object model
    private let managedObjectModelName = "Storage"
    private var _managedObjectModel: NSManagedObjectModel?
    private var managedObjectModel: NSManagedObjectModel? {
        get {
            if _managedObjectModel == nil {
                guard let modelURL = Bundle.main.url(forResource: managedObjectModelName, withExtension: "momd") else {
                    print("Empty modl url")
                    return nil
                }
                
                _managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)
            }
            return _managedObjectModel
        }
    }
    
    // MARK: - Coordinator
    private var _persistentStoreCoordinator: NSPersistentStoreCoordinator?
    private var persistentStoreCoordinator: NSPersistentStoreCoordinator? {
        get {
            if _persistentStoreCoordinator == nil {
                guard let model = self.managedObjectModel else {
                    print("Empty managed object model!")
                    return nil
                }
                
                _persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
                
                do {
                    try _persistentStoreCoordinator?.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
                } catch {
                    assert(false, "Error adding persistant store to coordinator: \(error)")
                }
            }
            
            return _persistentStoreCoordinator
        }
    }
    
    // MARK: - Master context
    private var _masterContext: NSManagedObjectContext?
    private var masterContext: NSManagedObjectContext? {
        get {
            if _masterContext == nil {
                let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                guard let persistentStoreCoordinator = self.persistentStoreCoordinator else {
                    print("Empty persistent store coordinator!")
                    return nil
                }
                
                context.persistentStoreCoordinator = persistentStoreCoordinator
                context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
                context.undoManager = nil
                _masterContext = context
            }
            
            return _masterContext
        }
    }
    
    // MARK: - Main context
    private var _mainContext: NSManagedObjectContext?
    public var mainContext: NSManagedObjectContext? {
        get {
            if _mainContext == nil {
                let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
                guard let parentContext = self.masterContext else {
                    print("No master context!")
                    return nil
                }
                
                context.parent = parentContext
                context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
                context.undoManager = nil
                _mainContext = context
            }
            
            return _mainContext
        }
    }
    
    // MARK: - Save context
    private var _saveContext: NSManagedObjectContext?
    public var saveContext: NSManagedObjectContext? {
        get {
            if _saveContext == nil {
                let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
                guard let parentContext = self.mainContext else {
                    print("No main context!")
                    return nil
                }
                
                context.parent = parentContext
                context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
                context.undoManager = nil
                _saveContext = context
            }
            
            return _saveContext
        }
    }
}
