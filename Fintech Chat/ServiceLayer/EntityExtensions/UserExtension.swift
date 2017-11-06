//
//  UserExtension.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 06/11/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import Foundation
import CoreData
import UIKit


extension User {
    static func generateUserIdString() -> String {
        let string = "\(arc4random_uniform(UINT32_MAX))+\(Date.timeIntervalSinceReferenceDate)+\(arc4random_uniform(UINT32_MAX))".data(using: .utf8)?.base64EncodedString()
        return string!
    }
    
    static func generateCurrentUserNameString() -> String {
        let string = UIDevice.current.name
        return string
    }
    
    static func findOrInsertUser(with id: String, in context: NSManagedObjectContext) -> User? {
        guard let model = context.persistentStoreCoordinator?.managedObjectModel else {
            print("Model is not available in context!")
            assert(false)
            return nil
        }
        
        var user: User?
        guard let fetchReguest = User.fetchRequestUserWithId(id, model: model) else {
            return nil
        }
        
        do {
            let results = try context.fetch(fetchReguest)
            if let foundUser = results.first {
                user = foundUser
            }
        } catch {
            print("Failed to fetch User: \(error)")
        }
        
        if user == nil {
            user = User.insertUser(with: id, in: context)
        }
        
        return user
    }
    
    static func insertUser(with id: String, in context: NSManagedObjectContext) -> User? {
        if let user = NSEntityDescription.insertNewObject(forEntityName: "User", into: context) as? User {
            user.userId = id
            return user
        }
        return nil
    }
    
    static func fetchRequestUserWithId(_ id: String, model: NSManagedObjectModel) -> NSFetchRequest<User>? {
        let fetchRequest: NSFetchRequest<User> = NSFetchRequest(entityName: "User")
        fetchRequest.predicate = NSPredicate(format: "userId = %@", id)
        return fetchRequest
    }
}
